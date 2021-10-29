import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let createPaymentSessionChannel = "monri.create.payment.session.channel"
    let createPaymentSessionMethod = "monri.create.payment.session.method"

    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let monriCreatePaymentSessionChannel = FlutterMethodChannel(name: createPaymentSessionChannel,
            binaryMessenger: controller.binaryMessenger)

    monriCreatePaymentSessionChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      // Note: this method is invoked on the UI thread.

      if (call.method == createPaymentSessionMethod) {
        let implementation = MonriHelper()
        implementation.createPaymentSessionHelperFunc{ response in
          guard let response: NewPaymentResponse = response else {
            result("something went wrong with create payment session")
            return //todo do we need return here?
          }

          result(response.clientSecret)
        }
      }

    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
