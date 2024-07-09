//
//  NetworkCacheService.swift
//

import Foundation

// MARK: - NetworkCacheCapacity

public typealias NetworkCacheCapacity = NetworkCacheService.CacheCapacity

// MARK: - NetworkCacheService

public final class NetworkCacheService: NetworkCacheServiceProtocol {

    public enum CacheCapacity: Int, Sendable {
        case oneMB = 1
        case twoMB = 2
        case tenMB = 10
        case twentyMB = 20
        case hundredMB = 100
    }

    public init(memoryCapacity: NetworkCacheCapacity = .tenMB, diskCapacity: NetworkCacheCapacity = .hundredMB, maxAge: NetworkCacheAge = .sixWeeks, fileManager: FileManager = .default) {

        self.memoryCapacity = memoryCapacity
        self.diskCapacity = diskCapacity
        self.maxAge = maxAge

        self.cache = Self.createCache(fileManager: fileManager, memoryCapacity: memoryCapacity, diskCapacity: diskCapacity)
    }

    public let memoryCapacity: CacheCapacity
    public let diskCapacity: CacheCapacity
    public let maxAge: NetworkCacheAge // alternatively, use cache.removeCachedResponses(since:)

    // MARK:

    public func cacheItem<T: Codable>(_ item: T, with response: URLResponse, for url: URL, policies: NetworkCachePolicies) {

        let now = Date()
        let payload = NetworkCachePayload(item: item, date: now, expirationPolicy: policies.expiration)

        guard let data = try? encoder.encode(payload) else {
            assertionFailure("cannot cache an invalid encodable")
            return
        }

        let request = cacheableRequest(with: url)
        let cachedResponse = CachedURLResponse(response: response, data: data, userInfo: nil, storagePolicy: policies.storage.foundation)
        cache.storeCachedResponse(cachedResponse, for: request)
    }

    public func readItem<T: Codable>(for url: URL) -> T? {

        let request = cacheableRequest(with: url)
        guard let data = cache.cachedResponse(for: request)?.data else {
            return nil // no cached data
        }

        var item: T?
        if let payload: NetworkCachePayload<T> = decodePayload(from: data) {
            do {
                let now = Date()
                item = try payload.getNonExpiredItem(withCurrentDate: now, maxAge: maxAge)
            } catch {
                cache.removeCachedResponse(for: request)
                item = nil
            }
        }

        return item
    }

    private func decodePayload<T: Codable>(from data: Data) -> NetworkCachePayload<T>? {
        try? decoder.decode(NetworkCachePayload<T>.self, from: data)
    }

    public func removeItem(for url: URL) {
        let request = cacheableRequest(with: url)
        cache.removeCachedResponse(for: request)
    }

    public func removeAllItems() {
        cache.removeAllCachedResponses()
    }

    // MARK:

    private func cacheableRequest(with url: URL) -> URLRequest {
        URLRequest(url: url, cachePolicy: .returnCacheDataDontLoad)
    }

    private let cache: URLCache

    private static func createCache(fileManager: FileManager,
                                    memoryCapacity: CacheCapacity,
                                    diskCapacity: CacheCapacity) -> URLCache {

        let cache: URLCache
        let megabyte = Int(pow(Double(1024), 2))
        let rawMemCapacity = memoryCapacity.rawValue * megabyte
        let rawDiskCapacity = diskCapacity.rawValue * megabyte

        let cacheURL = createDiskCacheURL(fileManager: fileManager)
        cache = URLCache(memoryCapacity: rawMemCapacity, diskCapacity: rawDiskCapacity, directory: cacheURL)
        return cache
    }

    private static func createDiskCacheURL(fileManager: FileManager) -> URL {

        let cachesURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let url = cachesURL.appendingPathComponent("NetworkCache")

        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        } catch CocoaError.fileWriteFileExists {
            // Folder already existed - ignore the error
        } catch {
            print(error)
        }

        return url
    }

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
}

// MARK: - NetworkCachePayload

fileprivate struct NetworkCachePayload<Item>: Codable where Item: Codable {

    // MARK:

    enum Error: Swift.Error {
        case expired
    }

    // MARK:

    var item: Item

    var date: Date

    var expirationPolicy: NetworkCachePolicies.ExpirationPolicy

    // MARK:

    /**
     - Throws ``Error`` if the item has expired
     */
    func getNonExpiredItem(withCurrentDate currentDate: Date, maxAge: NetworkCacheAge) throws -> Item {

        try verifyCachingDate(againstCurrentDate: currentDate, allowedAge: maxAge)
        return try getNonExpiredItemByPolicy(withCurrentDate: currentDate)
    }

    // MARK:

    private func getNonExpiredItemByPolicy(withCurrentDate currentDate: Date) throws -> Item {

        switch expirationPolicy {

        case .nonExpirable:
            break

        case .age(let age):
            try verifyCachingDate(againstCurrentDate: currentDate, allowedAge: age)
        }

        return item
    }

    private func verifyCachingDate(againstCurrentDate currentDate: Date, allowedAge: NetworkCacheAge) throws {

        if currentDate.timeIntervalSince(date) > allowedAge.rawValue {
            throw Error.expired
        }
    }
}
