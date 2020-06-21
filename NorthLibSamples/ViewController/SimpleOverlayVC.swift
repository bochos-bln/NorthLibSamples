//
//  SimpleOverlayVC.swift
//  NorthLibSamples
//
//  Created by Ringo Müller on 17.06.20.
//  Copyright © 2020 Ringo Müller. All rights reserved.
//
import UIKit
import NorthLib

extension UIView {
  @discardableResult
  public func addTap(_ target: Any, action: Selector) -> UITapGestureRecognizer {
    let tap = UITapGestureRecognizer()
    tap.addTarget(target, action: action)
    self.addGestureRecognizer(tap)
    self.isUserInteractionEnabled = true
    return tap
  }
}


class SimpleOverlayVC: UIViewController {
  
  var image: UIImage?
  var imageView = UIImageView()
  var imageView2 = UIImageView(frame: CGRect(x: 10, y: 10, width: 180, height: 120))
  var child = ChildOverlayVC()
  var oa: Overlay?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let filePath = Bundle.main.path(forResource: "IMG_L", ofType: "jpg") {
      image = UIImage(contentsOfFile: filePath)
    }
    
    if let filePath = Bundle.main.path(forResource: "IMG_L", ofType: "jpg") {
      let image2 = UIImage(contentsOfFile: filePath)?.maskWithColor(color: UIColor.red.withAlphaComponent(0.4))
      imageView2.image = image2
    }
    
    imageView.image = image
    imageView.backgroundColor = .yellow
    imageView.contentMode = .scaleAspectFit
    imageView.clipsToBounds = true
    self.view.addSubview(imageView)
    self.view.addSubview(imageView2)
//    NorthLib.pin(imageView, toSafe: self.view)
    NorthLib.pin(imageView.left, to: self.view.left)
    NorthLib.pin(imageView.right, to: self.view.right)
    imageView.pinHeight(UIScreen.main.bounds.size.width/(image?.size.width)!*(image?.size.height)!)
    NorthLib.pin(imageView.centerY, to: self.view.centerY)
    
    imageView.addTap(self, action: #selector(handleTap))
    imageView2.addTap(self, action: #selector(handleTap))
    child.imageView.addTap(self, action: #selector(handleCloseTap))
    
  
    
    oa = Overlay(overlay: child, into: self)
    
    oa?.shadeColor = .black
    oa?.maxAlpha = 0.99
  }
  
  // MARK: Single Tap
  @objc func handleTap(sender: UITapGestureRecognizer){
    //    if let nc = self.navigationController {
    //      nc.pushViewController(child, animated: true)
    //    }
//        oa?.open(animated: true, fromBottom: true)
//        return
    child.view.frame = self.view.frame
    child.view.setNeedsLayout()
    child.view.layoutIfNeeded()
    
    //    var sourceFrame = imageView.frame
    //    sourceFrame.size.height = imageView.frame.size.width / imageView.image?.size.width* imageView.image?.size.height
        //ensure imageviews sourceframe is correct usally the image height is huge...
    
    if sender.view == imageView {
//       oa?.openAnimated(fromFrame: imageView.frame, toFrame: child.imageView.frame)
      oa?.open(animated: true, fromBottom: false)
    }
    else if sender.view == imageView2 {
//       oa?.openAnimated(fromFrame: imageView2.frame, toFrame: child.imageView.frame)
      oa?.open(animated: true, fromBottom: true)
    }
  }
  
    @objc func handleCloseTap(sender: UITapGestureRecognizer){
  //    if let nc = self.navigationController {
  //      nc.pushViewController(ChildOverlayVC(), animated: true)
  //    }
      oa?.close(animated: true)
      
//      if let nc = self.navigationController {
//            nc.pushViewController(UIViewController(), animated: true)
//          }
    }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
  }
}


class ChildOverlayVC: UIViewController {
//  var stack = UIStackView()
  var image: UIImage?
//  var image: UIImage?{
//    didSet{
//      imageView.image
//    }
//  }
  var imageView = UIImageView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
//    stack.alignment = .fill
//    stack.axis = .vertical
//    stack.distribution = .fill
    imageView.layer.borderColor = UIColor.yellow.cgColor
    imageView.layer.borderWidth = 2.0
    if let filePath = Bundle.main.path(forResource: "IMG_XS", ofType: "jpg") {
      image = UIImage(contentsOfFile: filePath)
    }

    imageView.clipsToBounds=true
    imageView.image = image
    imageView.contentMode = .scaleAspectFit
    self.view.addSubview(imageView)
//    stack.addArrangedSubview(imageView)
    imageView.pinWidth(UIScreen.main.bounds.size.width).priority = UILayoutPriority(rawValue: 200)
    NorthLib.pin(imageView.centerX, to: self.view.centerX)
    NorthLib.pin(imageView.centerY, to: self.view.centerY)
//    NorthLib.pin(imageView.bottom, to: stack.bottom).priority = UILayoutPriority(rawValue: 200)
//        NorthLib.pin(imageView.left, to: stack.left).priority = UILayoutPriority(rawValue: 200)
//        NorthLib.pin(imageView.right, to: stack.right).priority = UILayoutPriority(rawValue: 200)
//        NorthLib.pin(imageView.top, to: stack.top).priority = UILayoutPriority(rawValue: 200)
//    NorthLib.pin(imageView, toSafe: self.view)
    
    imageView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 750), for: .vertical)
    imageView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 750), for: .horizontal)

    imageView.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .vertical)
    imageView.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .horizontal)
    
//    self.hug
//    olution is to increase the Hugging Priority of SuperView to High(750 or more) and decrease the Compression Resistance Priority of UIImageView to Low(250 or less). This will let constraint
  }
  
}
