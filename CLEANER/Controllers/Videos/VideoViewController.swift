//
//  VideoViewController.swift
//  CLEANER
//
//  Created by admin on 22/09/2019.
//  Copyright © 2019 SangNX. All rights reserved.
//

import UIKit
import Photos

class Video {
    var size: Double! = 0
    var durartion: TimeInterval! = 0
    var asset: PHAsset!
    
    init() {
        
    }
    
    init(size: Double, duration: TimeInterval, asset: PHAsset) {
        self.size = size
        self.durartion = duration
        self.asset = asset
    }
}

enum TypeVideos: String {
    case M = "10-100M"
    case Other = "Other"
}

class VideoViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnDelete: UIButton!
    
    private lazy var results = [TypeVideos.M: [Video()],
                                TypeVideos.Other: [Video()]] as [TypeVideos : Array<Video>]
    private var imagesDelete = [IndexPath:PHAsset]()
    private var fetchResult: PHFetchResult<PHAsset>!
    private let imageManager = PHCachingImageManager()
    private var targetSize = CGSize(width: (Constant.SCREEN_WIDTH - 3)/3, height: (Constant.SCREEN_WIDTH - 3)/3)
    private var isSelectMutiple = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnDelete.layer.cornerRadius = 25
        btnDelete.clipsToBounds = true
        setUpCollectionView()
        getAllVideos()
    }

    private func getAllVideos() {
        PhotosHelper.getAlbums { PHAssetCollections in
            PHAssetCollections.forEach({ PHAssetCollection in
                if let localizedTitle = PHAssetCollection.localizedTitle, localizedTitle == "Videos" {                    PhotosHelper.getPHFetchResultAssetsFromAlbum(album: PHAssetCollection, { PHFetchResult in
                        self.fetchResult = PHFetchResult
                        self.results[TypeVideos.M]!.removeAll(); self.results[TypeVideos.Other]!.removeAll()
                        PHFetchResult.enumerateObjects({ (PHAsset, Int, UnsafeMutablePointer) in
                            let size = Double(self.fileSize(asset: PHAsset)/1000000)
                            if size > 10 {
                                self.results[TypeVideos.M]!.append(Video(size: size, duration: PHAsset.duration, asset: PHAsset))
                            } else {
                                self.results[TypeVideos.Other]!.append(Video(size: size, duration: PHAsset.duration, asset: PHAsset))
                            }
                        })
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    })
                }
            })
        }
    }
    
    private func setUpCollectionView() {
        collectionView.registerCollectionCell(ImageCell.self, fromNib: false)
        collectionView.register(SectionAlbumColViewCell.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionAlbumColViewCell.identifier)
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
    
    private func fileSize( asset: PHAsset) -> Int64 {
        let resources = PHAssetResource.assetResources(for: asset)
        var sizeOnDisk: Int64? = 0
        if let resource = resources.first {
            if let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong {
                sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64))
            }
        }
        return sizeOnDisk ?? 0
    }
    
    @IBAction func handleDeteteVideos(_ sender: UIButton) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(Array(self.imagesDelete.values) as NSFastEnumeration)
        }, completionHandler: {success, error in
            if success {
                DispatchQueue.main.async {
                    for indexP in Array(self.imagesDelete.keys) {
                        if indexP.section == 0 {
                            self.results[TypeVideos.M]?.remove(at: indexP.row)
                        } else {
                            self.results[TypeVideos.Other]?.remove(at: indexP.row)
                        }
                    }
                    self.collectionView.deleteItems(at: Array(self.imagesDelete.keys))
                    self.imagesDelete.removeAll()
                    self.btnDelete.alpha = 0
                }
            } else {
                print(error as Any)
                DispatchQueue.main.async {
                    self.btnDelete.alpha = 0
                }
            }
        })
    }
    
    private func playVideo() {

        //        let asset = results[indexPath.row]
        //        imageManager.requestAVAsset(forVideo: asset, options: PhotosHelper.defaultVideoFetchOptions) { (AVAsset, AVAudioMix, Data) in
        //            if let avAsset = AVAsset, let image = self.videoSnapshot(asset: avAsset) {
        //                DispatchQueue.main.async {
        //                    cell.image = image
        //                    cell.clipsToBounds = true
        //                    cell.viewCheck.isHidden = self.isSelectMutiple ? false : true
        //                }
        //            }
        //        }
    }
}

//MARK: UICollectionViewDataSource,UICollectionViewDelegateFlowLayout 's Method

extension VideoViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let videosM =  self.results[TypeVideos.M], let videosOther = self.results[TypeVideos.Other] {
            return section == 0 ? videosM.count : videosOther.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(ImageCell.self, indexPath: indexPath)
        if var videosM = self.results[TypeVideos.M], var videosOther = self.results[TypeVideos.Other] {
            let asset = indexPath.section == 0 ? videosM[indexPath.row].asset : videosOther[indexPath.row].asset
            if let asset = asset {
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: PhotosHelper.defaultImageFetchOptions) { (image, Data) in
                    guard let image: UIImage = image else { return }
                    cell.image = image
                    cell.clipsToBounds = true
                    cell.viewCheck.isHidden = self.isSelectMutiple ? false : true
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemPerRow: CGFloat = 3
        let widthCell: CGFloat = (collectionView.frame.width - itemPerRow)/itemPerRow
        return CGSize(width: widthCell, height: widthCell)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionAlbum = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionAlbumColViewCell.identifier, for: indexPath) as! SectionAlbumColViewCell
        sectionAlbum.lbl.textColor = .blue
        sectionAlbum.backgroundColor = .white
        if indexPath.section == 0 {
            sectionAlbum.lbl.text = TypeVideos.M.rawValue
        } else {
            sectionAlbum.lbl.text = TypeVideos.Other.rawValue
        }
        return sectionAlbum
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if var videosM = self.results[TypeVideos.M], var videosOther = self.results[TypeVideos.Other] {
            if let asset = indexPath.section == 0 ? videosM[indexPath.row].asset : videosOther[indexPath.row].asset {
                self.imagesDelete.updateValue(asset, forKey: indexPath)
                if (btnDelete.alpha == 0 && imagesDelete.count > 0) { btnDelete.alpha = 1 }
                btnDelete.setTitle("Delete " + String(imagesDelete.count) + " videos", for: UIControl.State.normal)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.imagesDelete.removeValue(forKey: indexPath)
        if (self.imagesDelete.count == 0) { btnDelete.alpha = 0 }
        btnDelete.setTitle("Delete " + String(imagesDelete.count) + " videos", for: UIControl.State.normal)
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
