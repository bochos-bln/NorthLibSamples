//
//  SimpleOverlayVC.swift
//  NorthLibSamples
//
//  Created by Ringo Müller on 17.06.20.
//  Copyright © 2020 Ringo Müller. All rights reserved.
//
import UIKit
import NorthLib

// MARK: - UIView extension addTap
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

// MARK: - SimpleOverlayVC
class SimpleOverlayVC: UIViewController {
  var imageView = UIImageView()
  var imageView2 = UIImageView(frame: CGRect(x: 10, y: 10, width: 180, height: 120))
  var oa: Overlay?
  
  // MARK: viewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    if false {/// ImageCollectionVC Demo
      oa = Overlay(overlay: getImageCollectionVC(), into: self)
      imageView.addTap(self, action: #selector(handleTapImageCollectionVC))
      imageView2.addTap(self, action: #selector(handleTapImageCollectionVC))
    }
    else if true {/// Child Vc with ZoomedImageView
      oa = Overlay(overlay: getChildVcWithZoomedImageView(), into: self)
      imageView.addTap(self, action: #selector(handleTapZoomedImageView))
      imageView2.addTap(self, action: #selector(handleTapZoomedImageView))
    }
    else {/// ChildOverlayVC
      let child = ChildOverlayVC()
      oa = Overlay(overlay: child, into: self)
      child.imageView.addTap(self, action: #selector(handleCloseTap))
      imageView.addTap(self, action: #selector(handleTapChildOverlayVC))
      imageView2.addTap(self, action: #selector(handleTapChildOverlayVC))
    }
    setupView()
    oa?.closeRatio = 0.5
    oa?.shadeColor = .black
    oa?.maxAlpha = 0.99
  }
  
  // MARK: setupView()
  func setupView(){
    if let filePath = Bundle.main.path(forResource: "IMG_L_2", ofType: "jpg") {
      let image = UIImage(contentsOfFile: filePath)
      imageView2.image = image
    }
    
    if let filePath = Bundle.main.path(forResource: "IMG_L_4", ofType: "jpg") {
      let image = UIImage(contentsOfFile: filePath)?.maskWithColor(color: UIColor.red.withAlphaComponent(0.4))
      imageView.image = image
    }
    
    let wrapper = UIView()
    
    imageView.backgroundColor = .yellow
    imageView.contentMode = .scaleAspectFit
    imageView.clipsToBounds = true
    
    wrapper.addSubview(imageView)
    wrapper.addSubview(imageView2)
    
    NorthLib.pin(imageView.left, to: wrapper.left)
    NorthLib.pin(imageView.right, to: wrapper.right)
    
    if let img = imageView.image {
      imageView.pinHeight(UIScreen.main.bounds.size.width/(img.size.width)*(img.size.height))
    }
    
    NorthLib.pin(imageView.centerY, to: wrapper.centerY)
    
    self.view.addSubview(wrapper)
    NorthLib.pin(wrapper, toSafe: self.view)
  }
  
  // MARK: getImageCollectionVC()
  func getImageCollectionVC() -> UIViewController{
    let icVc = ImageCollectionVC()
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
    return icVc
  }
  
  // MARK: getChildVcWithZoomedImageView()
  func getChildVcWithZoomedImageView() -> UIViewController{
    let oi = OptionalImageItem(withWaitingName: "IMG_XS", waitingExt: "jpg", waitingTint: UIColor.yellow, detailName: "IMG_XL", detailExt: "jpg", detailTint: UIColor.cyan, exchangeTimeout: 0)
    let zView = ZoomedImageView(optionalImage: oi)
    zView.onX {
      self.oa?.close(animated: true, toBottom: true)
    }
    let vc = UIViewController()
    vc.view.addSubview(zView)
    NorthLib.pin(zView, to: vc.view)
    return vc
  }
  
  /// **Temp Vars openedFromRect**
  var openedFromRect = CGRect.zero
  // MARK: handleTapChildOverlayVC
  @objc func handleTapChildOverlayVC(sender: UITapGestureRecognizer){
    guard let child = self.oa?.overlayVC as? ChildOverlayVC else { return }
    child.view.frame = self.view.frame
    child.view.setNeedsLayout()
    child.view.layoutIfNeeded()
    
    if sender.view == imageView {
      child.imageView.image = imageView.image
      openedFromRect = imageView.frame
      oa?.openAnimated(fromFrame: openedFromRect, toFrame: child.imageView.frame)
      oa?.overlaySize = child.imageView.frame.size
    }
    else if sender.view == imageView2 {
      child.imageView.image = imageView2.image
      openedFromRect = imageView2.frame
      oa?.overlaySize = child.imageView.frame.size
      oa?.openAnimated(fromFrame: openedFromRect, toFrame: child.imageView.frame)
    }
  }
  
  // MARK: handleTapZoomedImageView
  @objc func handleTapZoomedImageView(sender: UITapGestureRecognizer){
    guard let ziv = self.oa?.overlayVC.view.subviews[0] as? ZoomedImageView else { return }
    if sender.view == imageView {
      ziv.optionalImage.image = imageView.image
      openedFromRect = imageView.frame //did not work due content insets centering!!
      //    oa?.openAnimated(fromFrame: openedFromRect, toFrame: ziv.imageView.frame)
      oa?.open(animated: true, fromBottom: true)
    }
    else if sender.view == imageView2 {
      ziv.optionalImage.image = imageView2.image
      openedFromRect = imageView2.frame//did not work due content insets centering!!
      //    oa?.openAnimated(fromFrame: openedFromRect, toFrame: ziv.imageView.frame)
      oa?.open(animated: true, fromBottom: false)
    }

  }
  
  // MARK: handleTapImageCollectionVC
  @objc func handleTapImageCollectionVC (sender: UITapGestureRecognizer){
    /// Handle other childs...
    if sender.view == imageView {
      openedFromRect = imageView.frame
      oa?.open(animated: true, fromBottom: false)
    }
    else if sender.view == imageView2 {
      openedFromRect = imageView2.frame
      oa?.open(animated: true, fromBottom: true)
    }
  }
  
  // MARK: handleCloseTap
  @objc func handleCloseTap(sender: UITapGestureRecognizer){
    if let child = self.oa?.overlayVC as? ChildOverlayVC {
      self.oa?.close(fromRect: child.imageView.frame, toRect: openedFromRect)
    }
    ///others have a close x
  }
}

///a simple UIViewController with a centered ImageView with Image
class ChildOverlayVC: UIViewController {
  var image: UIImage?
  var imageView = UIImageView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupWithoutWrapper()
  }
  
  func setupWithWrapper(){
    let wrapper = UIView()
    if let filePath = Bundle.main.path(forResource: "IMG_XL", ofType: "jpg") {
      imageView.image = UIImage(contentsOfFile: filePath)
      imageView.contentMode = .scaleAspectFit
    }
    wrapper.addSubview(imageView)
    
    imageView.pinWidth(UIScreen.main.bounds.size.width).priority = UILayoutPriority(rawValue: 200)
    NorthLib.pin(imageView.centerX, to: wrapper.centerX)
    NorthLib.pin(imageView.centerY, to: wrapper.centerY)
    
    if let img = imageView.image {
      let width = min(UIScreen.main.bounds.size.width, img.size.width)
      imageView.pinWidth(width)
      imageView.pinHeight(width*img.size.height/img.size.width)
    }
    
    self.view.addSubview(wrapper)
    NorthLib.pin(wrapper, toSafe: self.view)
  }
  
  func setupWithoutWrapper(){
    if let filePath = Bundle.main.path(forResource: "IMG_XL", ofType: "jpg") {
      imageView.image = UIImage(contentsOfFile: filePath)
      imageView.contentMode = .scaleAspectFit
    }
    self.view.addSubview(imageView)
    
    imageView.pinWidth(UIScreen.main.bounds.size.width).priority = UILayoutPriority(rawValue: 200)
    NorthLib.pin(imageView.centerX, to: self.view.centerX)
    NorthLib.pin(imageView.centerY, to: self.view.centerY)
    
    if let img = imageView.image {
      let width = min(UIScreen.main.bounds.size.width, img.size.width)
      imageView.pinWidth(width)
      imageView.pinHeight(width*img.size.height/img.size.width)
    }
  }
}
