import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  private let privacyShieldCoordinator = BreakWavePrivacyShieldCoordinator()

  override func sceneWillResignActive(_ scene: UIScene) {
    privacyShieldCoordinator.sceneWillResignActive(scene)
    super.sceneWillResignActive(scene)
  }

  override func sceneDidEnterBackground(_ scene: UIScene) {
    privacyShieldCoordinator.sceneDidEnterBackground(scene)
    super.sceneDidEnterBackground(scene)
  }

  override func sceneDidBecomeActive(_ scene: UIScene) {
    // Let Flutter process resumed privacy state before scheduling cover removal.
    super.sceneDidBecomeActive(scene)
    privacyShieldCoordinator.sceneDidBecomeActive(scene)
  }
}
