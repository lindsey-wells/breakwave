import Flutter
import Foundation

final class BreakWavePrivacyBridge {
  static let channelName = "breakwave/privacy_auth"

  private static var activeBridge: BreakWavePrivacyBridge?

  private let channel: FlutterMethodChannel
  private let credentialStore: BreakWaveKeychainCredentialStore
  private let biometricAuthenticator: BreakWaveBiometricAuthenticator

  private init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: Self.channelName,
      binaryMessenger: messenger
    )
    credentialStore = BreakWaveKeychainCredentialStore()
    biometricAuthenticator = BreakWaveBiometricAuthenticator()

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result("error")
        return
      }
      self.handle(call, result: result)
    }
  }

  static func register(with messenger: FlutterBinaryMessenger) {
    activeBridge = BreakWavePrivacyBridge(messenger: messenger)
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "credentialStatus":
      do {
        result(try credentialStore.isConfigured() ? "configured" : "notConfigured")
      } catch {
        result("error")
      }

    case "configurePin":
      guard let pin = pinArgument(from: call.arguments) else {
        result("error")
        return
      }
      do {
        try credentialStore.configure(pin: pin)
        result("success")
      } catch {
        result("error")
      }

    case "verifyPin":
      guard let pin = pinArgument(from: call.arguments) else {
        result("failed")
        return
      }
      do {
        guard let verified = try credentialStore.verify(pin: pin) else {
          result("unavailable")
          return
        }
        result(verified ? "success" : "failed")
      } catch {
        result("error")
      }

    case "clearCredential":
      do {
        try credentialStore.clear()
        result("success")
      } catch {
        result("error")
      }

    case "biometricStatus":
      result(biometricAuthenticator.status())

    case "authenticateBiometric":
      do {
        guard try credentialStore.isConfigured() else {
          result("unavailable")
          return
        }
      } catch {
        result("error")
        return
      }
      biometricAuthenticator.authenticate { authResult in
        result(authResult)
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func pinArgument(from arguments: Any?) -> String? {
    guard
      let values = arguments as? [String: Any],
      let pin = values["pin"] as? String
    else {
      return nil
    }
    return pin
  }
}
