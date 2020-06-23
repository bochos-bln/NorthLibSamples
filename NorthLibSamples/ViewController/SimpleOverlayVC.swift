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
    
    let wrapper = UIView()//Important to pin to safe otherwise transition "jumps"
    
    imageView.backgroundColor = .yellow
    imageView.contentMode = .scaleAspectFit
    imageView.clipsToBounds = true
    
    wrapper.addSubview(imageView)
    wrapper.addSubview(imageView2)
    
    let changeChildLabel = UILabel()
    changeChildLabel.textColor = .white
    changeChildLabel.layer.borderColor = UIColor.blue.cgColor
    changeChildLabel.layer.borderWidth = 2.0
    changeChildLabel.numberOfLines = 2
    changeChildLabel.textAlignment = .center
    changeChildLabel.text = child.title
    changeChildLabel.addTap(self, action: #selector(handleTapChangeChild))
    
    let changeAppearLabel = UILabel()
    changeAppearLabel.textColor = .white
    changeAppearLabel.layer.borderColor = UIColor.red.cgColor
    changeAppearLabel.layer.borderWidth = 2.0
    changeAppearLabel.numberOfLines = 2
    changeAppearLabel.textAlignment = .center
    changeAppearLabel.text = appear.title
    changeAppearLabel.addTap(self, action: #selector(handleTapChangeAppear))
    
    
    wrapper.addSubview(changeChildLabel)
    wrapper.addSubview(changeAppearLabel)
    
    NorthLib.pin(changeChildLabel.left, to: wrapper.left)
    NorthLib.pin(changeChildLabel.right, to: wrapper.right)
    NorthLib.pin(changeChildLabel.bottom, to: wrapper.bottom, dist: -20)
    
    NorthLib.pin(changeAppearLabel.left, to: wrapper.left)
    NorthLib.pin(changeAppearLabel.right, to: wrapper.right)
    NorthLib.pin(changeAppearLabel.bottom, to: wrapper.bottom, dist: -70)
    
    NorthLib.pin(imageView.left, to: wrapper.left)
    NorthLib.pin(imageView.right, to: wrapper.right)
    
    if let img = imageView.image {
      imageView.pinHeight(UIScreen.main.bounds.size.width/(img.size.width)*(img.size.height))
    }
    
    NorthLib.pin(imageView.centerY, to: wrapper.centerY)
    
    imageView.addTap(self, action: #selector(handleTap))
    imageView2.addTap(self, action: #selector(handleTap))
    self.view.addSubview(wrapper)
    NorthLib.pin(wrapper, toSafe: self.view)
  }
  // MARK: handleTapChangeChild
  @objc func handleTapChangeChild(sender: UITapGestureRecognizer){
    guard let label = sender.view as? UILabel else { return }
    child = child.next
    label.text = child.title
  }
  // MARK: handleTapChangeAppear
  @objc func handleTapChangeAppear(sender: UITapGestureRecognizer){
    guard let label = sender.view as? UILabel else { return }
    appear = appear.next
    label.text = appear.title
  }
  
  
  // MARK: ChildOptions
  var child = ChildOptions.simpleImage
  enum ChildOptions {
    case imageCollectionVC
    case zoomedImageView
    case simpleImage
    var next : ChildOptions{
      switch self {
      case .imageCollectionVC:
        return .zoomedImageView
      case .zoomedImageView:
        return .simpleImage
      case .simpleImage:
        return .imageCollectionVC
      } }
    var title : String {
      get{
        switch self {
        case .imageCollectionVC:
          return "Child:\nImageCollectionVC"
        case .zoomedImageView:
          return "Child:\nZoomedImageView"
        case .simpleImage:
          return "Child:\nSimpleImage"
        }}}
  }
  
  // MARK: AppearOptions
  var appear = AppearOptions.appearFromBottom
  enum AppearOptions {
    case appearFromBottom
    case appearAnimated
    case appearWithoutAnimation
    case fromSourceFrame
    var next : AppearOptions{
      switch self {
      case .appearFromBottom:
        return .appearAnimated
      case .appearAnimated:
        return .appearWithoutAnimation
      case .appearWithoutAnimation:
        return .fromSourceFrame
      case .fromSourceFrame:
        return .appearFromBottom
      } }
    var title : String {
      get{
        let pre = "Appear (Disappear on X)\n"
        switch self {
        case .appearFromBottom:
          return pre+"animated from Bottom"
        case .appearAnimated:
          return pre+"animated"
        case .appearWithoutAnimation:
          return pre+"without Animation"
        case .fromSourceFrame:
          return pre+"from Source Frame"
        }}}}
  
  
  // MARK: childWithImageCollectionVC()
  lazy var childWithImageCollectionVC : UIViewController = {
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
  }()
  
  // MARK: childVcWithZoomedImageView
  lazy var childVcWithZoomedImageView : UIViewController = {
    let oi = OptionalImageItem(withWaitingName: "IMG_XS", waitingExt: "jpg", waitingTint: UIColor.yellow, detailName: "IMG_XL", detailExt: "jpg", detailTint: UIColor.cyan, exchangeTimeout: 0)
    let zView = ZoomedImageView(optionalImage: oi)
    zView.onX {
      self.oa?.close(animated: true, toBottom: true)
    }
    let vc = UIViewController()
    vc.view.addSubview(zView)
    NorthLib.pin(zView, to: vc.view)
    return vc
  }()
  
  // MARK: childVcChildOverlayVC
  lazy var childVcChildOverlayVC : UIViewController = {
    let child = ChildOverlayVC()
    child.imageView.addTap(self, action: #selector(handleCloseTap))
    return child
  }()
  // MARK: handleCloseTap
  @objc func handleCloseTap(sender: UITapGestureRecognizer?){
    switch self.appear {
    case .appearAnimated:
      oa?.close(animated: true)
      break
    case .appearFromBottom:
      oa?.close(animated: true, toBottom: true)
      break
    case .appearWithoutAnimation:
      oa?.close(animated: false, toBottom: false)
      break
    case .fromSourceFrame:
      guard let covc = childVcChildOverlayVC as? ChildOverlayVC else {
        oa?.close(animated: true)
        break
      }
      oa?.close(fromRect: covc.imageView.frame, toRect: openedFromRect)
      break
    }
  }
  
  /// **Temp Vars openedFromRect**
  var openedFromRect = CGRect.zero
  // MARK: handleTap
  @objc func handleTap(sender: UITapGestureRecognizer){
    
    var openToRect : CGRect = .zero
    
    switch self.child {
    case .imageCollectionVC:
      self.oa = Overlay(overlay: childWithImageCollectionVC, into: self)
      guard let icv = childWithImageCollectionVC as? ImageCollectionVC else { break }
      icv.onX {
        self.handleCloseTap(sender: nil)
      }
      break;
    case .zoomedImageView:
      self.oa = Overlay(overlay: childVcWithZoomedImageView, into: self)
      guard let ziv = childVcChildOverlayVC.view.subviews[0] as? ZoomedImageView else { break }
      if sender.view == imageView {
        ziv.imageView.image = imageView.image
      }
      else if sender.view == imageView2 {
        ziv.imageView.image = imageView2.image
      }
      ziv.onX {
        self.handleCloseTap(sender: nil)
      }
      ziv.setNeedsLayout()
      ziv.layoutIfNeeded()
      self.oa?.overlaySize = ziv.imageView.frame.size
      openToRect = ziv.imageView.frame
      break;
    case .simpleImage:
      self.oa = Overlay(overlay: childVcChildOverlayVC, into: self)
      guard let covc = childVcChildOverlayVC as? ChildOverlayVC else { break }
      if sender.view == imageView {
        covc.imageView.image = imageView.image
      }
      else if sender.view == imageView2 {
        covc.imageView.image = imageView2.image
      }
      
      covc.view.frame = self.view.frame
      covc.view.setNeedsLayout()
      covc.view.layoutIfNeeded()
      self.oa?.overlaySize = covc.imageView.frame.size
      openToRect = covc.imageView.frame
      break;
    }
    
    if sender.view == imageView {
      openedFromRect = imageView.frame
    }
    else if sender.view == imageView2 {
      openedFromRect = imageView2.frame
    }
    switch self.appear {
    case .appearAnimated:
      oa?.open(animated: true, fromBottom: false)
      break
    case .appearFromBottom:
      oa?.open(animated: true, fromBottom: true)
      break
    case .appearWithoutAnimation:
      oa?.open(animated: false, fromBottom: false)
      break
    case .fromSourceFrame:
      oa?.openAnimated(fromFrame: openedFromRect, toFrame: openToRect)
      break
    }
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
