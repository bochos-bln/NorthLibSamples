//
//  ImageCollectionVC.swift
//  NorthLibSamples
//
//  Created by Ringo Müller on 18.06.20.
//  Copyright © 2020 Ringo Müller. All rights reserved.
//

import Foundation
import UIKit
import NorthLib
class PhotoGridCVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  var oa: Overlay?
  var child = ChildOverlayVC()
  
  let reuseIdentifier = "imagecell" // also enter this string as the cell identifier in the storyboard
  var files = ["IMG_L_1", "IMG_L_2", "IMG_L_3", "IMG_L_4", "IMG_L_5", "IMG_L_6", "IMG_L_7", "IMG_L_8", "IMG_L_9", "IMG_L_10", "IMG_L_1", "IMG_L_2", "IMG_L_3", "IMG_L_4", "IMG_L_5", "IMG_L_6", "IMG_L_7", "IMG_L_8", "IMG_L_9", "IMG_L_10", "IMG_L_1", "IMG_L_2", "IMG_L_3", "IMG_L_4", "IMG_L_5", "IMG_L_6", "IMG_L_7", "IMG_L_8", "IMG_L_9", "IMG_L_10", "IMG_L_1", "IMG_L_2", "IMG_L_3", "IMG_L_4", "IMG_L_5", "IMG_L_6", "IMG_L_7", "IMG_L_8", "IMG_L_9", "IMG_L_10"]
  var collectionview : UICollectionView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Create an instance of UICollectionViewFlowLayout since you cant
    // Initialize UICollectionView without a layout
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    layout.minimumInteritemSpacing = 2
    layout.minimumLineSpacing = 2
    collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
    guard let collectionview = collectionview else { return }
    collectionview.dataSource = self
    collectionview.delegate = self
    collectionview.register(PhotoCViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    collectionview.showsVerticalScrollIndicator = false
    self.view.addSubview(collectionview)
    NorthLib.pin(collectionview, toSafe: self.view)
    
    oa = Overlay(overlay: child, into: self)
    oa?.shadeColor = .black
    oa?.maxAlpha = 0.99
    child.imageView.addTap(self, action: #selector(handleCloseTap))
  }
  
    @objc func handleCloseTap(sender: UITapGestureRecognizer){
      oa?.close(animated: true)
    }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    child.view.frame = self.view.frame
    child.view.setNeedsLayout()
    child.view.layoutIfNeeded()
  }
  
}


// MARK: - UICollectionViewDataSource
extension PhotoGridCVC {
  // tell the collection view how many cells to make
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.files.count
  }
  
  // make a cell for each cell index path
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    // get a reference to our storyboard cell
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! PhotoCViewCell
    
    cell.label.text = self.files[indexPath.item]
    
    if let filePath = Bundle.main.path(forResource: self.files[indexPath.item], ofType: "jpg") {
      cell.image = UIImage(contentsOfFile: filePath)
    }
    else {
      cell.image = UIImage()
    }
    
    return cell
  }
}


// MARK: - UICollectionViewDelegate
extension PhotoGridCVC {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // handle tap events
    print("You selected cell #\(indexPath.item)!")
    if let filePath = Bundle.main.path(forResource: self.files[indexPath.item], ofType: "jpg") {
         child.imageView.image = UIImage(contentsOfFile: filePath)
//      child.imageView.sizeToFit()
//      child.view.setNeedsLayout()
//      child.view.layoutIfNeeded()
//      child.imageView.setNeedsLayout()
//          child.imageView.layoutIfNeeded()
      child.view.setNeedsUpdateConstraints()
      child.view.updateFocusIfNeeded()
      }
   

    
    guard let cell = collectionView.cellForItem(at: indexPath)! as? PhotoCViewCell else {
      return
    }
    let sourceFrame = self.view.convert(cell.imageView.frame, from:cell)
    print("toframe:", child.imageView.frame)
    oa?.openAnimated(fromFrame: sourceFrame, toFrame: child.imageView.frame)
    
  }
}

class PhotoCViewCell : UICollectionViewCell{
  
  let label: UILabel = {
    let label = UILabel()
    label.textColor = .white
    label.textAlignment = .center
    label.font = .preferredFont(forTextStyle: .footnote)
    return label
  }()
  
  fileprivate let imageView: UIImageView = UIImageView()
  
  var image:UIImage? {
    get{return imageView.image}
    set{
      imageView.image = newValue
      guard let size = image?.size else {
        return
      }
      heightConstraint?.constant = size.height*itmWidth/size.width
    }
    
  }
  
  let itmWidth:CGFloat = 90
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  var heightConstraint : NSLayoutConstraint?
  
 
  
  func setupViews(){
    imageView.contentMode = .scaleAspectFit
    imageView.clipsToBounds = true
    imageView.pinWidth(itmWidth)
    heightConstraint = imageView.pinHeight(itmWidth)
    imageView.autoresizesSubviews = true
    contentView.addSubview(imageView)
    contentView.addSubview(label)
    NorthLib.pin(imageView.top, to: contentView.top)
    NorthLib.pin(imageView.left, to: contentView.left).priority = UILayoutPriority(rawValue: 600)
    NorthLib.pin(imageView.right, to: contentView.right).priority = UILayoutPriority(rawValue: 600)
    NorthLib.pin(label.left, to: contentView.left)
    NorthLib.pin(label.right, to: contentView.right)
    NorthLib.pin(label.bottom, to: contentView.bottom)
    NorthLib.pin(imageView.bottom, to: contentView.bottom, dist: -15.0).priority = UILayoutPriority(rawValue: 600)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
