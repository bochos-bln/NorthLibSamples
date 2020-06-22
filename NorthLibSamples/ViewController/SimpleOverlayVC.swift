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
  var icVc = ImageCollectionVC()
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
    
    if false /*USE ImageCollectionVC DEMO */{
      

      icVc.images = [
        
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
      icVc.addMenuItem(title: "close animated", icon: "xmark.circle") { (str) in
        self.oa?.close(animated: true, toBottom: false)
      }
      icVc.addMenuItem(title: "close to bottom", icon: "arrow.down.square.fill") { (str) in
        self.oa?.close(animated: true, toBottom: true)
      }
      icVc.addMenuItem(title: "close", icon: "") { (str) in
        print("handle \(str)")
      }
      icVc.onTap { (oimg, x, y) in
        print("tapped at: \(x) \(y)")
      }
      icVc.onX {
         self.oa?.close(animated: true, toBottom: true)
      }
      oa = Overlay(overlay: icVc, into: self)
      oa?.overlayView?.addSubview(icVc.xButton)
      if let pc = icVc.pageControl {
        oa?.overlayView?.addSubview(pc)
      }
    } else {
      oa = Overlay(overlay: child, into: self)
    }
  
    oa?.closeRatio = 0.5
    oa?.shadeColor = .black
    oa?.maxAlpha = 0.99
  }
  
  // MARK: Single Tap
  @objc func handleTap(sender: UITapGestureRecognizer){
//    icVc.collectionView.backgroundColor = .clear
        if sender.view == imageView {
//          openedFromRect = imageView.frame
//          oa?.openAnimated(fromFrame: openedFromRect, toFrame: child.imageView.frame)
//          oa?.overlaySize = child.imageView.frame.size
          oa?.open(animated: true, fromBottom: false)
        }
        else if sender.view == imageView2 {
//           openedFromRect = imageView2.frame
//          oa?.overlaySize = child.imageView.frame.size
//           oa?.openAnimated(fromFrame: openedFromRect, toFrame: child.imageView.frame)
          oa?.open(animated: true, fromBottom: true)
        }
         
  }
  
  
  @objc func handleTap1(sender: UITapGestureRecognizer){
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
      openedFromRect = imageView.frame
      oa?.openAnimated(fromFrame: openedFromRect, toFrame: child.imageView.frame)
      oa?.overlaySize = child.imageView.frame.size
//      oa?.open(animated: true, fromBottom: false)
    }
    else if sender.view == imageView2 {
       openedFromRect = imageView2.frame
      oa?.overlaySize = child.imageView.frame.size
       oa?.openAnimated(fromFrame: openedFromRect, toFrame: child.imageView.frame)
//      oa?.open(animated: true, fromBottom: true)
    }
  }
  
  var openedFromRect = CGRect.zero
  
    @objc func handleCloseTap(sender: UITapGestureRecognizer){
  //    if let nc = self.navigationController {
  //      nc.pushViewController(ChildOverlayVC(), animated: true)
  //    }
//      oa?.close(animated: false)
//      oa?.shrinkTo(rect: imageView.frame)
      oa?.close(fromRect: child.imageView.frame, toRect: openedFromRect)
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
//    imageView.layer.borderColor = UIColor.yellow.cgColor
//    imageView.layer.borderWidth = 2.0
    if let filePath = Bundle.main.path(forResource: "IMG_XL", ofType: "jpg") {
      image = UIImage(contentsOfFile: filePath)
    }

    imageView.clipsToBounds=true
    imageView.image = image
    imageView.contentMode = .scaleAspectFit
    self.view.addSubview(imageView)
    imageView.pinWidth(UIScreen.main.bounds.size.width).priority = UILayoutPriority(rawValue: 200)
    NorthLib.pin(imageView.centerX, to: self.view.centerX)
    NorthLib.pin(imageView.centerY, to: self.view.centerY)
    
    guard let img = image else  {return    }
    let width = min(UIScreen.main.bounds.size.width, img.size.width)
    imageView.pinWidth(width)
    imageView.pinHeight(width*img.size.height/img.size.width)
//    NorthLib.pin(imageView.bottom, to: stack.bottom).priority = UILayoutPriority(rawValue: 200)
//        NorthLib.pin(imageView.left, to: stack.left).priority = UILayoutPriority(rawValue: 200)
//        NorthLib.pin(imageView.right, to: stack.right).priority = UILayoutPriority(rawValue: 200)
//        NorthLib.pin(imageView.top, to: stack.top).priority = UILayoutPriority(rawValue: 200)
//    NorthLib.pin(imageView, toSafe: self.view)
    
//    imageView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 750), for: .vertical)
//    imageView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 750), for: .horizontal)
//
//    imageView.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .vertical)
//    imageView.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .horizontal)
    
//    self.hug
//    olution is to increase the Hugging Priority of SuperView to High(750 or more) and decrease the Compression Resistance Priority of UIImageView to Low(250 or less). This will let constraint
  }
  
}
