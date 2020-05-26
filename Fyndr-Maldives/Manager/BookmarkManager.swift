//
//  BookmarkManager.swift
//  Fyndr
//
//  Created by BlackNGreen on 05/07/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

class BookmarkManager {
    
    var requestInProgress = false
    let chunkCount = 5
    static let shared = BookmarkManager()
    private init() {}
    
    func addToBookmark(profile : Profile)
    {
        print("BookmarkManager : Add profile to bookmark")
        
        DatabaseManager.shared.saveUpdateBookmark(profiles: [profile], bookmarkIds : [BookmarkIds.init(uniqueId: profile.uniqueId)])
        checkAndUpdateBookmarkOnServer()
    }
    
    fileprivate func checkAndUpdateBookmarkOnServer()
    {
        print("BookmarkManager : Check And Update Bookmark On Server : \(requestInProgress)")
        
        if !requestInProgress {
            
            let pendingCount = DatabaseManager.shared.bookmarkPendingProfileCount()
            print("BookmarkManager : Pending Count \(pendingCount)")
            
            if pendingCount >= chunkCount
            {
                updateBookmarkOnServer()
            }
        }
    }
    
    func updateBookmarkOnServer()
    {
        print("BookmarkManager : Update Bookmark On Server : \(requestInProgress)")
        
        if Reachability.isInternetConnected() {
            
            if let pendingIds = DatabaseManager.shared.getPendingBookmarks() {
                
                print("BookmarkManager : Pending id's \(pendingIds)")
                self.requestInProgress = true
                
                RequestManager.shared.addBookmarkRequest(bookmarkIds: pendingIds, onCompletion: { (responseJson) in
                    let response =  Response.init(json: responseJson)
                    if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                    {
                        print("BookmarkManager : update request status for id's \(pendingIds)")
                        DatabaseManager.shared.updateBookmarkRequestStatus(uniqueIds: pendingIds)
                        self.checkAndUpdateBookmarkOnServer()
                    }
                    self.requestInProgress = false
                }) { (error) in
                    self.requestInProgress = false
                }
            }
        }
    }
}
