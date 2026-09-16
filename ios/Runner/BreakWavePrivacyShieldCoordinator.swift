import UIKit

/// IOS-G2I app-switcher/background privacy cover.
/// This is a visual privacy shield, not a screenshot-prevention promise.
final class BreakWavePrivacyShieldCoordinator {
  private var shieldView: UIView?

  func sceneWillResignActive(_ scene: UIScene) {
    showShield(in: scene)
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    showShield(in: scene)
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    // FlutterSceneDelegate receives the active lifecycle first. Two main-queue
    // turns let Flutter apply its resumed privacy state before cover removal.
    DispatchQueue.main.async { [weak self] in
      DispatchQueue.main.async { [weak self] in
        self?.removeShield(in: scene)
      }
    }
  }

  private func showShield(in scene: UIScene) {
    guard let window = targetWindow(in: scene) else { return }

    if let shieldView {
      if shieldView.superview !== window {
        shieldView.removeFromSuperview()
        window.addSubview(shieldView)
      }
      shieldView.frame = window.bounds
      window.bringSubviewToFront(shieldView)
      return
    }

    let cover = UIView(frame: window.bounds)
    cover.backgroundColor = .systemBackground
    cover.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    cover.isUserInteractionEnabled = true
    cover.accessibilityIdentifier = "breakwave.privacyShield"

    let stack = UIStackView()
    stack.axis = .vertical
    stack.alignment = .center
    stack.spacing = 10
    stack.translatesAutoresizingMaskIntoConstraints = false

    let icon = UIImageView(image: UIImage(systemName: "lock.shield.fill"))
    icon.tintColor = .secondaryLabel
    icon.contentMode = .scaleAspectFit
    icon.translatesAutoresizingMaskIntoConstraints = false

    let title = UILabel()
    title.text = "BreakWave"
    title.font = .preferredFont(forTextStyle: .title2)
    title.textColor = .label

    let subtitle = UILabel()
    subtitle.text = "Private recovery information is protected."
    subtitle.font = .preferredFont(forTextStyle: .body)
    subtitle.textColor = .secondaryLabel
    subtitle.textAlignment = .center
    subtitle.numberOfLines = 0

    stack.addArrangedSubview(icon)
    stack.addArrangedSubview(title)
    stack.addArrangedSubview(subtitle)
    cover.addSubview(stack)

    NSLayoutConstraint.activate([
      icon.widthAnchor.constraint(equalToConstant: 42),
      icon.heightAnchor.constraint(equalToConstant: 42),
      stack.centerXAnchor.constraint(equalTo: cover.centerXAnchor),
      stack.centerYAnchor.constraint(equalTo: cover.centerYAnchor),
      stack.leadingAnchor.constraint(greaterThanOrEqualTo: cover.leadingAnchor, constant: 28),
      stack.trailingAnchor.constraint(lessThanOrEqualTo: cover.trailingAnchor, constant: -28),
    ])

    window.addSubview(cover)
    window.bringSubviewToFront(cover)
    shieldView = cover
  }

  private func removeShield(in scene: UIScene) {
    guard scene.activationState == .foregroundActive else { return }
    shieldView?.removeFromSuperview()
    shieldView = nil
  }

  private func targetWindow(in scene: UIScene) -> UIWindow? {
    guard let windowScene = scene as? UIWindowScene else { return nil }
    return windowScene.windows.first(where: { $0.isKeyWindow })
      ?? windowScene.windows.first
  }
}
