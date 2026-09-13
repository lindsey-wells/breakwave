import Foundation
import Security

final class BreakWaveKeychainCredentialStore {
  enum StoreError: Error {
    case keychain(OSStatus)
    case invalidRecord
  }

  static let service = "com.breakwaveapp.breakwave.privacy-lock"
  private static let account = "pin-verifier-v1"

  private let verifier = BreakWavePinVerifier()

  func isConfigured() throws -> Bool {
    let status = SecItemCopyMatching(baseQuery() as CFDictionary, nil)
    switch status {
    case errSecSuccess:
      return true
    case errSecItemNotFound:
      return false
    default:
      throw StoreError.keychain(status)
    }
  }

  func configure(pin: String) throws {
    let record = try verifier.makeRecord(pin: pin)
    let data = try JSONEncoder().encode(record)
    try write(data: data)
  }

  func verify(pin: String) throws -> Bool? {
    guard let data = try readData() else {
      return nil
    }

    let record: BreakWavePinVerificationRecord
    do {
      record = try JSONDecoder().decode(
        BreakWavePinVerificationRecord.self,
        from: data
      )
    } catch {
      throw StoreError.invalidRecord
    }

    return try verifier.verify(pin: pin, record: record)
  }

  func clear() throws {
    let status = SecItemDelete(baseQuery() as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw StoreError.keychain(status)
    }
  }

  private func readData() throws -> Data? {
    var query = baseQuery()
    query[kSecReturnData as String] = true
    query[kSecMatchLimit as String] = kSecMatchLimitOne

    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)

    switch status {
    case errSecSuccess:
      guard let data = item as? Data else {
        throw StoreError.invalidRecord
      }
      return data
    case errSecItemNotFound:
      return nil
    default:
      throw StoreError.keychain(status)
    }
  }

  private func write(data: Data) throws {
    let query = baseQuery()
    let update: [String: Any] = [
      kSecValueData as String: data,
    ]

    let updateStatus = SecItemUpdate(
      query as CFDictionary,
      update as CFDictionary
    )

    if updateStatus == errSecSuccess {
      return
    }

    guard updateStatus == errSecItemNotFound else {
      throw StoreError.keychain(updateStatus)
    }

    var add = query
    add[kSecValueData as String] = data
    add[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

    let addStatus = SecItemAdd(add as CFDictionary, nil)
    guard addStatus == errSecSuccess else {
      throw StoreError.keychain(addStatus)
    }
  }

  private func baseQuery() -> [String: Any] {
    return [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: Self.service,
      kSecAttrAccount as String: Self.account,
    ]
  }
}
