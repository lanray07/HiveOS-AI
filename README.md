# HiveOS AI

HiveOS AI is a SwiftUI iOS app scaffold for a premium AI-powered beekeeping intelligence platform.

Open `HiveOSAI.xcodeproj` in Xcode 15 or newer and run the `HiveOSAI` target on an iOS 17+ simulator or device.

## Included

- SwiftUI `NavigationStack` and tab architecture
- MVVM-style observable view models
- SwiftData local persistence
- Mock AI enabled by default with a `RemoteAIService` backend placeholder
- PhotosPicker and camera support
- Audio recording placeholder
- Local notifications
- StoreKit 2 subscription scaffolding and StoreKit config
- Swift Charts analytics
- Native PDF generation and share sheet
- WidgetKit and Apple Watch placeholder screens
- Agricultural disclaimer language throughout
- In-app multilingual layer for English, Spanish, French, German, Italian, and Portuguese
- Voice input for editable inspection, hive, apiary, and swarm sighting notes
- Swarm Alert Network for locally reporting swarm sightings and notifying nearby beekeepers with local notification scaffolding

## Backend Placeholder

`RemoteAIService` posts to:

```text
https://YOUR_BACKEND_URL.com/hiveos-ai
```

Never store API keys inside the app. Route model calls through a secure backend.

Remote AI requests include `languageCode` so your backend can return cautious insights in the selected app language.
