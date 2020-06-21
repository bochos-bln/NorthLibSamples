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
extension Overlay{
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    print("Scrolling")
  }
}


// MARK: - OverlayAnimator
class Overlay: NSObject, OverlaySpec, UIScrollViewDelegate, UIGestureRecognizerDelegate {
  private var openDuration: Double = 0.4 //usually 0.4-0.5
  private var closeDuration: Double = 0.25//
  private var debug = false
  
  var shadeView: UIView?
  let overlayView: UIScrollView = UIScrollView()
  
  var overlayVC: UIViewController
  var activeVC: UIViewController//LATER SELF!!
  var overlaySize: CGSize?
  var maxAlpha: Double = 0.8
  var shadeColor: UIColor = .black
  var closeRatio: CGFloat = 0.5 {
    didSet {
      //Prevent math issues
      if closeRatio > 1.0 { closeRatio = 1.0 }
      if closeRatio < 0.1 { closeRatio = 0.1 }
    }
  }
  // MARK: - init
  required init(overlay: UIViewController, into active: UIViewController) {
    overlayVC = overlay
    activeVC = active
    super.init()
    overlayView.delegate = self
    /// add the pan
    let panGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                      action: #selector(didPanWith(gestureRecognizer:)))
    overlayView.addGestureRecognizer(panGestureRecognizer)
  }
  // MARK: - close
  func close(animated: Bool) {
    close(animated: animated, toBottom: false)
  }
  // MARK: - close to bottom
  func close(animated: Bool, toBottom: Bool = false) {
    if animated == false {
      removeFromActiveVC()
      return;
    }
    UIView.animate(withDuration: closeDuration, animations: {
      self.shadeView?.alpha = 0
      self.overlayView.alpha = 0
      self.overlayVC.view.frame.origin.y
        = CGFloat(self.shadeView?.frame.size.height ?? 0.0)
    }, completion: { _ in
      self.removeFromActiveVC()
      self.overlayView.alpha = 1
    })
  }
  
  // MARK: - addToActiveVC
  func addToActiveVC(){
    ///ensure not presented anymore
    if overlayVC.view.superview != nil { removeFromActiveVC()}
    /// config the shade layer
    shadeView = UIView(frame: activeVC.view.frame)
    shadeView?.backgroundColor = shadeColor
    shadeView!.alpha = 0.0
    activeVC.view.addSubview(shadeView!)
    ///configure the overlay vc (TBD::may also create a new one?!)
    overlayView.alpha = 1.0
    overlayView.frame = activeVC.view.frame
    overlayView.clipsToBounds = true
    overlayView.addSubview(overlayVC.view)
    ///configure the overlay vc and add as child vc to active vc
    overlayVC.view.frame = activeVC.view.frame
    overlayVC.willMove(toParent: activeVC)
    activeVC.view.addSubview(overlayView)
    overlayVC.didMove(toParent: activeVC)
  }
  
  // MARK: - removeFromActiveVC
  func removeFromActiveVC(){
    shadeView?.removeFromSuperview()
    shadeView = nil
    overlayVC.view.removeFromSuperview()
    overlayView.removeFromSuperview()
  }
  
  private func showWithoutAnimation(){
    addToActiveVC()
    self.overlayVC.view.isHidden = false
    shadeView?.alpha = CGFloat(self.maxAlpha)
  }
  
  // MARK: - open animated
  func open(animated: Bool, fromBottom: Bool) {
    guard animated,
      let targetSnapshot
      = overlayVC.view.snapshotView(afterScreenUpdates: true) else {
        showWithoutAnimation()
        return
    }

    addToActiveVC()
    targetSnapshot.alpha = 0.0
   
    if fromBottom {
      targetSnapshot.frame = activeVC.view.frame
      targetSnapshot.frame.origin.y += targetSnapshot.frame.size.height
    }
    
    overlayVC.view.isHidden = true
    overlayView.addSubview(targetSnapshot)
    shadeView?.alpha = 0.0
    UIView.animate(withDuration: openDuration, animations: {
      if fromBottom {
        targetSnapshot.frame.origin.y = 0
      }
      self.shadeView?.alpha = CGFloat(self.maxAlpha)
      targetSnapshot.alpha = 1.0
    }) { (success) in
      self.overlayVC.view.isHidden = false
      targetSnapshot.removeFromSuperview()
    }
  }
  
  // MARK: - didPanWith
  var panStartY:CGFloat = 0.0
  @objc func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
    let translatedPoint = gestureRecognizer.translation(in: overlayView)
    
    if gestureRecognizer.state == .began {
      panStartY = gestureRecognizer.location(in: overlayView).y
                  + translatedPoint.y
    }
   
    self.overlayVC.view.frame.origin.y = translatedPoint.y > 0 ? translatedPoint.y : translatedPoint.y*0.4
    self.overlayVC.view.frame.origin.x = translatedPoint.x*0.4
    let p = translatedPoint.y/(overlayView.frame.size.height-panStartY)
    if translatedPoint.y > 0 {
      self.shadeView?.alpha = max(0, min(1-p, CGFloat(self.maxAlpha)))
    }

    if gestureRecognizer.state == .ended {
      if self.shadeView?.alpha ?? 1.0 < (1 - closeRatio) {
        self.close(animated: true, toBottom: true)
      }
      else {
        UIView.animate(seconds: closeDuration) {
          self.overlayVC.view.frame.origin = .zero
          self.shadeView?.alpha = CGFloat(self.maxAlpha)
        }
      }
      
    }
  }
    
   // MARK: - open fromFrame
  func openAnimated(fromFrame: CGRect, toFrame: CGRect) {
    guard let fromSnapshot = activeVC.view.resizableSnapshotView(from: fromFrame, afterScreenUpdates: false, withCapInsets: .zero) else {
      showWithoutAnimation()
      return
    }
    guard let targetSnapshot = overlayVC.view.snapshotView(afterScreenUpdates: true) else {
       showWithoutAnimation()
       return
     }

    addToActiveVC()
    targetSnapshot.alpha = 0.0

    if debug {
      overlayView.layer.borderColor = UIColor.green.cgColor
      overlayView.layer.borderWidth = 2.0
      
      fromSnapshot.layer.borderColor = UIColor.red.cgColor
      fromSnapshot.layer.borderWidth = 2.0
      
      targetSnapshot.layer.borderColor = UIColor.blue.cgColor
      targetSnapshot.layer.borderWidth = 2.0
      
      self.overlayVC.view.layer.borderColor = UIColor.orange.cgColor
      self.overlayVC.view.layer.borderWidth = 2.0

      print("fromSnapshot.frame:", fromSnapshot.frame)
      print("targetSnapshot.frame:", toFrame)
    }


    
    fromSnapshot.layer.masksToBounds = true
    fromSnapshot.frame = fromFrame

    overlayView.addSubview(fromSnapshot)
    overlayView.addSubview(targetSnapshot)
    
    UIView.animateKeyframes(withDuration: openDuration, delay: 0, animations: {
      UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.3) {
                      self.shadeView?.alpha = CGFloat(self.maxAlpha)
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
      self.overlayVC.view.isHidden = false
      targetSnapshot.removeFromSuperview()
      targetSnapshot.removeFromSuperview()
    }
  }
  
   // MARK: - shrinkTo rect
  func shrinkTo(rect: CGRect) {
    close(fromRect: overlayVC.view.frame, toRect: rect)
  }
   // MARK: - shrinkTo targetView
  func shrinkTo(targetView: UIView) {
    if !targetView.isDescendant(of: activeVC.view) {
      self.close(animated: true)
      return;
    }
    close(fromRect: overlayVC.view.frame, toRect: activeVC.view.convert(targetView.frame, from: targetView))
  }
  
   // MARK: - close fromRect toRect
  func close(fromRect: CGRect, toRect: CGRect) {
    guard let overlaySnapshot = overlayVC.view.resizableSnapshotView(from: fromRect, afterScreenUpdates: false, withCapInsets: .zero) else {
      self.close(animated: true)
      return
    }
    
    if debug {
      print("todo close fromRect", fromRect, "toRect", toRect)
      overlaySnapshot.layer.borderColor = UIColor.magenta.cgColor
      overlaySnapshot.layer.borderWidth = 2.0
    }
    
    overlaySnapshot.frame = fromRect
    overlayView.addSubview(overlaySnapshot)

    UIView.animateKeyframes(withDuration: closeDuration, delay: 0, animations: {
      UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.4) {
        self.overlayVC.view.alpha = 0.0
      }
      UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.7) {
        overlaySnapshot.frame = toRect
        
      }
      UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.3) {
        overlaySnapshot.alpha = 0.0
      }
      UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1) {
        self.shadeView?.alpha = 0.0
      }
    }) { (success) in
      self.removeFromActiveVC()
      self.overlayView.alpha = 1.0
      self.overlayVC.view.alpha = 1.0
    }
    
  }
}
