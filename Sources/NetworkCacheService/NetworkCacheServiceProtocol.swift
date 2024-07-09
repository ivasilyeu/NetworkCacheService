//
//  NetworkCacheServiceProtocol.swift
//

import Foundation

// MARK: - NetworkCacheServiceProtocol

public protocol NetworkCacheServiceProtocol: AnyObject, Sendable {

    /**
     Caches the item. Item must be Encodable to be cacheable, and Decodable in order to be able to be read back
     */
    func cacheItem<T>(_ item: T, with response: URLResponse, for url: URL, policies: NetworkCachePolicies) where T: Codable

    /**
     Reads an item that corresponds to the URL from the cache. The item must be Encodable to be cacheable, and Decodable in order to be able to be read back
     */
    func readItem<T>(for url: URL) -> T? where T: Codable

    /**
     Cleanup
     */
    func removeItem(for url: URL)

    /**
     Full cleanup
     */
    func removeAllItems()
}

// MARK: - Defaults

public extension NetworkCacheServiceProtocol {

    /**
     Caches the item with ``nonExpirable`` policy. Item must be Encodable to be cacheable, and Decodable in order to be able to be read back
     */
    func cacheItem<T>(_ item: T, with response: URLResponse, for url: URL) where T: Codable {

        cacheItem(item, with: response, for: url, policies: .nonExpirable)
    }

    /**
     Helper method to read cached items of an explicitly specified type
     */
    func readItem<T>(of: T.Type = T.self, for url: URL) -> T? where T: Codable {
        readItem(for: url)
    }
}
