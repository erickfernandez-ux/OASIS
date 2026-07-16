import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let privacyChannelName = "oasis/privacy"
  private var privacyProtectionEnabled = false
  private var privacyOverlayView: UIView?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleWillResignActive),
      name: UIApplication.willResignActiveNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleDidBecomeActive),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )

    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    configurePrivacyChannel()
    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  private func configurePrivacyChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: privacyChannelName,
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "privacy_unavailable", message: nil, details: nil))
        return
      }

      switch call.method {
      case "setSecureFlag":
        let arguments = call.arguments as? [String: Any]
        let enabled = arguments?["enabled"] as? Bool ?? false
        self.privacyProtectionEnabled = enabled
        if enabled {
          if UIApplication.shared.applicationState != .active {
            self.showPrivacyOverlay()
          }
        } else {
          self.hidePrivacyOverlay()
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  @objc private func handleWillResignActive() {
    guard privacyProtectionEnabled else {
      return
    }
    showPrivacyOverlay()
  }

  @objc private func handleDidBecomeActive() {
    hidePrivacyOverlay()
  }

  private func showPrivacyOverlay() {
    guard privacyOverlayView == nil else {
      return
    }
    guard let targetWindow = currentKeyWindow() else {
      return
    }

    let overlay = UIView(frame: targetWindow.bounds)
    overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    overlay.backgroundColor = UIColor.systemBackground

    let label = UILabel()
    label.text = "OASIS"
    label.textColor = .secondaryLabel
    label.font = UIFont.preferredFont(forTextStyle: .headline)
    label.translatesAutoresizingMaskIntoConstraints = false

    overlay.addSubview(label)
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
      label.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
    ])

    targetWindow.addSubview(overlay)
    privacyOverlayView = overlay
  }

  private func hidePrivacyOverlay() {
    privacyOverlayView?.removeFromSuperview()
    privacyOverlayView = nil
  }

  private func currentKeyWindow() -> UIWindow? {
    if let keyWindow = window {
      return keyWindow
    }

    return UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first(where: { $0.isKeyWindow })
  }
}
