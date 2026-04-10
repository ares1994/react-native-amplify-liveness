# react-native-amplify-liveness

React Native bridge for **Amplify UI Face Liveness**.

- **Android SDK**: `com.amplifyframework.ui:liveness:1.5.0`
- **iOS SDK**: `AmplifyUI Liveness` (via SPM)
- **Compatibility**: React Native 0.73+

This package launches the native Amplify UI liveness flows and resolves as a Promise to Javascript upon completion.

## 1. Installation

```bash
npm install react-native-amplify-liveness
# or
yarn add react-native-amplify-liveness
```

## 2. API Usage

```typescript
import { startLiveness, requestCameraPermission } from 'react-native-amplify-liveness';

const runVerification = async () => {
  // 1. Request Camera Permission (Android)
  const hasPermission = await requestCameraPermission();
  if (!hasPermission) return;

  // 2. Start Liveness
  try {
    const result = await startLiveness({
      sessionId: "YOUR_SESSION_ID",
      region: "us-east-1",
      accessKeyId: "ASIA...",
      secretAccessKey: "...",
      sessionToken: "...",
    });

    if (result.status === 'completed') {
      console.log("Verified!");
    }
  } catch (error) {
    console.error("Liveness failed", error);
  }
};
```

---

## 3. Required Native Setup (iOS)

> [!IMPORTANT]
> The AWS FaceLiveness SDK is distributed exclusively via **Swift Package Manager (SPM)**. To avoid complex linkage conflicts between CocoaPods and SPM, this package uses a **"Local Bridge"** strategy for iOS. Standard autolinking is disabled.

### Step 1: Verify Autolink Status
In your project root, ensure you have a `react-native.config.js` file with the following configuration:

```javascript
module.exports = {
  dependencies: {
    'react-native-amplify-liveness': {
      platforms: {
        ios: null, // This disables CocoaPods autolinking for this package
      },
    },
  },
};
```

### Step 2: Add SPM Dependency in Xcode
1. Open `ios/YourProject.xcworkspace` in Xcode.
2. Select your project in the Project Navigator, then select your **Main App Target**.
3. Go to **File > Add Package Dependencies...**.
4. Search for: `https://github.com/aws-amplify/amplify-ui-swift-liveness`.
5. Set the version rule to **Exact Version: 1.4.4**.
6. Check the **FaceLiveness** product and add it to your **Main App Target**.

### Step 3: Inject the Bridge Files
1. In Xcode, right-click your App Target folder and select **Add Files to "YourApp"...**.
2. Navigate to `node_modules/react-native-amplify-liveness/ios/`.
3. Select **both** `AmplifyLiveness.swift` and `AmplifyLiveness.m`.
4. **Crucial**: Ensure "Copy items if needed" is **checked** and your main target is selected.
5. If Xcode asks to create a **Bridging Header**, click **Create Bridging Header**.

### Step 4: Update `Info.plist`
Add the camera usage description to `ios/YourApp/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app requires camera access for identity verification.</string>
```

---

## 4. Required Native Setup (Android)

1. **Permissions**: Add the following to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.CAMERA" />
   ```
2. **Min SDK**: Ensure `minSdkVersion` is at least **24** in `android/build.gradle`.

---

## Example Project
A fully configured example can be found in the `example/` directory.
