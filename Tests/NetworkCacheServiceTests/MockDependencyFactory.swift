//
//  MockDependencyFactory.swift
//

import NetworkCacheService

// MARK: - NetworkCacheServiceFactoryProtocol

extension MockDependencyFactory: NetworkCacheServiceFactoryProtocol {}

// MARK: - MockDependencyFactory

public final class MockDependencyFactory {

    public init() {}

    public func resetAll() {

        networkCacheService.removeAllItems()
    }
    
    public private(set) lazy var networkCacheService: NetworkCacheServiceProtocol = NetworkCacheService()
}
