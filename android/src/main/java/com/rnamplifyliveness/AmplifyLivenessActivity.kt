package com.rnamplifyliveness

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.material3.MaterialTheme
import com.amplifyframework.auth.AWSCredentials
import com.amplifyframework.auth.AWSCredentialsProvider
import com.amplifyframework.auth.AuthException
import com.amplifyframework.ui.liveness.ui.FaceLivenessDetector
import com.amplifyframework.ui.liveness.ui.LivenessColorScheme
import com.amplifyframework.core.Consumer

private class StaticCredentialsProvider(
  private val credentials: AWSCredentials
) : AWSCredentialsProvider<AWSCredentials> {
  override fun fetchAWSCredentials(
    onSuccess: Consumer<AWSCredentials>,
    onError: Consumer<AuthException>
  ) {
    onSuccess.accept(credentials)
  }
}

class AmplifyLivenessActivity : ComponentActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    val sessionId = intent.getStringExtra("sessionId")
    val region = intent.getStringExtra("region")
    val accessKeyId = intent.getStringExtra("accessKeyId")
    val secretAccessKey = intent.getStringExtra("secretAccessKey")
    val sessionToken = intent.getStringExtra("sessionToken")
    val expirationEpochSeconds =
      intent.getLongExtra("expirationEpochSeconds", (System.currentTimeMillis() / 1000L) + 300L)

    if (sessionId.isNullOrBlank() ||
      region.isNullOrBlank() ||
      accessKeyId.isNullOrBlank() ||
      secretAccessKey.isNullOrBlank() ||
      sessionToken.isNullOrBlank()) {
      finishWithError(
        "sessionId, region, accessKeyId, secretAccessKey and sessionToken are required"
      )
      return
    }

    val credentials = AWSCredentials.createAWSCredentials(
      accessKeyId,
      secretAccessKey,
      sessionToken,
      expirationEpochSeconds
    )
    if (credentials == null) {
      finishWithError("Failed to create AWS credentials")
      return
    }
    val credentialsProvider = StaticCredentialsProvider(credentials)

    setContent {
      MaterialTheme(colorScheme = LivenessColorScheme.default()) {
        FaceLivenessDetector(
          sessionId = sessionId,
          region = region,
          credentialsProvider = credentialsProvider,
          onComplete = {
            val resultIntent = Intent().apply {
              putExtra("sessionId", sessionId)
            }
            setResult(Activity.RESULT_OK, resultIntent)
            finish()
          },
          onError = { error ->
            finishWithError(error.message ?: "Liveness flow failed")
          }
        )
      }
    }
  }

  private fun finishWithError(errorMessage: String) {
    val resultIntent = Intent().apply {
      putExtra("errorMessage", errorMessage)
      putExtra("sessionId", intent.getStringExtra("sessionId"))
    }
    setResult(2, resultIntent)
    finish()
  }
}
