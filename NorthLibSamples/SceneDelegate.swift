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

/*******
ToDO's / Issues
 
- Handle rotation from ImageCollectionViewController, not from View DONE
    - Issue: small Image displayed => rotate => the nearby Image is also shown
    => ToDo Solution fade Out & In or just set the transparency!
- discuss or implement active view
     @SEE Specs L. 123 f ....
       > currentPage - to indicate which image is displayed
       > numberOfPages - to specify how many dots are displayed in total
- Test
*/

class UIControlClosureStorage {
  let closure: () -> ()

  init(attachTo: AnyObject, closure: @escaping () -> ()) {
    self.closure = closure
    objc_setAssociatedObject(attachTo, "[\(UUID().uuidString)]", self, .OBJC_ASSOCIATION_RETAIN)
  }

  @objc func invoke() {
    closure()
  }
}

extension UIControl {
  func addAction(for controlEvents: UIControl.Event = .primaryActionTriggered, action: @escaping () -> ()) {
    let itm = UIControlClosureStorage(attachTo: self, closure: action)
    addTarget(itm, action: #selector(UIControlClosureStorage.invoke), for: controlEvents)
 }
}

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
  
  public convenience init(withWaitingName waitingName: String? = nil,
                          waitingExt: String? = nil,
                          waitingTint: UIColor? = nil,
                          detailName: String? = nil,
                          detailExt: String? = nil,
                          detailTint: UIColor? = nil,
                          exchangeTimeout:Double = 0.0) {
    self.init()
    
    if let name = waitingName,
      let ext = waitingExt,
      let filePath = Bundle.main.path(forResource: name, ofType: ext) {
        var img = UIImage(contentsOfFile: filePath)
        if let _tint = waitingTint, let _img = img{
          img = _img.maskWithColor(color: _tint)
        }
        self.waitingImage = img
    }
    
    if let name = detailName,
      let ext = detailExt,
      let filePath = Bundle.main.path(forResource: name, ofType: ext) {
        var img = UIImage(contentsOfFile: filePath)
        if let _tint = detailTint, let _img = img{
          img = _img.maskWithColor(color: _tint)
        }
      if exchangeTimeout > 0.0 {
        DispatchQueue.main.asyncAfter(deadline: .now() + exchangeTimeout) {
          self.image = img
        }
      } else {
        self.image = img
      }
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
      #elseif false //OPTION OverlaySpec with UICollectionVC with Photos
      window.rootViewController = PhotoGridCVC()
      #elseif false //OPTION OverlaySpec with SimpleOverlayVC with NC
      window.rootViewController = UINavigationController(rootViewController: SimpleOverlayVC())
      #elseif true //OPTION OverlaySpec with SimpleOverlayVC
      window.rootViewController = SimpleOverlayVC()
      #elseif false //OPTION 3:  using  UIViewController with Custom View: ZoomedImageView
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
      //The Initial VC
      let vc = UIViewController()
      let btn = UIButton()
      btn.setTitle("Push ImageCollectionViewController", for: .normal)
      btn.layer.borderColor = UIColor.white.cgColor
      btn.layer.borderWidth = 1.0
      btn.isEnabled = false
      btn.titleEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
      vc.view.addSubview(btn)
      pin(btn.centerX, to: vc.view.centerX)
      pin(btn.centerY, to: vc.view.centerY)
      //The ImageCollectionViewController automaticly pushed after 1s
      let icVc = ImageCollectionVC()
      icVc.images = [
//        OptionalImageItem(withWaitingName: "IMG_XS", waitingExt: "jpg", waitingTint: UIColor.systemIndigo,
//                          detailName: nil, detailExt: "jpg", detailTint: UIColor.systemIndigo,
//                          exchangeTimeout: 2.0),
        OptionalImageItem(withWaitingName: "IMG_M", waitingExt: "jpg", waitingTint: UIColor.red, detailName: "IMG_L", detailExt: "jpg", detailTint: UIColor.red, exchangeTimeout: 1.0),
        OptionalImageItem(withWaitingName: "IMG_XS", waitingExt: "jpg", waitingTint: UIColor.green, detailName: "IMG_L", detailExt: "jpg", detailTint: UIColor.green, exchangeTimeout: 4.0),
        OptionalImageItem(withWaitingName: "IMG_S", waitingExt: "jpg", waitingTint: UIColor.blue),
        OptionalImageItem(withWaitingName: "IMG_XS", waitingExt: "jpg", waitingTint: UIColor.yellow, detailName: "IMG_XL", detailExt: "jpg", detailTint: UIColor.yellow, exchangeTimeout: 8.0),
        OptionalImageItem(withWaitingName: "IMG_S", waitingExt: "jpg", waitingTint: UIColor.purple),
        OptionalImageItem(withWaitingName: "IMG_M", waitingExt: "jpg", waitingTint: UIColor.systemPink, detailName: "IMG_XL", detailExt: "jpg", detailTint: UIColor.systemPink, exchangeTimeout: 12.0),
        OptionalImageItem(withWaitingName: "IMG_L", waitingExt: "jpg", waitingTint: UIColor.brown),
        OptionalImageItem(withWaitingName: "IMG_XL", waitingExt: "jpg", waitingTint: UIColor.cyan, detailName: "IMG_XL", detailExt: "jpg", detailTint: UIColor.cyan, exchangeTimeout: 16.0),
      ]
      icVc.pageControlMaxDotsCount = 3
      icVc.addMenuItem(title: "hallo", icon: "doc") { (str) in
        print("handle \(str)")
      }
      icVc.onTap { (oimg, x, y) in
        print("tapped at: \(x) \(y)")
      }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 20.0) {
          //Test replacement of Max Dots with all Dots
          icVc.pageControlMaxDotsCount = 0
      }
//      var addClosure = true
//      for oit in icVc.images {
//        addClosure = !addClosure
//        if addClosure == true { continue }
//        oit.onTap { (oimg, x, y) in
//          print("You taped at:", x, y, " in ", oit.image, oit.waitingImage)
//        }
//      }
      
      icVc.index = 0
      icVc.pageControlColors = (current: UIColor.rgb(0xcccccc),
                                  other: UIColor.rgb(0xcccccc, alpha: 0.3))
          

      let oitm = icVc.images.first
      
      var detailImageNames = ["IMG_M", "IMG_L", "IMG_XL"]
        
      
//      oitm?.onHighResImgNeeded(zoomFactor: 1.8) { (callback: @escaping (UIImage?) -> ()) in
//        let imgName = detailImageNames.pop()
//        print("Generating the Image for: \(imgName).jpg")
//
//        if imgName == nil {
//          callback(nil)
//          return;
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//          print("Callback with an image!")
//          if let filePath = Bundle.main.path(forResource: imgName, ofType: "jpg") {
//            callback(UIImage(contentsOfFile: filePath))
//          }
//        }
//      }
            
      
      let nc = UINavigationController(rootViewController: vc)
      icVc.modalPresentationStyle = .fullScreen
      icVc.modalTransitionStyle = .flipHorizontal
      
      btn.addAction {
        vc.navigationController?.present(icVc, animated: true, completion: nil)
      }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        vc.navigationController?.pushViewController(icVc, animated: true)
        btn.isEnabled = true
      }
      
        //Pushing default/initial VC
        window.rootViewController = nc
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
