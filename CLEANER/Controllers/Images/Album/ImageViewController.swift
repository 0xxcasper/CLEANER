//
//  ImageViewController.swift
//  CLEANER
//
//  Created by admin on 22/09/2019.
//  Copyright © 2019 SangNX. All rights reserved.
//

import UIKit
import Photos

enum Album: String {
    case Same = "Same"
    case Action = "Action"
}

enum TypeAlbum: String {
    case All = "All Photos"
    case Selfies = "Selfies"
    case Favorites = "Favorites"
    case Screenshots = "Screenshots"
    case Gif = "Gif"
    case Live = "Live Photos"
}

class ImageViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var data = [Album.Same: [TypeAlbum.All: PHFetchResult<PHAsset>(), TypeAlbum.Selfies: PHFetchResult<PHAsset>(),TypeAlbum.Favorites: PHFetchResult<PHAsset>(), TypeAlbum.Screenshots: PHFetchResult<PHAsset>()],
                        Album.Action: [TypeAlbum.Gif: PHFetchResult<PHAsset>(), TypeAlbum.Live: PHFetchResult<PHAsset>()]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllImageFromGallary()
        getAllAlbums()
    }
    
    private func setUpCollectionView() {
        collectionView.registerXibCell(AlbumCollectionViewCell.self)
        collectionView.register(SectionAlbumColViewCell.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionAlbumColViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension ImageViewController
{
    private func getAllAlbums(){
        PhotosHelper.getAlbums { PHAssetCollections in
            PHAssetCollections.forEach({ PHAssetCollection in
                if let localizedTitle = PHAssetCollection.localizedTitle {
                    switch localizedTitle {
                    case TypeAlbum.Selfies.rawValue:
                        self.getAmoutPhotosOfAlbum(album: Album.Same, type: TypeAlbum.Selfies, ph: PHAssetCollection)
                    case TypeAlbum.Favorites.rawValue:
                        self.getAmoutPhotosOfAlbum(album: Album.Same, type: TypeAlbum.Favorites, ph: PHAssetCollection)
                    case TypeAlbum.Screenshots.rawValue:
                        self.getAmoutPhotosOfAlbum(album: Album.Same, type: TypeAlbum.Screenshots, ph: PHAssetCollection)
                    case TypeAlbum.Live.rawValue:
                        self.getAmoutPhotosOfAlbum(album: Album.Action, type: TypeAlbum.Live, ph: PHAssetCollection)
                    default:
                        break
                    }
                }
            })
        }
    }
    
    private func getAllImageFromGallary(){
        PhotosHelper.getAllPHFetchResultAssets { PHFetchResult in
            self.data[Album.Same]![TypeAlbum.All] = PHFetchResult
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    private func getAmoutPhotosOfAlbum( album: Album, type: TypeAlbum, ph: PHAssetCollection) {
        PhotosHelper.getPHFetchResultAssetsFromAlbum(album: ph, { PHFetchResult in
            self.data[album]![type] = PHFetchResult
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        })
    }
}

extension ImageViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? data[Album.Same]!.count : data[Album.Action]!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(AlbumCollectionViewCell.self, indexPath: indexPath)
        cell.addShadow(ofColor: .black, radius: 5, offset: .zero, opacity: 0.3)
        let key = indexPath.section == 0 ? Array(data[Album.Same]!.keys)[indexPath.row] : Array(data[Album.Action]!.keys)[indexPath.row]
        cell.lblName.text = key.rawValue
        cell.lblAmout.text = indexPath.section == 0 ? String(data[Album.Same]![key]!.count) : String(data[Album.Action]![key]!.count)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectPhotoVC = SelectPhotoViewController()
        let key = indexPath.section == 0 ? Array(data[Album.Same]!.keys)[indexPath.row] : Array(data[Album.Action]!.keys)[indexPath.row]
        selectPhotoVC.fetchResult = indexPath.section == 0 ? data[Album.Same]![key] : data[Album.Action]![key]
        self.navigationController?.pushViewController(selectPhotoVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionAlbum = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionAlbumColViewCell.identifier, for: indexPath) as! SectionAlbumColViewCell
        if indexPath.section == 0 {
            sectionAlbum.lbl.text = Album.Same.rawValue
        } else {
            sectionAlbum.lbl.text = Album.Action.rawValue
        }
        return sectionAlbum
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width/2 - 16 - 8), height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}
