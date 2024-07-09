//
//  DependencyFactory.swift
//

import Foundation

// MARK: - DependencyFactory

public final class DependencyFactory {

    public init() {}

    public func resetAll() {

        networkCacheService.removeAllItems()
    }
    
    public private(set) lazy var networkCacheService: NetworkCacheServiceProtocol = NetworkCacheService()
}

// MARK: - NetworkCacheServiceFactoryProtocol

extension DependencyFactory: NetworkCacheServiceFactoryProtocol {}
