import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
        let keys = NSDictionary(contentsOfFile: path)
        
        if let googleMapsApiKey = keys?.value(forKey: "google_maps_api_key") as? String {
            GMSServices.provideAPIKey(googleMapsApiKey)
        }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
