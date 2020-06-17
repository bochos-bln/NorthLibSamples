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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let filePath = Bundle.main.path(forResource: "IMG_L", ofType: "jpg") {
      image = UIImage(contentsOfFile: filePath)
    }
    imageView.image = image
    imageView.contentMode = .scaleAspectFit
    self.view.addSubview(imageView)
    NorthLib.pin(imageView, toSafe: self.view)
    

    tap.addTarget(self, action: #selector(handleTap))
    imageView.addGestureRecognizer(tap)
    imageView.isUserInteractionEnabled = true
  }
  
  // MARK: Single Tap
  @objc func handleTap(sender: UITapGestureRecognizer){
    if let nc = self.navigationController {
      nc.pushViewController(ChildOverlayVC(), animated: true)
    }
  }
}


class ChildOverlayVC: UIViewController {
  
  var image: UIImage?
  var imageView = UIImageView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let filePath = Bundle.main.path(forResource: "IMG_S", ofType: "jpg") {
      image = UIImage(contentsOfFile: filePath)?.withTintColor(UIColor.red.withAlphaComponent(0.5))
    }
    imageView.image = image
    imageView.contentMode = .scaleAspectFit
    self.view.addSubview(imageView)
    NorthLib.pin(imageView, toSafe: self.view, dist: 30)
  }
  
}
