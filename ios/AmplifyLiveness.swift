import Foundation
import React
import UIKit

#if canImport(FaceLiveness)
import FaceLiveness
import SwiftUI
import Amplify
import AWSPluginsCore
import AWSClientRuntime

struct RNemporaryCredentials: AWSTemporaryCredentials {
  let accessKeyId: String
  let secretAccessKey: String
  let sessionToken: String
  let expiration: Date
}

class StaticAWSCredentialsProvider: AWSCredentialsProvider {
  let credentials: AWSTemporaryCredentials
  init(credentials: AWSTemporaryCredentials) {
    self.credentials = credentials
  }
  func fetchAWSCredentials() async throws -> AWSCredentials {
    return credentials
  }
}

struct LivenessWrapperView: View {
  let sessionID: String
  let region: String
  let credentialsProvider: AWSCredentialsProvider
  let onComplete: () -> Void
  let onError: (String) -> Void
  
  @State private var isPresented = true
  
  var body: some View {
    FaceLivenessDetectorView(
      sessionID: sessionID,
      credentialsProvider: credentialsProvider,
      region: region,
      isPresented: $isPresented,
      onCompletion: { result in
        switch result {
        case .success:
          onComplete()
        case .failure(let error):
          onError(error.localizedDescription)
        }
      }
    )
  }
}
#endif

@objc(AmplifyLiveness)
class AmplifyLiveness: NSObject {
  @objc
  static func requiresMainQueueSetup() -> Bool {
    true
  }

  @objc(startLiveness:resolver:rejecter:)
  func startLiveness(_ input: NSDictionary,
                     resolver resolve: @escaping RCTPromiseResolveBlock,
                     rejecter reject: @escaping RCTPromiseRejectBlock) {
    guard let sessionId = input["sessionId"] as? String,
          let region = input["region"] as? String,
          let accessKey = input["accessKeyId"] as? String,
          let secret = input["secretAccessKey"] as? String,
          let sessionToken = input["sessionToken"] as? String else {
      reject("E_INPUT", "sessionId, region, and aws credentials are required.", nil)
      return
    }

    let defaultExp = Date().timeIntervalSince1970 + 300
    let expSeconds = (input["expirationEpochSeconds"] as? NSNumber)?.doubleValue ?? defaultExp
    let expiration = Date(timeIntervalSince1970: expSeconds)

    DispatchQueue.main.async {
      #if canImport(FaceLiveness)
      // Robust way to find the root view controller in Scene-based apps
      var rootViewController: UIViewController?
      if #available(iOS 13.0, *) {
          rootViewController = UIApplication.shared.connectedScenes
              .filter { $0.activationState == .foregroundActive }
              .compactMap { $0 as? UIWindowScene }
              .first?.windows
              .filter { $0.isKeyWindow }
              .first?.rootViewController
      }
      
      // Fallback
      if rootViewController == nil {
          rootViewController = UIApplication.shared.delegate?.window??.rootViewController
      }

      guard let root = rootViewController else {
        reject("E_NO_ROOT", "Unable to find root view controller.", nil)
        return
      }

      let credentials = RNemporaryCredentials(
        accessKeyId: accessKey,
        secretAccessKey: secret,
        sessionToken: sessionToken,
        expiration: expiration
      )
      let provider = StaticAWSCredentialsProvider(credentials: credentials)

      let hosting = UIHostingController(
        rootView: LivenessWrapperView(
          sessionID: sessionId,
          region: region,
          credentialsProvider: provider,
          onComplete: {
            DispatchQueue.main.async {
              resolve([
                "sessionId": sessionId,
                "status": "completed"
              ])
              root.dismiss(animated: true)
            }
          },
          onError: { error in
            DispatchQueue.main.async {
              resolve([
                "sessionId": sessionId,
                "status": "error",
                "errorMessage": error
              ])
              root.dismiss(animated: true)
            }
          }
        )
      )

      hosting.modalPresentationStyle = .fullScreen
      root.present(hosting, animated: true)
      #else
      reject(
        "E_IOS_DEPENDENCY",
        "FaceLiveness Swift package not found. Add https://github.com/aws-amplify/amplify-ui-swift-liveness and link FaceLiveness product in your iOS app target.",
        nil
      )
      #endif
    }
  }
}
