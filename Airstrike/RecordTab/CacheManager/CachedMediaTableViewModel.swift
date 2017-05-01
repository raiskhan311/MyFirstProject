//
//  CachedMediaTableViewModel.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 1/9/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class CachedMediaTableViewModel {
    
    fileprivate var cachedMedia: [CachedMedia]?
    fileprivate let dateFormatter = DateFormatter()
    var delegate: UploadDelegate?
    var amountCompletedUploading: Int64 = 0
    var canEdit = true

    init() {
        dateFormatter.dateStyle = .short
        guard let cmo = try? DAOCachedMedia().getAll() else { return }
        cachedMedia = cmo
    }
}

// MARK: - Getters

extension CachedMediaTableViewModel {
    
    func getCellCount() -> Int {
        return cachedMedia?.count ?? 0
    }
    
    func getThumbnailImage(for indexPath: IndexPath, completion: @escaping (_ image: UIImage?) -> ()) {
        guard let c = cachedMedia, c.count > indexPath.item else {
            completion(.none)
            return
        }
        print(c[indexPath.item].getFilePath())
        if FileManager.default.fileExists(atPath: c[indexPath.item].getFilePath()) {
            MediaServiceConnector.sharedInstance.ziggeo.videos.GetImageForLocalVideo(c[indexPath.item].getFilePath()) { (image, error) in
                if let e = error {
                    print(e.localizedDescription)
                    completion(.none)
                } else {
                    completion(image)
                }
            }
        }
    }
    
    func getDescription(for indexPath: IndexPath) -> String? {
        guard let c = cachedMedia, c.count > indexPath.item else { return .none }
        return dateFormatter.string(from: c[indexPath.item].date)
    }
    
    func getDuration(for indexPath: IndexPath) -> String? {
        guard let c = cachedMedia, c.count > indexPath.item else { return .none }
        return c[indexPath.item].duration
    }
    
    func deleteItem(at indexPath: IndexPath) {
        self.cachedMedia?[indexPath.item].removeFromCachedMediaDirectory()
        try? DAOCachedMedia().delete(self.cachedMedia?[indexPath.item].id)
        try? DAOMediaMapping().delete(self.cachedMedia?[indexPath.item].id)
        self.cachedMedia?.remove(at: indexPath.item)
    }
    
    func cellHeight() -> CGFloat {
        return 100
    }
        
    func uploadAllVideos() {
        if let cM = cachedMedia, cM.count > 0 {
            _ = MediaServiceConnector.sharedInstance.ziggeo.videos.CreateVideo(.none, file: cM[0].getFilePath(), cover: nil, callback: { (dictionary, response, error) in
                if let d = self.delegate {
                    if let d = dictionary, let videoArray = d["video"] as? [String:Any], let token = videoArray["token"] as? String {
                        guard let leagueId = ServiceConnector.sharedInstance.getDisplayLeague()?.id else { return }
                        ServiceConnector.sharedInstance.addMedia(mediaToken: token, creationDate: cM[0].date, leagueId: leagueId, mappingId: cM[0].id, complete: { (success, mediaId) in
                            if success {
                                try? DAOMedia().insert(Media(id: mediaId, type: MediaType.video, mediaToken: token, creationDate: cM[0].date), mappingId: cM[0].id)
                            }
                        })
                    }
                    self.cachedMedia?[0].removeFromCachedMediaDirectory()
                    try? DAOCachedMedia().delete(self.cachedMedia?[0].id)
                    self.cachedMedia?.remove(at: 0)
                    d.uploadComplete()
                    self.canEdit = true
                    self.amountCompletedUploading = 0
                }
            }, progress: { (amountCompleted, total) in
                self.amountCompletedUploading += amountCompleted
                if let d = self.delegate {
                    self.canEdit = false
                    let progress = Float(self.amountCompletedUploading)/Float(total)
                    d.progressUpdated(progress: progress)
                }
            })
        }
    }
    
}
