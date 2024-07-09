import struct Foundation.TimeInterval

// MARK: - NetworkCacheAge

public struct NetworkCacheAge: RawRepresentable, Codable, Sendable {

    // MARK:

    public static let sixWeeks: Self = .init(rawValue: 6 * week.rawValue)

    public static let week: Self = .init(rawValue: 7 * day.rawValue)

    public static let day: Self = .init(rawValue: 24 * hour.rawValue)

    public static let hour: Self = .init(rawValue: 60 * 60)

    // MARK:

    public init(rawValue: TimeInterval) {
        self.rawValue = rawValue
    }

    public var rawValue: TimeInterval
}
