`NetworkCacheService` is a simple URL load caching service that allows to directly cache responses without having to rely on predetermined URLSession caching strategies.

##Features

- Expiration policies support
- Disk and memory storage
- Full thread safety

##Usage

###Caching of network response models:

```swift
URLSession.shared.dataTask(with: url) { [cacheService] data, response, error in
    guard let response, let data else {
        return
    }

    do {
        let networkModel = try JSONDecoder().decode(ResponseNetworkModel.self, from: data)

        cacheService.cacheItem(networkModel, with: response, for: url, policies: .nonExpirable)
    }
    catch {
    }
}.resume()
```

###Reading of previously cached models:

```swift
let modelOrNil = cacheService.readItem(of: ResponseNetworkModel.self, for: url)
```

## Integration

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

Use Swift Package Manager and add dependency to `Package.swift` file.

```swift
  dependencies: [
    .package(url: "https://github.com/ivasilyeu/NetworkCacheService.git", .upToNextMajor(from: "1.0.0"))
  ]
```

Alternatively, in Xcode select `File > Add Package Dependencies…` and add NetworkCacheService repository URL:

```
https://github.com/ivasilyeu/NetworkCacheService.git
```
