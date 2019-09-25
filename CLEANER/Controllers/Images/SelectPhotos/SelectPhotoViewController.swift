//
//  SelectPhotoViewController.swift
//  CLEANER
//
//  Created by admin on 22/09/2019.
//  Copyright © 2019 SangNX. All rights reserved.
//

import UIKit
import Photos

class SelectPhotoViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnDelete: UIButton!
    
    var fetchResult: PHFetchResult<PHAsset>!
    var isLocation: Bool! = false
    var phCollections: [PHAssetCollection]!
    
    private var results = [PHAsset]()
    private var imagesDelete = [IndexPath:PHAsset]()
    private let imageManager = PHCachingImageManager()
    private var targetSize = CGSize(width: (Constant.SCREEN_WIDTH - 3)/3, height: (Constant.SCREEN_WIDTH - 3)/3)
    private var isSelectMutiple = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !isLocation {
            self.fetchResult.enumerateObjects({ (PHAsset, Int, UnsafeMutablePointer) in
                self.results.append(PHAsset)
            })
        } else {
            phCollections.forEach { (PHAssetCollection) in
                PhotosHelper.getPHFetchResultAssetsFromAlbum(album: PHAssetCollection, { PHFetchResult in
                    PHFetchResult.enumerateObjects({ (PHAsset, Int, UnsafeMutablePointer) in
                        self.results.append(PHAsset)
                    })
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                })
            }
        }
        btnDelete.layer.cornerRadius = 25
        btnDelete.clipsToBounds = true
        setUpCollectionView()
    }
    
    private func setUpCollectionView() {
        collectionView.registerCollectionCell(ImageCell.self, fromNib: false)
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 1
            layout.minimumInteritemSpacing = 1
            layout.sectionHeadersPinToVisibleBounds = true
        }
        collectionView.allowsMultipleSelection = true
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    @IBAction func hanldeDeletePhotos(_ sender: UIButton) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(Array(self.imagesDelete.values) as NSFastEnumeration)
        }, completionHandler: {success, error in
            if success {
                DispatchQueue.main.async {
                    for indexP in Array(self.imagesDelete.keys) {
                        self.results.remove(at: indexP.row)
                    }
                    self.collectionView.deleteItems(at: Array(self.imagesDelete.keys))
                    self.imagesDelete.removeAll()
                    self.btnDelete.alpha = 0
                }
            } else {
                print(error as Any)
            }
        })
    }
}

//MARK: UICollectionViewDataSource,UICollectionViewDelegateFlowLayout 's Method

extension SelectPhotoViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(ImageCell.self, indexPath: indexPath)
        let asset = results[indexPath.row]
        imageManager.requestImage(for: asset, targetSize: self.targetSize, contentMode: .aspectFill, options: PhotosHelper.defaultImageFetchOptions, resultHandler: { image, _ in
            guard let image: UIImage = image else { return }
            cell.image = image
            cell.clipsToBounds = true
            cell.viewCheck.isHidden = self.isSelectMutiple ? false : true
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemPerRow: CGFloat = 3
        let widthCell: CGFloat = (collectionView.frame.width - itemPerRow)/itemPerRow
        return CGSize(width: widthCell, height: widthCell)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = results[indexPath.row]
        self.imagesDelete.updateValue(asset, forKey: indexPath)
        if (btnDelete.alpha == 0 && imagesDelete.count > 0) { btnDelete.alpha = 1 }
        btnDelete.setTitle("Delete " + String(imagesDelete.count) + " photos", for: UIControl.State.normal)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.imagesDelete.removeValue(forKey: indexPath)
        if (self.imagesDelete.count == 0) { btnDelete.alpha = 0 }
        btnDelete.setTitle("Delete " + String(imagesDelete.count) + " photos", for: UIControl.State.normal)
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        DispatchQueue.main.async {
            self.imageManager.startCachingImages(for: indexPaths.map{ self.fetchResult.object(at: $0.item) }, targetSize: self.targetSize, contentMode: .aspectFill, options: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        DispatchQueue.main.async {
            self.imageManager.stopCachingImages(for: indexPaths.map{ self.fetchResult.object(at: $0.item) }, targetSize: self.targetSize, contentMode: .aspectFill, options: nil)
        }
    }
}
