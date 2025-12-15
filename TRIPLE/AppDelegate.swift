//
//  AppDelegate.swift
//  TRIPLE
//
//  Created by 홍승표 on 11/24/25.
//

import UIKit
import GoogleMaps
import GooglePlaces

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Load Google Maps API Key from Secret.plist
        if let path = Bundle.main.path(forResource: "Secret", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
           let apiKey = dict["GoogleMaps-API-KEY"] as? String, !apiKey.isEmpty {
            GMSServices.provideAPIKey(apiKey)
            GMSPlacesClient.provideAPIKey(apiKey)
        } else {
            assertionFailure("Missing or empty APIKEY in Secret.plist")
        }
        let window = UIWindow(frame: UIScreen.main.bounds)
        let navController = UINavigationController()
        navController.setNavigationBarHidden(true, animated: false) // Default NavigationBar 숨기기
        let aVC = MainViewController(nibName: "MainViewController", bundle: nil)
        navController.viewControllers = [aVC]
        window.rootViewController = navController
        self.window = window
        window.makeKeyAndVisible()
        return true
    }
    
}
