//
//  SceneDelegate.swift
//  DriveSafe
//
//  Created by yahia salman on 10/12/24.
//

//
//  SceneDelegate.swift
//  HackFax-AAAAT
//
//  Created by yahia salman on 2/16/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = LoginViewController()
        self.window = window
        window.makeKeyAndVisible()
        
    }



}
