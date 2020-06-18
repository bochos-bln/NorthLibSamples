//
//  SimpleOverlayVC.swift
//  NorthLibSamples
//
//  Created by Ringo Müller on 17.06.20.
//  Copyright © 2020 Ringo Müller. All rights reserved.
//
import UIKit
import NorthLib


class SimpleOverlayVC: UIViewController {
  
  var image: UIImage?
  var imageView = UIImageView()
  var tap = UITapGestureRecognizer()
  var closeTap = UITapGestureRecognizer()
  var child = ChildOverlayVC()
  var oa: OverlayAnimator?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let filePath = Bundle.main.path(forResource: "IMG_L", ofType: "jpg") {
      image = UIImage(contentsOfFile: filePath)
    }
    imageView.image = image
    imageView.backgroundColor = .yellow
    imageView.contentMode = .scaleAspectFit
    imageView.clipsToBounds = true
    self.view.addSubview(imageView)
//    NorthLib.pin(imageView, toSafe: self.view)
    NorthLib.pin(imageView.left, to: self.view.left)
    NorthLib.pin(imageView.right, to: self.view.right)
    imageView.pinHeight(UIScreen.main.bounds.size.width/(image?.size.width)!*(image?.size.height)!)
    NorthLib.pin(imageView.centerY, to: self.view.centerY)
    

    tap.addTarget(self, action: #selector(handleTap))
    closeTap.addTarget(self, action: #selector(handleCloseTap))
    imageView.addGestureRecognizer(tap)
    imageView.isUserInteractionEnabled = true
    
//    oa = OverlayAnimator(overlayView: child.view, shadeView: self.view)
    oa = OverlayAnimator(overlay: child, into: self)
    oa?.shadeColor = .purple
    oa?.maxAlpha = 0.8
    
    child.imageView.addGestureRecognizer(closeTap)
    child.imageView.isUserInteractionEnabled = true
  }
  
  // MARK: Single Tap
  @objc func handleTap(sender: UITapGestureRecognizer){
//    if let nc = self.navigationController {
//      nc.pushViewController(child, animated: true)
//    }
//    oa?.open(animated: true, fromBottom: true)
//    return
    child.view.frame = self.view.frame
    child.view.setNeedsLayout()
    child.view.layoutIfNeeded()
    
//    var sourceFrame = imageView.frame
//    sourceFrame.size.height = imageView.frame.size.width / imageView.image?.size.width* imageView.image?.size.height
    //ensure imageviews sourceframe is correct usally the image height is huge...
    oa?.openAnimated(fromFrame: imageView.frame, toFrame: child.imageView.frame)
    
  }
  
    @objc func handleCloseTap(sender: UITapGestureRecognizer){
  //    if let nc = self.navigationController {
  //      nc.pushViewController(ChildOverlayVC(), animated: true)
  //    }
      oa?.close(animated: true)
      
    }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
  }
}


class ChildOverlayVC: UIViewController {
  
  var image: UIImage?
  fileprivate  var imageView = UIImageView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let filePath = Bundle.main.path(forResource: "IMG_XS", ofType: "jpg") {
      image = UIImage(contentsOfFile: filePath)
    }
    imageView.image = image
    imageView.contentMode = .scaleAspectFit
    self.view.addSubview(imageView)
    NorthLib.pin(imageView.centerX, to: self.view.centerX)
    NorthLib.pin(imageView.centerY, to: self.view.centerY)
//    NorthLib.pin(imageView, toSafe: self.view, dist: 30)
  }
  
}
