//
//  NetworkCachePolicies.swift
//

import Foundation

// MARK: - NetworkCachePolicies

public struct NetworkCachePolicies {

    static let nonExpirable: Self = .init(storage: .allowed, expiration: .nonExpirable)

    static let inMemoryOnlyNonExpirable: Self = .init(storage: .allowedInMemoryOnly, expiration: .nonExpirable)

    public init(storage: StoragePolicy, expiration: ExpirationPolicy) {
        self.storage = storage
        self.expiration = expiration
    }

    // MARK:

    public enum StoragePolicy {

        case allowed

        case allowedInMemoryOnly

        var foundation: URLCache.StoragePolicy {
            switch self {
            case .allowed:
                return .allowed
            case .allowedInMemoryOnly:
                return .allowedInMemoryOnly
            }
        }
    }

    public var storage: StoragePolicy

    public enum ExpirationPolicy: Codable {

        case nonExpirable

        case age(NetworkCacheAge)
    }

    public var expiration: ExpirationPolicy
}
