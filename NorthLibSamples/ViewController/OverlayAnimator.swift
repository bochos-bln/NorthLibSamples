////
////  OverlayAnimator.swift
////  NorthLib
////
////  Created by Ringo Müller on 17.06.20.
////  Copyright © 2020 Norbert Thies. All rights reserved.
////
//
import Foundation
import NorthLib
/**
The Overlay class manages the two view controllers 'overlay' and 'active'.
'active' is currently visible and 'overlay' will be presented on top of
'active'. To accomplish this, two views are created, the first one, 'shadeView'
is positioned on top of 'active.view' with the same size and colored 'shadeColor'
with an alpha between 0...maxAlpha. This view is used to shade the active view
controller during the open/close animations. The second view, overlayView is
used to contain 'overlay' and is animated during opening and closing operations.
In addition two gesture recognizers (pinch and pan) are used on shadeView to
start the close animation. The pan gesture is used to move the overlay to the bottom of shadeView.
 The pinch gesture is used to shrink the overlay
in size while being centered in shadeView. When 'overlay' has been shrunk to
'closeRatio' (see attribute) or moved 'closeRatio * overlayView.bounds.size.height'
points to the bottom then 'overlay' is animated automatically away from the
screen. While the gesture recognizers are working or during the animation the
alpha of shadeView is changed to reflect the animation's ratio (alpha = 0 =>
'overlay' is no longer visible). The gesture recognizers coexist with gesture
recognizers being active in 'overlay'.
*/
/**
 This Class is the container and holds the both VC's
 presentation Process: UIViewControllerContextTransitioning?? or simply
 =====
 ToDo List
 ======
 X Calling VC's
 O add ZoomableImageVC for Pinch Gesture
 O OverlaySpec
    O=> var shadeView: UIView = UIView()
    X=> var overlayView: UIView = UIView()
    X=> var overlayVC: UIViewController
    X=> var activeVC: UIViewController//LATER SELF!!
    ?=> var overlaySize: CGSize?
    ?=> var maxAlpha: Double = 1.0
    O=> var shadeColor: UIColor = UIColor.red
    O=> var closeRatio: CGFloat = 0.5
 X Konzept => ViewAnimation nicht via UIViewControllerTransitionDelegate
         => da reine View Animationen abgesprochen waren & höhere Komplexität
 X implement Appear from Bottom
 X implement appear from different View (Appear Animated needs to know which View)
    X=> shrink parent to new & fade look ugly!
    X=> passed the view for the moment
    O=> view Frame in Source FRame
 O implement Pan to close
    O=>wrapper holds a scrollview
    O=> scrollview contain overlayview
    O=> scrollview handles pan
    O=> scrollview handles pinch
 O pinch to Close
?O next/upcomming
 
 
 */
// MARK: - UIScrollViewDelegate
extension OverlayAnimator{
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    print("Scrolling")
  }
}

class OverlayAnimator: NSObject, OverlaySpec, UIScrollViewDelegate, UIGestureRecognizerDelegate{
  
  var shadeView: UIView = UIView()
  var overlayView: UIScrollView = UIScrollView()
  var wrapper: UIView = UIView()
  
  var overlayVC: UIViewController
  var activeVC: UIViewController//LATER SELF!!
  
  
  
  var overlaySize: CGSize?
  
  var maxAlpha: Double = 1.0
  
  var shadeColor: UIColor = .clear
  
  var closeRatio: CGFloat = 0.5
  
  required init(overlay: UIViewController, into active: UIViewController) {
    overlayVC = overlay
    activeVC = active
    super.init()
    overlayView.delegate = self
  }
  
  func close(animated: Bool) {
    print("todo close")
    wrapper.removeFromSuperview()
  }
  
  
  func open(animated: Bool, fromBottom: Bool) {
    guard let fromSnapshot = activeVC.view.snapshotView(afterScreenUpdates: true) else {
      print("cannot open due no snapshot is possible may TODo if non animated!")
      return
    }
    fromSnapshot.layer.masksToBounds = true
    
    guard let targetSnapshot = overlayVC.view.snapshotView(afterScreenUpdates: true) else {
      print("cannot open due target snapshot is possible may TODo if non animated!")
      return
    }
    
    wrapper = UIView(frame: activeVC.view.frame)
    shadeView = UIView(frame: CGRect(origin: .zero, size: wrapper.frame.size))
    shadeView.backgroundColor = shadeColor
    self.shadeView.alpha = 0
    
    var fromFrame : CGRect = activeVC.view.frame
    fromFrame.origin.y = fromFrame.size.height + fromFrame.origin.y
    targetSnapshot.frame = fromFrame
    
    wrapper.addSubview(shadeView)
    
    wrapper.addSubview(fromSnapshot)
    wrapper.addSubview(targetSnapshot)
    
    
    targetSnapshot.alpha = 0.0
    activeVC.view.addSubview(wrapper)

    UIView.animate(withDuration: 2.2, animations: {
      var toFrame = targetSnapshot.frame
      toFrame.origin.y = 0
      targetSnapshot.frame = toFrame
      fromSnapshot.alpha = 0.0
      targetSnapshot.alpha = 1.0
      self.shadeView.alpha = CGFloat(self.maxAlpha)
      
    }) { (success) in
      self.wrapper.addSubview(self.overlayVC.view)
      fromSnapshot.removeFromSuperview()
      targetSnapshot.removeFromSuperview()
    }
  }
  var startY:CGFloat = 0.0
  @objc func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
    if gestureRecognizer.state == .began {
      startY = self.overlayVC.view.frame.origin.y
    }
    
//    let anchorPoint = CGPoint(x: fromReferenceImageViewFrame.midX, y: fromReferenceImageViewFrame.midY)
    
    let translatedPoint = gestureRecognizer.translation(in: wrapper)
    let verticalDelta : CGFloat = translatedPoint.y < 0 ? 0 : translatedPoint.y
    self.overlayVC.view.frame.origin.y = verticalDelta
    print("pan:", verticalDelta, (100-verticalDelta), gestureRecognizer.state.rawValue, startY, wrapper.frame )
    wrapper.alpha = max(0,(100-verticalDelta))/100
    if gestureRecognizer.state == .ended {
      if wrapper.alpha < 0.5 {
        self.close(animated: false)
      }
      else {
        UIView.animate(seconds: 0.3) {
          self.overlayVC.view.frame.origin.y = self.startY
          self.wrapper.alpha = 1.0
        }
      }
      
    }
//    self.overlayVC.view = shadeView.alpha

//    let backgroundAlpha = backgroundAlphaFor(view: fromVC.view, withPanningVerticalDelta: verticalDelta)
//    let scale = scaleFor(view: fromVC.view, withPanningVerticalDelta: verticalDelta)
//
//    fromVC.view.alpha = backgroundAlpha
    
  }
  
  func openAnimated(fromFrame: CGRect, toFrame: CGRect) {
    guard let fromSnapshot = activeVC.view.resizableSnapshotView(from: fromFrame, afterScreenUpdates: false, withCapInsets: .zero) else {
      print("cannot open due no fromsnapshot is possible may TODo if non animated!")
      return
    }
//    overlayVC.view.alpha = 0
    activeVC.presentSubVC(controller: overlayVC, inView: activeVC.view)
    
    fromSnapshot.layer.masksToBounds = true
    fromSnapshot.frame = fromFrame
    
    guard let targetSnapshot = overlayVC.view.snapshotView(afterScreenUpdates: true) else {
      print("cannot open due target snapshot is possible may TODo if non animated!")
      return
    }
    
    wrapper = UIView(frame: activeVC.view.frame)
    let panGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                      action: #selector(didPanWith(gestureRecognizer:)))
//    panGestureRecognizer.delegate = self
    wrapper.addGestureRecognizer(panGestureRecognizer)
    
//    wrapper.backgroundColor = .black //ToDo otherwise looks ugly!
    shadeView = UIView(frame: CGRect(origin: .zero, size: wrapper.frame.size))
    shadeView.backgroundColor = shadeColor
    self.shadeView.alpha = 0
    
    wrapper.addSubview(shadeView)
    wrapper.addSubview(fromSnapshot)
    wrapper.addSubview(targetSnapshot)
    
    ///Debug
    fromSnapshot.layer.borderColor = UIColor.red.cgColor
    fromSnapshot.layer.borderWidth = 2.0
    
    targetSnapshot.alpha = 0.0
    activeVC.view.addSubview(wrapper)
    print("fromSnapshot.frame:", fromSnapshot.frame)
    print("targetSnapshot.frame:", toFrame)
        
    UIView.animateKeyframes(withDuration: 0.4, delay: 0, animations: {
      UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.3) {
                      self.shadeView.alpha = CGFloat(self.maxAlpha)
                }
      UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.7) {
                  fromSnapshot.frame = toFrame
               }
      
      UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.4) {
                 fromSnapshot.alpha = 0.0
               }
      UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.3) {
                 targetSnapshot.alpha = 1.0
               }
      
    }) { (success) in
      self.wrapper.addSubview(self.overlayVC.view)
//      self.wrapper.backgroundColor = .clear
      fromSnapshot.removeFromSuperview()
      targetSnapshot.removeFromSuperview()
    }
  }
  

  func shrinkTo(rect: CGRect) {
    print("todo shrinkTo rect")
  }
  
  func shrinkTo(targetView: UIView) {
    print("todo shrinkTo view")
  }
}
