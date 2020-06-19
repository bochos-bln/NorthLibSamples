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
class OverlayAnimator: OverlaySpec{
  
  var shadeView: UIView = UIView()
  var overlayView: UIView = UIView()
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
  
  
  func openAnimated(fromFrame: CGRect, toFrame: CGRect) {
    guard let fromSnapshot = activeVC.view.resizableSnapshotView(from: fromFrame, afterScreenUpdates: false, withCapInsets: .zero) else {
      print("cannot open due no fromsnapshot is possible may TODo if non animated!")
      return
    }
    fromSnapshot.layer.masksToBounds = true
    fromSnapshot.frame = fromFrame
    
    guard let targetSnapshot = overlayVC.view.snapshotView(afterScreenUpdates: true) else {
      print("cannot open due target snapshot is possible may TODo if non animated!")
      return
    }
    
    wrapper = UIView(frame: activeVC.view.frame)
//    wrapper.backgroundColor = .black //ToDo otherwise looks ugly!
    shadeView = UIView(frame: CGRect(origin: .zero, size: wrapper.frame.size))
    shadeView.backgroundColor = shadeColor
    self.shadeView.alpha = 0
    
    wrapper.addSubview(shadeView)
    wrapper.addSubview(fromSnapshot)
    wrapper.addSubview(targetSnapshot)
    
    ///Debug
//    fromSnapshot.layer.borderColor = UIColor.red.cgColor
//    fromSnapshot.layer.borderWidth = 2.0
    
    targetSnapshot.alpha = 0.0
    activeVC.view.addSubview(wrapper)
    print("fromSnapshot.frame:", fromSnapshot.frame)
        
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
