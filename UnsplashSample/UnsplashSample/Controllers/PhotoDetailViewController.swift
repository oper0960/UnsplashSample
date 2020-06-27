//
//  PhotoDetailViewController.swift
//  UnsplashSample
//
//  Created by Gilwan Ryu on 2020/06/26.
//  Copyright © 2020 GilwanRyu. All rights reserved.
//

import UIKit

protocol PhotoDetailViewContollerDelegate: class {
    func close(indexPath: IndexPath)
}

class PhotoDetailViewController: UIViewController {
    static func instance() -> PhotoDetailViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoDetailViewController") as! PhotoDetailViewController
    }
    
    weak var delegate: PhotoDetailViewContollerDelegate?
    
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    var currentIndex: IndexPath = IndexPath(row: 0, section: 0) {
        didSet {
            self.photosCollectionView.scrollToItem(at: currentIndex, at: .centeredHorizontally, animated: false)
            self.titleLabel.text = self.photos[currentIndex.row].user.name
        }
    }
    
    var photos = [Photo]() {
        didSet {
            DispatchQueue.main.async {
                self.photosCollectionView.reloadData()
            }
        }
    }
    
    private var navigationBarHidden = false {
        didSet {
            if self.navigationBarHidden {
                UIView.animate(withDuration: 1, animations: {
                    self.navigationBarView.alpha = 0
                    self.setNeedsStatusBarAppearanceUpdate()
                }) { _ in
                    self.navigationBarView.isHidden = true
                }
            } else {
                UIView.animate(withDuration: 1, animations: {
                    self.navigationBarView.isHidden = false
                    self.navigationBarView.alpha = 1
                    self.setNeedsStatusBarAppearanceUpdate()
                })
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return self.navigationBarHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCollectionView()
    }
}

// MARK: - Network
extension PhotoDetailViewController {
    func setCollectionView() {
        self.photosCollectionView.delegate = self
        self.photosCollectionView.dataSource = self
    }
}

// MARK: - Button
extension PhotoDetailViewController {
    @IBAction func closeBtn(_ sender: UIButton) {
        self.delegate?.close(indexPath: self.currentIndex)
        self.dismiss(animated: true)
    }
    
    @IBAction func shareBtn(_ sender: UIButton) {
        // TODO
    }
}

// MARK: - CollectionView Delegate, Datesource, FlowLayout
extension PhotoDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let imageWidth = self.photos[indexPath.row].width
        let imageHeight = self.photos[indexPath.row].height
        let myViewWidth = UIScreen.main.bounds.width

        let ratio = myViewWidth / CGFloat(imageWidth)
        let scaledHeight = CGFloat(imageHeight) * ratio
        
        return CGSize(width: myViewWidth, height: scaledHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoDetailCell", for: indexPath) as! PhotoDetailCollectionViewCell
        photoCell.bind(photo: self.photos[indexPath.row])
        return photoCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.navigationBarHidden = !self.navigationBarHidden
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        var visibleRect = CGRect()

        visibleRect.origin = self.photosCollectionView.contentOffset
        visibleRect.size = self.photosCollectionView.bounds.size

        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)

        guard let indexPath = self.photosCollectionView.indexPathForItem(at: visiblePoint) else { return }

        self.currentIndex = indexPath
        self.titleLabel.text = self.photos[indexPath.row].user.name
    }
}
