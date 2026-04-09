package com.rnamplifyliveness;

import android.app.Activity;
import android.content.Intent;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;

public class AmplifyLivenessModule extends ReactContextBaseJavaModule {
  private static final int REQUEST_CODE_LIVENESS = 42179;
  private Promise pendingPromise;

  private final ActivityEventListener activityEventListener = new BaseActivityEventListener() {
    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
      if (requestCode != REQUEST_CODE_LIVENESS || pendingPromise == null) {
        return;
      }

      WritableMap map = Arguments.createMap();
      map.putString("sessionId", data != null ? data.getStringExtra("sessionId") : null);

      if (resultCode == Activity.RESULT_OK) {
        map.putString("status", "completed");
      } else if (resultCode == Activity.RESULT_CANCELED) {
        map.putString("status", "cancelled");
      } else {
        map.putString("status", "error");
      }

      if (data != null && data.hasExtra("errorMessage")) {
        map.putString("errorMessage", data.getStringExtra("errorMessage"));
      }

      pendingPromise.resolve(map);
      pendingPromise = null;
    }
  };

  public AmplifyLivenessModule(ReactApplicationContext reactContext) {
    super(reactContext);
    reactContext.addActivityEventListener(activityEventListener);
  }

  @NonNull
  @Override
  public String getName() {
    return "AmplifyLiveness";
  }

  @ReactMethod
  public void startLiveness(ReadableMap input, Promise promise) {
    Activity activity = getCurrentActivity();
    if (activity == null) {
      promise.reject("E_NO_ACTIVITY", "No active Activity found.");
      return;
    }

    if (pendingPromise != null) {
      promise.reject("E_BUSY", "Liveness flow already running.");
      return;
    }

    String sessionId = input.hasKey("sessionId") ? input.getString("sessionId") : null;
    String region = input.hasKey("region") ? input.getString("region") : null;
    String accessKeyId = input.hasKey("accessKeyId") ? input.getString("accessKeyId") : null;
    String secretAccessKey = input.hasKey("secretAccessKey") ? input.getString("secretAccessKey") : null;
    String sessionToken = input.hasKey("sessionToken") ? input.getString("sessionToken") : null;
    long expirationEpochSeconds = input.hasKey("expirationEpochSeconds")
      ? (long) input.getDouble("expirationEpochSeconds")
      : (System.currentTimeMillis() / 1000L) + 300L;

    if (sessionId == null || region == null || accessKeyId == null || secretAccessKey == null || sessionToken == null) {
      promise.reject("E_INPUT", "sessionId, region, accessKeyId, secretAccessKey and sessionToken are required.");
      return;
    }

    pendingPromise = promise;

    Intent intent = new Intent(activity, AmplifyLivenessActivity.class);
    intent.putExtra("sessionId", sessionId);
    intent.putExtra("region", region);
    intent.putExtra("accessKeyId", accessKeyId);
    intent.putExtra("secretAccessKey", secretAccessKey);
    intent.putExtra("sessionToken", sessionToken);
    intent.putExtra("expirationEpochSeconds", expirationEpochSeconds);
    activity.startActivityForResult(intent, REQUEST_CODE_LIVENESS);
  }
}
