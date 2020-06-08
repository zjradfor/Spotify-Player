//
//  AppDelegate.swift
//  SpotifyKitDemo
//
//  Created by Zach Radford on 2020-05-31.
//  Copyright © 2020 Zach Radford. All rights reserved.
//

import UIKit

fileprivate let application = SpotifyManager.SpotifyDeveloperApplication(
    clientId:     ClientKeys.clientId,
    clientSecret: ClientKeys.clientSecret,
    redirectUri:  ClientKeys.redirectUri
)

let spotifyManager = SpotifyManager(with: application)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if ClientKeys.clientId == "" {
            assertionFailure("Please enter your spotify developer credentials in ClientKeys.swift")
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

}

