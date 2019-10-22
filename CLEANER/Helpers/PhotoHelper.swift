//
//  PhotosHelper.swift
//  Instagram
//
//  Created by QUỐC on 4/8/19.
//  Copyright © 2019 QUỐC. All rights reserved.
//

//-->https://github.com/DroidsOnRoids/PhotosHelper/blob/master/PhotosHelper.swift<--//
import Foundation
import Photos
import UIKit

public enum AssetFetchResult<T> {
    case Assets([T])
    case Asset(T)
    case Error
}

public struct PhotosHelper {
    
    public struct FetchOptions {
        
        public var count: Int
        public var newestFirst: Bool
        public var size: CGSize?
        
        public init() {
            self.count = 0
            self.newestFirst = true
            self.size = nil
        }
    }
    
    public static var defaultImageFetchOptions: PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.version = .original
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .none
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        return options
    }
    
    public static var defaultVideoFetchOptions: PHVideoRequestOptions {
        let options = PHVideoRequestOptions()
        options.version = .original
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        return options
    }
    
    static func getAlbum(named: String, completion: @escaping(_ album: PHAssetCollection?) -> ()) {
        DispatchQueue.global(qos: .background).async {
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "localizedTitle = %@", named)
            let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            if let album = collections.firstObject {
                completion(album)
            } else {
                PhotosHelper.createAlbum(named: named) { album in
                    completion(album)
                }
            }
        }
    }
    
    static func createAlbum(named: String, completion: @escaping (_ album: PHAssetCollection?) -> ()) {
        var placeholder: PHObjectPlaceholder?
        
        PHPhotoLibrary.shared().performChanges({
            let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: named)
            placeholder = createAlbumRequest.placeholderForCreatedAssetCollection
        }) { success, error in
            var album: PHAssetCollection?
            if success {
                let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder?.localIdentifier ?? ""], options: nil)
                album = collectionFetchResult.firstObject
            }
            completion(album)
        }
    }
    
    static func getAssetsFromAlbum(album: PHAssetCollection, fetchOptions: FetchOptions = FetchOptions(), completion: @escaping (_ result: AssetFetchResult<PHAsset>) -> ()) {
        DispatchQueue.global(qos: .background).async {
            let assetsFetchOptions = PHFetchOptions()
            assetsFetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: !fetchOptions.newestFirst)]
            var assets = [PHAsset]()
            let fetchedAssets = PHAsset.fetchAssets(in: album, options: assetsFetchOptions)
            let rangeLength = min(fetchedAssets.count, fetchOptions.count)
            let range = NSRange(location: 0, length: fetchOptions.count != 0 ? rangeLength : fetchedAssets.count)
            let indexes = NSIndexSet(indexesIn: range)
            fetchedAssets.enumerateObjects(at: indexes as IndexSet, options: []) { asset, index, stop in
                assets.append(asset)
            }
            completion(.Assets(assets))
        }
    }
    
    static func getPHFetchResultAssetsFromAlbum(album: PHAssetCollection,_ completion: @escaping (_ result: PHFetchResult<PHAsset>) -> ()) {
        DispatchQueue.global(qos: .background).async {
            let assetsFetchOptions = PHFetchOptions()
            assetsFetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let fetchedAssets = PHAsset.fetchAssets(in: album, options: assetsFetchOptions)
            completion(fetchedAssets)
        }
    }
    
    static func getAllPHFetchResultAssets(_ completion: @escaping (_ result: PHFetchResult<PHAsset>) -> ()) {
        DispatchQueue.global(qos: .background).async {
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let allPhotos = PHAsset.fetchAssets(with: .image, options: options)
            completion(allPhotos)
        }
    }
    
    static func getAlbums(completion:@escaping (_ albums: Set<PHAssetCollection>) -> ()) {
        DispatchQueue.global(qos: .background).async {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "localizedTitle", ascending: true)]
            let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: fetchOptions)
            var result = Set<PHAssetCollection>()
            [albums, smartAlbums].forEach {
                $0.enumerateObjects { collection, index, stop in
                    if collection.estimatedAssetCount > 0 { result.insert(collection) }
                }
            }
            completion(result)
        }
    }
    
    static func getAlbumsMoment(completion:@escaping (_ albums: Set<PHAssetCollection>) -> ()) {
        DispatchQueue.global(qos: .background).async {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "localizedTitle", ascending: true)]
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .moment, subtype: .any, options: fetchOptions)
            var result = Set<PHAssetCollection>()
            [smartAlbums].forEach {
                $0.enumerateObjects { collection, index, stop in
                    if collection.estimatedAssetCount > 0 { result.insert(collection) }
                }
            }
            completion(result)
        }
    }
    
    static func getAlbumsVideos(completion:@escaping (_ albums: Set<PHAssetCollection>) -> ()) {
        DispatchQueue.global(qos: .background).async {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "localizedTitle", ascending: true)]
            let albums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumVideos, options: fetchOptions)
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumVideos, options: fetchOptions)
            var result = Set<PHAssetCollection>()
            [albums,smartAlbums].forEach {
                $0.enumerateObjects { collection, index, stop in
                    if collection.estimatedAssetCount > 0 { result.insert(collection) }
                }
            }
            completion(result)
        }
    }
    
    static func getImagesFromAlbum(album: PHAssetCollection, options: PHImageRequestOptions = defaultImageFetchOptions, fetchOptions: FetchOptions = FetchOptions(), completion: @escaping (_ result: AssetFetchResult<UIImage>,_ creationDate:Date?) -> ()) {
        DispatchQueue.global(qos: .background).async {
            PhotosHelper.getAssetsFromAlbum(album: album, fetchOptions: fetchOptions, completion: { result in
                switch result {
                case .Asset: ()
                case .Error: completion(.Error, nil)
                case .Assets(let assets):
                    let imageManager = PHImageManager.default()
                    assets.forEach { asset in
                        imageManager.requestImage(for: asset, targetSize: fetchOptions.size ?? CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill,options: options, resultHandler: { image, _ in
                            guard let date:Date =  asset.creationDate else { return }
                            guard let image:UIImage = image else { return }
                            completion(.Asset(image), date)
                        })
                    }
                }
            })
        }
    }
    
    static func getCameraRollAlbum(completion: @escaping (_ album: PHAssetCollection?) -> ()) {
        DispatchQueue.global(qos: .background).async {
            let albums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumMyPhotoStream, options: nil)
            completion(albums.firstObject)
        }
    }
    
}
