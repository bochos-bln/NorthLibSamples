//
//  ZoomableImageViewController.swift
//  NorthLibSamples
//
//  Created by Ringo Müller on 27.05.20.
//  Copyright © 2020 Ringo Müller. All rights reserved.
//

import UIKit
import NorthLib


class ZoomableImageViewController: UIViewController {
  
  var detailImage: UIImage?
  var previewImage: UIImage?
  var optionalImage: OptionalImage = OptionalImageItem()
  let simulateDownload = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let filePath = Bundle.main.path(forResource: "IMG_M", ofType: "jpg") {
      detailImage = UIImage(contentsOfFile: filePath)
    }
    
    if let filePath = Bundle.main.path(forResource: "IMG_XS", ofType: "jpg") {
      previewImage = UIImage(contentsOfFile: filePath)
    }
    
    //    optionalImage.image = detailImage
    optionalImage.waitingImage = previewImage
    
    let zView = ZoomedImageView(optionalImage: optionalImage)
    zView.onX {
      print("Close")
    }
    zView.onHighResImgNeeded(zoomFactor: 1.4) { (optionalImage, callback) in
      print("  zView.onHighResImgNeeded")
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        if let filePath = Bundle.main.path(forResource: "IMG_XL", ofType: "jpg") {
          self.optionalImage.image = UIImage(contentsOfFile: filePath)
          callback(true)
        } else {
          callback(false)
        }
      }
    }
    self.view = zView
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    //Set Detail Image after Delay to Simulate Download
    DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
      print("Exchanged!")
      self.optionalImage.image = self.detailImage
    }
    /* Test #2 2nd Exchange, not required but seems to work
     DispatchQueue.main.asyncAfter(deadline: .now() + 12.5) {
     if let detailImageFilePath = Bundle.main.path(forResource: "IMG_XL",
     ofType: "jpg"),
     let optionalImage = self.optionalImage {
     print("Exchanged #2!")
     optionalImage.image = UIImage(contentsOfFile: detailImageFilePath)
     }
     }
     */
  }
}
