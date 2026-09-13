import Foundation
import LocalAuthentication

final class BreakWaveBiometricAuthenticator {
  func status() -> String {
    let context = LAContext()
    var error: NSError?

    guard context.canEvaluatePolicy(
      .deviceOwnerAuthenticationWithBiometrics,
      error: &error
    ) else {
      return availabilityStatus(for: error)
    }

    if context.biometryType == .faceID && !hasFaceIDUsageDescription {
      return "notAvailable"
    }

    return "available"
  }

  func authenticate(completion: @escaping (String) -> Void) {
    let context = LAContext()
    context.localizedCancelTitle = "Cancel"

    var error: NSError?
    guard context.canEvaluatePolicy(
      .deviceOwnerAuthenticationWithBiometrics,
      error: &error
    ) else {
      completion(authResultForUnavailable(error))
      return
    }

    if context.biometryType == .faceID && !hasFaceIDUsageDescription {
      completion("unavailable")
      return
    }

    context.evaluatePolicy(
      .deviceOwnerAuthenticationWithBiometrics,
      localizedReason: "Unlock your private BreakWave information."
    ) { success, evaluationError in
      let value = success
        ? "success"
        : self.authResult(for: evaluationError as NSError?)

      DispatchQueue.main.async {
        completion(value)
      }
    }
  }

  private var hasFaceIDUsageDescription: Bool {
    guard let value = Bundle.main.object(
      forInfoDictionaryKey: "NSFaceIDUsageDescription"
    ) as? String else {
      return false
    }
    return !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  private func availabilityStatus(for error: NSError?) -> String {
    guard let code = laErrorCode(error) else {
      return "unknown"
    }

    switch code {
    case .biometryNotEnrolled:
      return "notEnrolled"
    case .biometryNotAvailable:
      return "notAvailable"
    case .biometryLockout:
      return "lockedOut"
    default:
      return "unknown"
    }
  }

  private func authResultForUnavailable(_ error: NSError?) -> String {
    guard let code = laErrorCode(error) else {
      return "unavailable"
    }

    switch code {
    case .userCancel, .systemCancel, .appCancel, .userFallback:
      return "cancelled"
    case .authenticationFailed:
      return "failed"
    case .biometryNotAvailable, .biometryNotEnrolled, .biometryLockout:
      return "unavailable"
    default:
      return "unavailable"
    }
  }

  private func authResult(for error: NSError?) -> String {
    guard let code = laErrorCode(error) else {
      return "error"
    }

    switch code {
    case .userCancel, .systemCancel, .appCancel, .userFallback:
      return "cancelled"
    case .authenticationFailed:
      return "failed"
    case .biometryNotAvailable, .biometryNotEnrolled, .biometryLockout:
      return "unavailable"
    default:
      return "error"
    }
  }

  private func laErrorCode(_ error: NSError?) -> LAError.Code? {
    guard let error, error.domain == LAError.errorDomain else {
      return nil
    }
    return LAError.Code(rawValue: error.code)
  }
}
