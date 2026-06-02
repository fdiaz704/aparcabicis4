import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Read the Google Maps API key from Info.plist (injected from Secrets.xcconfig
    // at build time). Never hardcode the key in source.
    if let mapsApiKey = Bundle.main.object(forInfoDictionaryKey: "MapsApiKey") as? String,
       !mapsApiKey.isEmpty {
      GMSServices.provideAPIKey(mapsApiKey)
    } else {
      assertionFailure("MapsApiKey missing. Create ios/Flutter/Secrets.xcconfig from the .example file.")
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

