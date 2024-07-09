import XCTest
@testable import NetworkCacheService

final class NetworkCacheServiceTests: XCTestCase {

    let dependencies: NetworkCacheServiceFactoryProtocol = DependencyFactory()
    lazy var cache = dependencies.networkCacheService

    func testThatStringCacheUncacheWorks() throws {

        let item = "test"
        let url = URL(string: "https://google.com")! //URL(string: UUID().uuidString)!
        let mockedResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!

        cache.cacheItem(item,
                        with: mockedResponse,
                        for: url,
                        policies: NetworkCachePolicies(storage: .allowed, expiration: .age(.day)))

        let uncachedItem = cache.readItem(of: String.self, for: url)

        XCTAssertNotNil(uncachedItem, "a cached item must be uncacheable")
        guard let uncachedItem else { return }
        XCTAssertEqual(uncachedItem, item, "cached and uncached items must be equal")
    }
}





