import CommonCrypto
import Foundation
import Security

struct BreakWavePinVerificationRecord: Codable {
  let schemaVersion: Int
  let kdf: String
  let iterations: Int
  let salt: Data
  let verifier: Data
}

final class BreakWavePinVerifier {
  enum VerifierError: Error {
    case invalidPin
    case invalidRecord
    case randomFailure(OSStatus)
    case derivationFailure(Int32)
  }

  private static let schemaVersion = 1
  private static let kdfName = "pbkdf2-hmac-sha256"
  private static let saltLength = 16
  private static let verifierLength = 32

  // Provisional only. IOS-G3 must benchmark the oldest supported physical
  // iPhone and may raise this value before production credential enrollment.
  private static let provisionalIterations = 200_000

  func makeRecord(pin: String) throws -> BreakWavePinVerificationRecord {
    guard isValidPin(pin) else {
      throw VerifierError.invalidPin
    }

    let salt = try randomBytes(count: Self.saltLength)
    let derived = try derive(
      pin: pin,
      salt: salt,
      iterations: Self.provisionalIterations
    )

    return BreakWavePinVerificationRecord(
      schemaVersion: Self.schemaVersion,
      kdf: Self.kdfName,
      iterations: Self.provisionalIterations,
      salt: salt,
      verifier: derived
    )
  }

  func verify(
    pin: String,
    record: BreakWavePinVerificationRecord
  ) throws -> Bool {
    guard isValidPin(pin) else {
      return false
    }
    guard
      record.schemaVersion == Self.schemaVersion,
      record.kdf == Self.kdfName,
      record.iterations > 0,
      record.salt.count >= Self.saltLength,
      record.verifier.count == Self.verifierLength
    else {
      throw VerifierError.invalidRecord
    }

    let candidate = try derive(
      pin: pin,
      salt: record.salt,
      iterations: record.iterations
    )
    return constantTimeEqual(candidate, record.verifier)
  }

  private func isValidPin(_ pin: String) -> Bool {
    let bytes = Array(pin.utf8)
    return bytes.count == 6 && bytes.allSatisfy { byte in
      byte >= 48 && byte <= 57
    }
  }

  private func randomBytes(count: Int) throws -> Data {
    var bytes = [UInt8](repeating: 0, count: count)
    let status = bytes.withUnsafeMutableBytes { buffer in
      guard let address = buffer.baseAddress else {
        return errSecParam
      }
      return SecRandomCopyBytes(kSecRandomDefault, count, address)
    }
    guard status == errSecSuccess else {
      throw VerifierError.randomFailure(status)
    }
    return Data(bytes)
  }

  private func derive(
    pin: String,
    salt: Data,
    iterations: Int
  ) throws -> Data {
    var output = [UInt8](
      repeating: 0,
      count: Self.verifierLength
    )
    let passwordLength = pin.utf8.count

    let status: Int32 = pin.withCString { passwordPointer in
      salt.withUnsafeBytes { saltBuffer in
        guard let saltAddress = saltBuffer
          .bindMemory(to: UInt8.self)
          .baseAddress else {
          return Int32(kCCParamError)
        }

        return output.withUnsafeMutableBufferPointer { outputBuffer in
          guard let outputAddress = outputBuffer.baseAddress else {
            return Int32(kCCParamError)
          }

          return CCKeyDerivationPBKDF(
            CCPBKDFAlgorithm(kCCPBKDF2),
            passwordPointer,
            passwordLength,
            saltAddress,
            salt.count,
            CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
            UInt32(iterations),
            outputAddress,
            outputBuffer.count
          )
        }
      }
    }

    guard status == kCCSuccess else {
      throw VerifierError.derivationFailure(status)
    }
    return Data(output)
  }

  private func constantTimeEqual(_ lhs: Data, _ rhs: Data) -> Bool {
    guard lhs.count == rhs.count else {
      return false
    }

    let left = [UInt8](lhs)
    let right = [UInt8](rhs)
    var difference: UInt8 = 0

    for index in left.indices {
      difference |= left[index] ^ right[index]
    }
    return difference == 0
  }
}
