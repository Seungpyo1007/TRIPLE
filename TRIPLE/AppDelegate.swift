//
//  AppDelegate.swift
//  TRIPLE
//
//  Created by 홍승표 on 11/24/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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
