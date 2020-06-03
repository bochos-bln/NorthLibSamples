//
//  SceneDelegate.swift
//  NorthLibSamples
//
//  Created by Ringo Müller on 27.05.20.
//  Copyright © 2020 Ringo Müller. All rights reserved.
//

import UIKit
import SwiftUI
import NorthLib

extension OptionalImageItem{
  public convenience init(withResourceName name: String?, ofType ext: String?, tint: UIColor? = nil) {
    self.init()
    if let filePath = Bundle.main.path(forResource: name, ofType: ext) {
      var img = UIImage(contentsOfFile: filePath)
      if let _tint = tint, let _img = img{
        img = _img.maskWithColor(color: _tint)
      }
      
      self.waitingImage = img
    }
  }
}

extension UIImage {
  
  public func maskWithColor(color: UIColor) -> UIImage {
    
    UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
    let context = UIGraphicsGetCurrentContext()!
    
    let rect = CGRect(origin: CGPoint.zero, size: size)
    color.setFill()
    self.draw(in: rect)
    
    context.setBlendMode(.softLight)
    context.fill(rect)
    
    let resultImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return resultImage
  }
  
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    
    if let windowScene = scene as? UIWindowScene {
      let window = UIWindow(windowScene: windowScene)
      
      /************************************
       * SELECT Which Sample should be executed!
       * using #if for swift flag to get rid of the:
       * "Will never ececuted" Warning
       * which appears with default if/else
       ************************************/
      #if false //OPTION 1:  using SwiftUi Example
        let contentView = ContentView()
        window.rootViewController = UIHostingController(rootView: contentView)
      #elseif false //OPTION 2:  using Custom IUViewController:  ZoomableImageViewController
        window.rootViewController = ZoomableImageViewController()
      #elseif false //OPTION 3:  using  IUViewController with Custom View: ZoomedImageView
        let oi = OptionalImageItem(withResourceName: "IMG_M",
                                   ofType: "jpg",
                                   tint: UIColor.green)
        let zView = ZoomedImageView(optionalImage: oi)
        zView.onX {
          print("Close")
        }
        let vc = UIViewController()
        vc.view = zView
        window.rootViewController = vc
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.5) {
          if let filePath = Bundle.main.path(forResource: "IMG_L", ofType: "jpg") {
            oi.image = UIImage(contentsOfFile: filePath)
            print("Exchanged!")
          }
          
        }
      #else //OPTION 4:   using Custom IUViewController:  ImageCollectionViewController (UICollectionView)
        let icVc = ImageCollectionViewController()
        icVc.images = [
          OptionalImageItem(withResourceName: "IMG_L", ofType: "jpg"),
          OptionalImageItem(withResourceName: "IMG_XL", ofType: "jpg", tint: UIColor.red),
          OptionalImageItem(withResourceName: "IMG_M", ofType: "jpg", tint: UIColor.green),
          OptionalImageItem(withResourceName: "IMG_S", ofType: "jpg", tint: UIColor.purple),
          OptionalImageItem(withResourceName: "IMG_L", ofType: "jpg", tint: UIColor.yellow),
          OptionalImageItem(withResourceName: "IMG_L", ofType: "jpg", tint: UIColor.magenta),
          OptionalImageItem(withResourceName: "IMG_L", ofType: "jpg", tint: UIColor.blue)
        ]
        icVc.index = 0
        window.rootViewController = icVc
      #endif
      
      self.window = window
      window.makeKeyAndVisible()
    }
  }
  
  
  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
  }
  
  func sceneDidBecomeActive(_ scene: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
  }
  
  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
  }
  
  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
  }
  
  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
  }
  
  
}
