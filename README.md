# react-native-amplify-liveness

React Native native bridge for **Amplify UI Face Liveness**.

- Android dependency used by this package: `com.amplifyframework.ui:liveness:1.5.0`
- React Native baseline: `0.76`
- Intended compatibility: `0.73+`

This package launches native Amplify UI liveness and resolves to JS when the flow completes, errors, or is cancelled.

## Install

```bash
npm install react-native-amplify-liveness
```

For iOS:

```bash
cd ios && pod install
```

## API

```ts
import {startLiveness, requestCameraPermission} from 'react-native-amplify-liveness';
```

### `startLiveness({ sessionId, region, accessKeyId, secretAccessKey, sessionToken, expirationEpochSeconds? })`

Starts native Amplify UI liveness flow.

Returns:

```ts
type StartLivenessInput = {
  sessionId: string;
  region: string;
  accessKeyId: string;
  secretAccessKey: string;
  sessionToken: string;
  expirationEpochSeconds?: number; // defaults to now + 5 minutes
}

type LivenessResult = {
  sessionId: string;
  status: 'completed' | 'error' | 'cancelled';
  errorMessage?: string;
}
```

### `requestCameraPermission()`

Requests Android camera permission (iOS handled by native UI and Info.plist usage string).

## Required Native Setup

This module utilizes a dynamic credential provider bridge. You **do not** need to install or statically configure the overarching Amplify Auth framework (`amplifyconfiguration.json`) inside your host app.
Instead, your backend should dynamically fetch short-lived STS temporary credentials and provide them to the JS `startLiveness` function.

### Android

Android utilizes standard React Native autolinking. No special dependency configuration is required beyond standard Android app requirements.

1.  Ensure your `android/build.gradle` `minSdkVersion` is at least `24`.
2.  Ensure you have the camera permissions in your `android/app/src/main/AndroidManifest.xml`:
    ```xml
    <uses-permission android:name="android.permission.CAMERA" />
    ```

### iOS

Amplify UI Liveness for iOS is distributed by AWS exclusively via **Swift Package Manager**, which historically struggles to map natively through CocoaPods. To avoid fatal compiling module map conflicts, this package utilizes a robust **"Local Bridge" implementation strategy** for iOS. CocoaPods autolinking is completely disabled.

Instead of fighting `cocoapods-spm` in your `Podfile`, developers will link the SPM framework safely through Xcode.

#### Setup Steps

Because React Native autolinking is bypassed for iOS, you must inject the AWS SPM dependency and the swift bridge files into your application manually once.

1.  **Add `FaceLiveness` via Xcode Swift Package Manager**:
    *   Open your main application workspace (e.g. `ios/MyApp.xcworkspace`).
    *   Navigate in the top menu to: `File > Add Package Dependencies...`
    *   In the search bar, paste: `https://github.com/aws-amplify/amplify-ui-swift-liveness`
    *   Set the Dependency Rule to `Up to Next Minor Version` and the version to `1.4.4`.
    *   Click Add Package, check exactly the **FaceLiveness** product, and ensure it sets to your main App target (`MyApp`).

2.  **Add the Bridge Files**:
    *   From the Xcode Project Navigator, right-click on your App Target folder (the topmost yellow folder below your workspace, e.g. `MyApp`) and select `Add Files to "MyApp"...`.
    *   Navigate to your project's `node_modules/react-native-amplify-liveness/ios/` directory on your machine. Select **both** `AmplifyLiveness.swift` and `AmplifyLiveness.m`.
    *   Make sure you tick **"Copy items if needed"** so the files become a static member of your codebase. Make sure your `MyApp` target is checked at the bottom.

*(If Xcode prompts you to create a bridging header during this drag-and-drop process, click **Create Bridging Header**).*

3.  **Update `Info.plist`**:
    You must add the camera permissions usage description to your app's `Info.plist` before running:
    ```xml
    <key>NSCameraUsageDescription</key>
    <string>Your app requires camera access for liveness detection.</string>
    ```

## Example

See `example/App.tsx` for a minimal usage flow.
