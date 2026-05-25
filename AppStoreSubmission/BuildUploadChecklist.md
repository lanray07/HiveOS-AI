# HiveOS AI Build and Upload Checklist

Use this checklist on a Mac with Xcode installed.

## 1. Open Project

- Open `HiveOSAI.xcodeproj`
- Select scheme: `HiveOSAI`
- Select target: `HiveOSAI`

## 2. Signing

- Go to **Signing & Capabilities**
- Enable **Automatically manage signing**
- Select the Apple Developer team for Olanrewaju Bankole
- Confirm the bundle identifier matches the App Store Connect record

Current project bundle identifier:

```text
com.hiveosai.app
```

If App Store Connect uses a different bundle identifier, update the Xcode target before archiving.

## 3. Version

Current project values:

```text
Marketing Version: 1.0
Build Number: 1
Deployment Target: iOS 17.0
Devices: iPhone and iPad
```

If App Store Connect already has build `1`, increment the build number to `2`.

## 4. Archive

In Xcode:

- Select **Any iOS Device (arm64)** or a connected iPhone
- Choose **Product > Archive**
- Wait for the archive to appear in Organizer

Command-line equivalent on a Mac:

```sh
xcodebuild archive \
  -project "HiveOSAI.xcodeproj" \
  -scheme "HiveOSAI" \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "build/HiveOSAI.xcarchive"
```

## 5. Upload

In Organizer:

- Select the archive
- Click **Distribute App**
- Choose **App Store Connect**
- Choose **Upload**
- Include symbols
- Let Xcode manage signing
- Upload

Command-line export/upload can also use `Tools/ExportOptions-AppStore.plist` after signing is configured.

## GitHub Actions Build

The repository includes `.github/workflows/ios-build.yml`.

On every push to `main`, GitHub Actions runs a simulator compile on a macOS runner.

For App Store Connect upload through GitHub:

1. Go to **GitHub > Repository > Settings > Secrets and variables > Actions**
2. Add these repository secrets:

```text
APPLE_TEAM_ID
ASC_KEY_ID
ASC_ISSUER_ID
ASC_API_KEY_BASE64
```

`ASC_API_KEY_BASE64` is the App Store Connect `.p8` API key encoded as base64.

On macOS:

```sh
base64 -i AuthKey_XXXXXXXXXX.p8
```

On Windows PowerShell:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("AuthKey_XXXXXXXXXX.p8"))
```

Then run **Actions > iOS Build > Run workflow**, enable **Archive and upload to App Store Connect**, and optionally enter a build number.

## 6. App Store Connect

After processing finishes:

- Go to **iOS App Version 1.0 > Build**
- Select the uploaded build
- Add the first subscriptions under **In-App Purchases and Subscriptions**
- Save
- Submit for review

## Known Notes

- Mock AI is enabled by default.
- The app does not store API keys.
- Subscription product IDs are scaffolded in `HiveOSAI/Resources/StoreKit.storekit`.
- App Store assets are in `AppStoreSubmission/UploadNow`.
