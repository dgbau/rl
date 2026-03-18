# Swift & iOS Development

<!-- category: template -->

## Overview

Patterns and best practices for Swift and iOS/iPadOS/macOS development — SwiftUI, UIKit, app architecture, data persistence, networking, and App Store deployment.
[FILL: What this app does, target platforms (iOS/iPadOS/macOS/watchOS/visionOS), minimum deployment target]

## Project Configuration

- Xcode version: [FILL: Xcode 16.x]
- Swift version: [FILL: Swift 6.x]
- Minimum deployment: [FILL: iOS 17 / iOS 18]
- Architecture: [FILL: SwiftUI-first / UIKit / hybrid]
- Package manager: [FILL: Swift Package Manager (SPM) / CocoaPods (legacy)]
- Scheme/targets: [FILL: App, widget extension, watch app, etc.]

## SwiftUI

### View composition
```swift
struct ContentView: View {
    @State private var items: [Item] = []

    var body: some View {
        NavigationStack {
            List(items) { item in
                NavigationLink(value: item) {
                    ItemRow(item: item)
                }
            }
            .navigationTitle("Items")
            .navigationDestination(for: Item.self) { item in
                ItemDetail(item: item)
            }
        }
    }
}
```

### View best practices
- Keep views small — extract subviews when `body` exceeds ~30 lines
- Use `@ViewBuilder` for conditional view composition
- Prefer `NavigationStack` + `navigationDestination` over `NavigationLink(destination:)` (deprecated pattern)
- Use `LazyVStack`/`LazyHStack` inside `ScrollView` for long lists (not `VStack`)
- Test views with `#Preview` macro — fast iteration without running the full app

### Property wrappers
| Wrapper | Purpose | Scope |
|---------|---------|-------|
| `@State` | Local value type state | Single view |
| `@Binding` | Two-way reference to parent's `@State` | Child view |
| `@StateObject` | Create and own an `ObservableObject` | View that creates the object |
| `@ObservedObject` | Observe an `ObservableObject` owned elsewhere | Child view |
| `@EnvironmentObject` | Shared object injected via `.environmentObject()` | Any descendant view |
| `@Environment(\.key)` | System values (colorScheme, dismiss, etc.) | Any view |
| `@AppStorage("key")` | UserDefaults-backed state | Persists across launches |
| `@SceneStorage("key")` | Per-scene state restoration | Persists across scene sessions |
| `@Query` | SwiftData model fetch (replaces `@FetchRequest`) | Views using SwiftData |

### Observation framework (iOS 17+)
```swift
@Observable
class ViewModel {
    var items: [Item] = []
    var isLoading = false

    func loadItems() async {
        isLoading = true
        items = await api.fetchItems()
        isLoading = false
    }
}

// In view — no wrapper needed, just reference:
struct ItemList: View {
    var viewModel: ViewModel

    var body: some View {
        List(viewModel.items) { item in
            Text(item.name)
        }
        .task { await viewModel.loadItems() }
    }
}
```

- Prefer `@Observable` (macro) over `ObservableObject` + `@Published` for new code (iOS 17+)
- `@Observable` tracks property access at the view level — more granular, fewer re-renders
- Use `.task {}` modifier for async work tied to view lifecycle

## UIKit (when needed)

### When to use UIKit over SwiftUI
- Complex collection view layouts (`UICollectionViewCompositionalLayout`)
- Custom gesture recognizers and hit testing
- Advanced text editing (`UITextView` with attributed strings)
- Camera/AR integrations requiring `UIViewController` lifecycle
- Legacy codebase migration — wrap UIKit in `UIViewRepresentable` / `UIViewControllerRepresentable`

### UIKit in SwiftUI
```swift
struct CameraView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ vc: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Handle captured image
        }
    }
}
```

## App Architecture

### Recommended patterns
| Pattern | Best For | Complexity |
|---------|----------|------------|
| **MVVM** | Most SwiftUI apps | Low-Medium |
| **TCA (Composable Architecture)** | Complex state, testability | Medium-High |
| **VIPER/Clean** | Large teams, strict separation | High |
| **MV (Model-View)** | Simple apps, Apple's direction | Low |

- [FILL: Architecture pattern used in this project]

### MVVM with SwiftUI
```
View (SwiftUI)          → displays state, sends actions
  ↕
ViewModel (@Observable) → business logic, transforms data
  ↕
Model / Service         → data access, networking, persistence
```

- ViewModels should be `@Observable` classes (iOS 17+) or `ObservableObject`
- Views never call networking/persistence directly — always through ViewModel
- Keep ViewModels testable: inject dependencies via protocols

### Project structure
```
[FILL: Adapt to project layout]
App/
  AppEntry.swift              # @main App struct
  ContentView.swift           # Root view / tab bar
Features/
  Auth/
    AuthView.swift
    AuthViewModel.swift
    AuthService.swift
  Home/
    HomeView.swift
    HomeViewModel.swift
Models/
  User.swift
  Item.swift
Services/
  APIClient.swift
  StorageService.swift
Extensions/
  View+Extensions.swift
  Date+Formatting.swift
Resources/
  Assets.xcassets
  Localizable.xcstrings
```

- Group by feature, not by type
- One file per type (view, view model, model)
- Extensions in dedicated files, grouped by extended type

## Data Persistence

### SwiftData (iOS 17+ — recommended)
```swift
@Model
class Item {
    var name: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var tags: [Tag]

    init(name: String) {
        self.name = name
        self.createdAt = .now
        self.tags = []
    }
}

// In App:
@main struct MyApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
            .modelContainer(for: [Item.self, Tag.self])
    }
}

// In View — query directly:
struct ItemList: View {
    @Query(sort: \Item.createdAt, order: .reverse) var items: [Item]
    @Environment(\.modelContext) var context

    func addItem() {
        context.insert(Item(name: "New"))
    }
}
```

### Other persistence options
| Option | Best For | Notes |
|--------|----------|-------|
| **SwiftData** | Structured app data | Built on Core Data, Swift-native API |
| **Core Data** | Legacy / complex migrations | Mature, powerful, verbose |
| **UserDefaults** | Small preferences, settings | Not for large/sensitive data |
| **Keychain** | Passwords, tokens, secrets | Use `Security` framework or wrapper library |
| **FileManager** | Documents, exports, caches | App sandbox directories |
| **CloudKit** | iCloud sync | Built-in with SwiftData via `ModelConfiguration` |

- [FILL: Persistence strategy used in this project]

## Networking

### Modern async networking
```swift
struct APIClient {
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    private let baseURL = URL(string: "https://api.example.com")!

    func fetch<T: Decodable>(_ path: String) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw APIError.badResponse
        }
        return try decoder.decode(T.self, from: data)
    }
}

// Usage in ViewModel:
func loadUsers() async {
    do {
        users = try await api.fetch("/users")
    } catch {
        errorMessage = error.localizedDescription
    }
}
```

- Always use `async/await` — avoid completion handlers in new code
- Decode with `Codable` — use `CodingKeys` for API field name mismatches
- Handle network errors gracefully — show user-facing error states, allow retry
- Use `URLCache` and `ETag`/`If-None-Match` for response caching
- [FILL: API base URL, auth headers, specific endpoints]

## Concurrency (Swift Concurrency)

### Structured concurrency
```swift
// Sequential
let user = try await fetchUser(id: 1)
let posts = try await fetchPosts(for: user)

// Parallel
async let user = fetchUser(id: 1)
async let settings = fetchSettings()
let (u, s) = try await (user, settings)

// Task group for dynamic parallelism
let images = try await withThrowingTaskGroup(of: UIImage.self) { group in
    for url in urls {
        group.addTask { try await downloadImage(url) }
    }
    return try await group.reduce(into: []) { $0.append($1) }
}
```

### Actors
```swift
actor ImageCache {
    private var cache: [URL: UIImage] = [:]

    func image(for url: URL) -> UIImage? { cache[url] }
    func store(_ image: UIImage, for url: URL) { cache[url] = image }
}
```

- Use `actor` for shared mutable state — compiler-enforced data race safety
- Mark `@MainActor` on ViewModels and any UI-updating code
- Use `Task { }` to bridge from synchronous to async contexts
- Use `Task.detached` sparingly — only when you explicitly don't want to inherit actor context
- Swift 6 strict concurrency: enable `SWIFT_STRICT_CONCURRENCY=complete` to catch data races at compile time

## Navigation

### NavigationStack (iOS 16+)
```swift
@Observable class Router {
    var path = NavigationPath()

    func navigate(to destination: Destination) {
        path.append(destination)
    }
    func popToRoot() {
        path = NavigationPath()
    }
}

enum Destination: Hashable {
    case detail(Item)
    case settings
    case profile(User)
}

struct RootView: View {
    var router: Router

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: Destination.self) { dest in
                    switch dest {
                    case .detail(let item): ItemDetail(item: item)
                    case .settings: SettingsView()
                    case .profile(let user): ProfileView(user: user)
                    }
                }
        }
    }
}
```

- Use a centralized `Router` for programmatic navigation
- `TabView` for top-level sections, `NavigationStack` within each tab
- Deep links: handle via `.onOpenURL` modifier and route through `Router`
- [FILL: Navigation structure — tabs, split view, sidebar]

## Testing

### Unit tests
```swift
@Test func viewModelLoadsItems() async {
    let mockAPI = MockAPIClient(items: [.sample])
    let vm = ItemViewModel(api: mockAPI)

    await vm.loadItems()

    #expect(vm.items.count == 1)
    #expect(vm.items.first?.name == "Sample")
}
```

- Use Swift Testing framework (`@Test`, `#expect`) for new tests (Xcode 16+)
- XCTest still supported — `XCTestCase`, `XCTAssertEqual`
- Inject dependencies via protocols for testable ViewModels
- Test business logic, not SwiftUI view rendering
- Use `@MainActor` on tests that touch `@MainActor`-isolated types

### UI tests
- Use `XCUIApplication` for integration/E2E tests
- Set `accessibilityIdentifier` on views for stable test selectors
- Keep UI tests focused on critical flows — they're slow
- [FILL: Test runner configuration, CI setup]

## App Lifecycle & System Integration

### Key modifiers
```swift
.onAppear { }                    // View appeared
.task { }                        // Async work tied to view lifecycle
.onChange(of: value) { }         // React to state changes
.onReceive(publisher) { }       // Combine publisher
.onOpenURL { url in }           // Deep links / universal links
.handlesExternalEvents(matching:) // macOS window routing
```

### Background tasks
- `BGAppRefreshTask`: Periodic background fetch (15-30 min minimum interval)
- `BGProcessingTask`: Long-running background work (overnight, while charging)
- Register in `Info.plist` under `BGTaskSchedulerPermittedIdentifiers`
- Always test background tasks on device — simulator behavior differs

### Push notifications
```swift
UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
    if granted { DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() } }
}
// Handle token in AppDelegate: application(_:didRegisterForRemoteNotificationsWithDeviceToken:)
```

- APNs (Apple Push Notification service) requires a paid developer account
- Use `UserNotifications` framework for local and remote notification handling
- Rich notifications: notification service extension for media attachments
- [FILL: Push notification provider — Firebase, OneSignal, custom APNs]

## Performance

- **Instruments**: Profile with Time Profiler, Allocations, Leaks, Core Animation
- **Launch time**: Target <400ms warm launch; defer non-critical work with `Task.detached`
- **Memory**: Monitor with Instruments Allocations; watch for retain cycles in closures (`[weak self]`)
- **Lists**: Use `List` or `LazyVStack` — never `VStack` for 50+ items
- **Images**: Use `AsyncImage` for URL-loaded images, cache with `URLCache` or third-party (Kingfisher, Nuke)
- **Animations**: Keep at 60fps; use `withAnimation` and avoid layout recalculation during animation

## Accessibility

- Set `.accessibilityLabel()` on all interactive elements without visible text
- Use `.accessibilityValue()` for dynamic state (slider position, toggle state)
- Group related elements: `.accessibilityElement(children: .combine)`
- Test with VoiceOver on device — Xcode Accessibility Inspector catches basics only
- Support Dynamic Type: use system fonts or `.scaledFont`, test at all text sizes
- Minimum touch target: 44x44 points

## App Store Deployment

- **Signing**: Automatic signing in Xcode, or manual with provisioning profiles for CI
- **TestFlight**: Internal testing (up to 100), external testing (up to 10,000) — requires App Review
- **CI/CD**: Xcode Cloud (Apple-native), Fastlane (`gym` for build, `pilot` for TestFlight, `deliver` for App Store)
- **App Review guidelines**: No private API usage, clear privacy policy, complete App Privacy labels
- **Privacy**: `NSCameraUsageDescription`, `NSLocationWhenInUseUsageDescription`, etc. in `Info.plist`
- [FILL: Distribution method — App Store, TestFlight, Enterprise, Ad Hoc]

## Key Constraints

- [FILL: Minimum iOS version and device support (iPhone, iPad, both)]
- [FILL: Offline requirements — what works without network]
- [FILL: Privacy/compliance requirements — GDPR, HIPAA, COPPA]
- [FILL: Performance targets — launch time, scroll FPS, memory budget]
- Always support current and previous major iOS version (e.g., iOS 17 + 18)
- App size: keep under 200MB for cellular download without WiFi prompt

## Where to Look

- Apple Developer docs: https://developer.apple.com/documentation/
- Swift language: https://docs.swift.org/swift-book/
- Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/
- SwiftUI tutorials: https://developer.apple.com/tutorials/swiftui
- Swift Package Index: https://swiftpackageindex.com/
- [FILL: Project-specific documentation and design specs]

## Common Pitfalls

- Retain cycles in closures — always use `[weak self]` in escaping closures on class instances
- Updating `@State` from background thread — use `@MainActor` or `DispatchQueue.main`
- Forgetting `Identifiable` conformance for `List`/`ForEach` — causes cryptic SwiftUI errors
- `NavigationLink` re-creating destination views — use value-based `navigationDestination` instead
- Core Data / SwiftData migrations failing silently — test migrations on real data before shipping
- Auto Layout conflicts in UIKit — set `translatesAutoresizingMaskIntoConstraints = false`
- [FILL: Project-specific gotchas encountered]
