//
//  DatabaseManager.swift
//  Fyndr
//
//  Created by BlackNGreen on 01/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON


enum EntityName : String {
    case profileList = "ProfileList"
    case imageList = "ImageList"
    case blockList = "BlockList"
    case chatHistoryList = "ChatHistoryList"
    case chatList = "ChatList"
    case unReadMessageList = "UnReadMessageList"
    case bookmarkList = "BookmarkList"
    case eventLog = "EventLog"
    case appChatPolicy = "AppChatPolicy"
}


class DatabaseManager
{
    static let shared = DatabaseManager()
    let context = APP_DELEGATE.persistentContainer.viewContext
    private init(){}
    
    let TAG = "DB :"
    
    //MARK:- Profile
    func saveUpdateProfile(profile : Profile)
    {
        guard let uniqueId = profile.uniqueId else {
            print("\(TAG) Profile id nil")
            return
        }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.profileList.rawValue)
        request.predicate = NSPredicate(format: "uniqueId = %@", uniqueId)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            var profileList : ProfileList?
            
            if result.count > 0
            {
                profileList = result.first as? ProfileList
            }else
            {
                let entity = NSEntityDescription.entity(forEntityName: EntityName.profileList.rawValue , in: context)
                let profileObj = NSManagedObject.init(entity: entity!, insertInto: context)
                profileList = profileObj as? ProfileList
            }
            
            profileList?.age = Int16(profile.age ?? 0)
            profileList?.dob = profile.dob
            profileList?.about = profile.about
            profileList?.email = profile.email
            profileList?.gender = profile.gender
            profileList?.isAudio = profile.isAudio
            profileList?.isImage = profile.isImage
            profileList?.isInterest = profile.isInterest
            profileList?.isMute = profile.isMute
            profileList?.isRegister = profile.isRegister
            profileList?.isVideo = profile.isVideo
            profileList?.isVisible = profile.isVisible
            profileList?.jabberId = profile.jabberId
            profileList?.name = profile.name
            profileList?.number = profile.number
            profileList?.password = profile.password
            profileList?.profileType = profile.profileType
            profileList?.uniqueId = profile.uniqueId
            profileList?.msisdn = profile.msisdn
            profileList?.city = profile.cityString
            profileList?.imageList = profile.imageListString
            profileList?.videoList = profile.videoListString
            profileList?.interests = profile.interestsString
            profileList?.interestCategory = profile.interestCategoryString
            
            do {
                try context.save()
            } catch {
                print("\(TAG) Failed to save profile : \(String(describing: profile.uniqueId))")
            }
        } catch {
            print("\(TAG) Failed to fetch profile : \(String(describing: profile.uniqueId))")
        }
    }
    
    func getProfile(uniqueId : String) -> Profile?
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.profileList.rawValue)
        request.predicate = NSPredicate(format: "uniqueId = %@", uniqueId)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            
            if let profileObj = result.first as? ProfileList
            {
                var profile = Profile.init(json: JSON())
                
                profile.age = Int(profileObj.age)
                profile.dob = profileObj.dob
                profile.about = profileObj.about
                profile.email = profileObj.email
                profile.gender = profileObj.gender
                profile.isAudio = profileObj.isAudio
                profile.isImage = profileObj.isImage
                profile.isInterest = profileObj.isInterest
                profile.isMute = profileObj.isMute
                profile.isRegister = profileObj.isRegister
                profile.isVideo = profileObj.isVideo
                profile.isVisible = profileObj.isVisible
                profile.jabberId = profileObj.jabberId
                profile.name = profileObj.name
                profile.number = profileObj.number
                profile.password = profileObj.password
                profile.profileType = profileObj.profileType
                profile.msisdn = profileObj.msisdn
                profile.uniqueId = profileObj.uniqueId
                
                if let cityString = profileObj.city {
                    profile.city = City.init(json:JSON.init(parseJSON: cityString))
                }
                
                if let interestCategoryJson = profileObj.interestCategory {
                    let jsonArray = JSON.init(parseJSON: interestCategoryJson)
                    if let interestCategoryItem = jsonArray.array { profile.interestCategory = interestCategoryItem.map { Interest.init(json: $0)} }
                }
                
                if let imageListJson = profileObj.imageList {
                    let jsonArray = JSON.init(parseJSON: imageListJson)
                    if let imageListItem = jsonArray.array { profile.imageList = imageListItem.map { ImageModel.init(json: $0)} }
                }
                
                if let videoListJson = profileObj.videoList {
                    let jsonArray = JSON.init(parseJSON: videoListJson)
                    if let videoListItem = jsonArray.array { profile.videoList = videoListItem.map { VideoModel.init(json: $0)} }
                }
                
                if let interestJson = profileObj.interests {
                    let jsonArray = JSON.init(parseJSON: interestJson)
                    if let interestsItem = jsonArray.array { profile.interests = interestsItem.map { SubCategory.init(json: $0)} }
                }
                return profile
            }
        } catch {
            print("\(TAG) Failed to fetch profile : \(uniqueId)")
        }
        return nil
    }
    
    
    func isProfileExist(uniqueId : String) -> Bool
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.profileList.rawValue)
        request.predicate = NSPredicate(format: "uniqueId = %@", uniqueId)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            if result.count > 0
            {
                return true
            }
        } catch {
            print("\(TAG) Failed to fetch profile : \(uniqueId)")
        }
        return false
    }
    
    func deleteProfile(uniqueId : String)
    {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.profileList.rawValue)
        fetchRequest.predicate = NSPredicate(format: "uniqueId == %@", uniqueId)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        
        do {
            try context.execute(deleteRequest)
            
        } catch let error as NSError {
            print("\(TAG) Could not delete profile : \(uniqueId). Error \(error), \(error.userInfo)")
        }
    }
    
    func deleteAllProfile()
    {
        self.deleteAllDataFor(entityName: EntityName.profileList.rawValue)
    }
    
    
    //MARK:- Bookmark
    func saveUpdateBookmark(profiles : [Profile], bookmarkIds : [BookmarkIds]?)
    {
        for profile in profiles
        {
            if let uniqueId = profile.uniqueId
            {
                self.saveUpdateProfile(profile: profile)
                
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.bookmarkList.rawValue)
                request.predicate = NSPredicate(format: "uniqueId = %@", uniqueId)
                request.returnsObjectsAsFaults = false
                
                do {
                    let result = try context.fetch(request)
                    var bookmarkList : BookmarkList?
                    
                    if result.count > 0
                    {
                        bookmarkList = result.first as? BookmarkList
                    }else {
                        let entity = NSEntityDescription.entity(forEntityName: EntityName.bookmarkList.rawValue , in: context)
                        let bookmarkObj = NSManagedObject.init(entity: entity!, insertInto: context)
                        bookmarkList = bookmarkObj as? BookmarkList
                    }
                    bookmarkList?.avatarUrl = profile.imageList?.first?.url
                    
                    let bookmarkId = bookmarkIds?.filter({$0.uniqueId ==  uniqueId})
                    bookmarkList?.createdDate = bookmarkId?.first?.timeStamp ?? Date().millisecondsSince1970
                    
                    bookmarkList?.name = profile.name
                    bookmarkList?.requestStatus = Int16(SyncStatus.PENDING.rawValue)
                    bookmarkList?.status = 1 // Bookmarked
                    bookmarkList?.uniqueId = profile.uniqueId
                    do {
                        try context.save()
                    } catch {
                        print("\(TAG) Failed to save bookmark. profile :\(String(describing: profile.uniqueId))")
                    }
                }catch {
                    print("\(TAG) Failed to fetch bookmark, for : \(String(describing: profile.uniqueId))")
                }
            }
        }
    }
    
    
    func updateBookmarkRequestStatus(uniqueIds : [BookmarkIds])
    {
        for profileIdWithTimeStamp in uniqueIds {
            if let uniqueId = profileIdWithTimeStamp.uniqueId {
                
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.bookmarkList.rawValue)
                request.predicate = NSPredicate(format: "uniqueId = %@", uniqueId)
                request.returnsObjectsAsFaults = false
                
                do {
                    let results = try context.fetch(request)
                    if results.count > 0 {
                        for result in results
                        {
                            if let bookmarkList = result as? BookmarkList
                            {
                                bookmarkList.requestStatus = Int16(SyncStatus.SUCCESS.rawValue)
                            }
                        }
                        do {
                            try context.save()
                        } catch {
                            print("\(TAG) Failed to update bookmark status. :\(String(describing: uniqueId))")
                        }
                    }
                }catch {
                    print("\(TAG) Failed to fetch bookmark, for : \(String(describing: uniqueId))")
                }
            }
        }
    }
    
    func getBookmarkList() -> [BookmarkedProfile]?
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.bookmarkList.rawValue)
        request.sortDescriptors = [NSSortDescriptor.init(key: "createdDate", ascending: false)]
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            
            if result.count > 0
            {
                var bookmarkedList = [BookmarkedProfile]()
                for bookmarkObj in result
                {
                    if let bookmarkObj  = bookmarkObj as? BookmarkList {
                        
                        var bookmark = BookmarkedProfile.init()
                        bookmark.avatarUrl = bookmarkObj.avatarUrl
                        bookmark.createdDate = bookmarkObj.createdDate
                        bookmark.name = bookmarkObj.name
                        bookmark.requestStatus = bookmarkObj.requestStatus
                        bookmark.status = bookmarkObj.status
                        bookmark.uniqueId = bookmarkObj.uniqueId
                        bookmarkedList.append(bookmark)
                    }
                }
                return bookmarkedList
            }
            
        } catch {
            print("\(TAG) Failed to fetch bookmark")
        }
        return nil
    }
    
    func getPendingBookmarkIds() -> [String]?
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.bookmarkList.rawValue)
        request.predicate = NSPredicate(format: "requestStatus = %d", Int16(SyncStatus.PENDING.rawValue))
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            if result.count > 0
            {
                var bookmarkedList = [String]()
                for bookmarkObj in result
                {
                    if let bookmarkObj  = bookmarkObj as? BookmarkList,  let uniqueId = bookmarkObj.uniqueId  {
                        bookmarkedList.append(uniqueId)
                    }
                }
                return bookmarkedList
            }
            
        } catch {
            print("\(TAG) Failed to fetch bookmark")
        }
        return nil
    }
    
    func getPendingBookmarks() -> [BookmarkIds]?
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.bookmarkList.rawValue)
        request.predicate = NSPredicate(format: "requestStatus = %d", Int16(SyncStatus.PENDING.rawValue))
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            if result.count > 0
            {
                var bookmarkedList = [BookmarkIds]()
                for bookmarkObj in result
                {
                    if let bookmarkObj  = bookmarkObj as? BookmarkList,  let uniqueId = bookmarkObj.uniqueId  {
                        bookmarkedList.append(BookmarkIds.init(uniqueId: uniqueId, timeStamp: bookmarkObj.createdDate))
                    }
                }
                return bookmarkedList
            }
            
        } catch {
            print("\(TAG) Failed to fetch bookmark")
        }
        return nil
    }
    
    func bookmarkPendingProfileCount() -> Int
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.bookmarkList.rawValue)
        request.predicate = NSPredicate(format: "requestStatus = %d", Int16(SyncStatus.PENDING.rawValue))
        request.includesSubentities = false
        request.includesPropertyValues = false
        
        do {
            let count = try context.count(for: request)
            return count
        } catch {
            print("\(TAG) Failed to fetch bookmark")
        }
        return 0
    }
    
    
    func isBookmarked(uniqueId : String?) -> Bool
    {
        guard let uniqueId = uniqueId else {
            return false
        }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.bookmarkList.rawValue)
        request.predicate = NSPredicate(format: "uniqueId = %@", uniqueId)
        request.includesSubentities = false
        request.includesPropertyValues = false
        
        do {
            let count = try context.count(for: request)
            if count > 0
            {
                return true
            }
        } catch {
            print("\(TAG) Failed to fetch bookmark")
        }
        return false
    }
    
    func deleteBookmark(uniqueId : String?)
    {
        guard let uniqueId = uniqueId else {
            return
        }
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.bookmarkList.rawValue)
        fetchRequest.predicate = NSPredicate(format: "uniqueId == %@", uniqueId)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        do {
            try context.execute(deleteRequest)
            
            if !self.isBlocked(uniqueId: uniqueId)
            {
                self.deleteProfile(uniqueId: uniqueId)
            }
            
        } catch let error as NSError {
            print("\(TAG) Could not delete bookmark for uniqueId : \(uniqueId). \(error), \(error.userInfo)")
        }
    }
    
    func deleteAllBookmark()
    {
        self.deleteAllDataFor(entityName: EntityName.bookmarkList.rawValue)
    }
    
    //MARK:- BlockList
    func saveUpdateBlockList(profiles : [Profile], blockIds : [BlockIds]?)
    {
        for profile in profiles
        {
            if let uniqueId = profile.uniqueId
            {
                self.saveUpdateProfile(profile: profile)
                
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.blockList.rawValue)
                request.predicate = NSPredicate(format: "uniqueId = %@", uniqueId)
                request.returnsObjectsAsFaults = false
                
                do {
                    let result = try context.fetch(request)
                    var blockList : BlockList?
                    
                    if result.count > 0
                    {
                        blockList = result.first as? BlockList
                    }else {
                        let entity = NSEntityDescription.entity(forEntityName: EntityName.blockList.rawValue , in: context)
                        let bookmarkObj = NSManagedObject.init(entity: entity!, insertInto: context)
                        blockList = bookmarkObj as? BlockList
                    }
                    blockList?.avatarUrl = profile.imageList?.first?.url
                    
                    let blockId = blockIds?.filter({$0.uniqueId ==  uniqueId})
                    blockList?.createdDate = blockId?.first?.timeStamp ?? Date().millisecondsSince1970

                    blockList?.name = profile.name
                    blockList?.requestStatus = Int16(SyncStatus.SUCCESS.rawValue)
                    blockList?.status = 1 // Blocked
                    blockList?.uniqueId = profile.uniqueId
                    
                    do {
                        try context.save()
                    } catch {
                        print("\(TAG) Failed to save bookmark for : \(String(describing: profile.uniqueId))")
                    }
                }catch {
                    print("\(TAG) Failed to fetch blocklist for : \(String(describing: profile.uniqueId))")
                }
            }
        }
    }
    
    func getBlockList() -> [BlockedProfile]?
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.blockList.rawValue)
        request.sortDescriptors = [NSSortDescriptor.init(key: "createdDate", ascending: false)]
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            
            if result.count > 0
            {
                var blockList = [BlockedProfile]()
                
                for blockObj in result
                {
                    if let blockObj  = blockObj as? BlockList {
                        
                        var block = BlockedProfile.init()
                        block.avatarUrl = blockObj.avatarUrl
                        block.createdDate = blockObj.createdDate
                        block.name = blockObj.name
                        block.requestStatus = blockObj.requestStatus
                        block.status = blockObj.status
                        block.uniqueId = blockObj.uniqueId
                        blockList.append(block)
                    }
                }
                return blockList
            }
            
        } catch {
            print("\(TAG) Failed to fetch blocklist")
        }
        return nil
    }
    
    func isBlocked(uniqueId : String?) -> Bool
    {
        guard let uniqueId = uniqueId else {
            return false
        }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.blockList.rawValue)
        request.predicate = NSPredicate(format: "uniqueId = %@", uniqueId)
        request.includesSubentities = false
        request.includesPropertyValues = false
        
        do {
            let count = try context.count(for: request)
            if count > 0
            {
                return true
            }
        } catch {
            print("\(TAG) Failed to fetch blocklist")
        }
        return false
        
        /*
         let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.blockList.rawValue)
         request.predicate = NSPredicate(format: "uniqueId = %@", uniqueId)
         request.returnsObjectsAsFaults = false
         
         do {
         let result = try context.fetch(request)
         if result.count > 0
         {
         return true
         }
         } catch {
         print("\(TAG) Failed to fetch blocklist for : \(uniqueId)")
         }
         return false
         */
    }
    
    func deteleFromBlockList(uniqueId : String?)
    {
        guard let uniqueId = uniqueId else {
            return
        }
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.blockList.rawValue)
        fetchRequest.predicate = NSPredicate(format: "uniqueId == %@", uniqueId)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        do {
            try context.execute(deleteRequest)
            if !self.isBookmarked(uniqueId: uniqueId)
            {
                self.deleteProfile(uniqueId: uniqueId)
            }
            
        } catch let error as NSError {
            print("\(TAG) Could not delete blocklist for uniqueId :\(uniqueId). Error \(error), \(error.userInfo)")
        }
    }
    
    func deleteAllBlockList()
    {
        self.deleteAllDataFor(entityName: EntityName.blockList.rawValue)
    }
    
    //MARK:- ChatHistory
    func saveUpdateChatHistory(chatHistory : ChatHistory)
    {
        guard let uniqueId = chatHistory.uniqueId else {
            print("\(TAG) uniqueId is nil in chatHistory")
            return
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.chatHistoryList.rawValue)
        request.predicate = NSPredicate(format: "uniqueId = %@", uniqueId)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            var chatHistoryList : ChatHistoryList?
            
            if result.count > 0
            {
                chatHistoryList = result.first as? ChatHistoryList
            }else
            {
                let entity = NSEntityDescription.entity(forEntityName: EntityName.chatHistoryList.rawValue , in: context)
                let chatHistoryObjList = NSManagedObject.init(entity: entity!, insertInto: context)
                chatHistoryList = chatHistoryObjList as? ChatHistoryList
            }
            
            chatHistoryList?.avatarUrl = chatHistory.avatarUrl
            chatHistoryList?.contactNumber = chatHistory.contactNumber
            chatHistoryList?.createdDate = chatHistory.createdDate
            chatHistoryList?.lastMessage = chatHistory.lastMessage
            chatHistoryList?.name = chatHistory.name
            chatHistoryList?.uniqueId = chatHistory.uniqueId
            chatHistoryList?.connectionStatus = Int16(chatHistory.connectionStatus)
            chatHistoryList?.unReadMessageCount = Int16(chatHistory.unReadMessageCount)
            
            do {
                try context.save()
            } catch {
                print("\(TAG) Failed to save ChatHistory")
            }
        } catch {
            print("\(TAG) Failed to fetch chatHistory for : \(String(describing: chatHistory.uniqueId))")
        }
    }
    
    
    func getChatHistoryList(for connectionStatus : Int) -> [ChatHistory]?
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.chatHistoryList.rawValue)
        request.sortDescriptors = [NSSortDescriptor.init(key: "createdDate", ascending: false)]
        request.predicate = NSPredicate(format: "connectionStatus = %d", connectionStatus)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            
            if result.count > 0
            {
                var chatHistoryList = [ChatHistory]()
                
                for chatHistoryListObj in result
                {
                    if let chatHistoryObj = chatHistoryListObj as? ChatHistoryList
                    {
                        var chatHistory = ChatHistory.init()
                        chatHistory.avatarUrl = chatHistoryObj.avatarUrl
                        chatHistory.contactNumber = chatHistoryObj.contactNumber
                        chatHistory.createdDate = chatHistoryObj.createdDate
                        chatHistory.lastMessage = chatHistoryObj.lastMessage
                        chatHistory.name = chatHistoryObj.name
                        chatHistory.uniqueId = chatHistoryObj.uniqueId
                        chatHistory.connectionStatus = Int(chatHistoryObj.connectionStatus)
                        chatHistory.unReadMessageCount = Int(chatHistoryObj.unReadMessageCount)
                        
                        chatHistoryList.append(chatHistory)
                    }
                }
                return chatHistoryList
            }
            
        } catch {
            print("\(TAG) Failed to fetch ChatHistory for connectionStatus : \(connectionStatus)")
        }
        return nil
    }
    
    func getChatHistory(for uniqueId : String) -> ChatHistory?
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.chatHistoryList.rawValue)
        request.predicate = NSPredicate(format: "uniqueId = %@", uniqueId)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            
            if result.count > 0
            {
                if let chatHistoryObj = result.first as? ChatHistoryList
                {
                    var chatHistory = ChatHistory.init()
                    chatHistory.avatarUrl = chatHistoryObj.avatarUrl
                    chatHistory.contactNumber = chatHistoryObj.contactNumber
                    chatHistory.createdDate = chatHistoryObj.createdDate
                    chatHistory.lastMessage = chatHistoryObj.lastMessage
                    chatHistory.name = chatHistoryObj.name
                    chatHistory.uniqueId = chatHistoryObj.uniqueId
                    chatHistory.connectionStatus = Int(chatHistoryObj.connectionStatus)
                    chatHistory.unReadMessageCount = Int(chatHistoryObj.unReadMessageCount)
                    
                    return chatHistory
                }
            }
            
        } catch {
            print("\(TAG) Failed to fetch ChatHistory for : \(uniqueId)")
        }
        return nil
    }
    
    func clearUnReadCountInChatHistory(for uniqueId : String) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.chatHistoryList.rawValue)
        request.predicate = NSPredicate(format: "uniqueId = %@", uniqueId)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            if result.count > 0
            {
                let chatHistoryList = result.first as? ChatHistoryList
                chatHistoryList?.unReadMessageCount = 0
                do {
                    try context.save()
                } catch {
                    print("\(TAG) Failed to update un read status in ChatHistory for : \(uniqueId)")
                }
            }
        } catch {
            print("\(TAG) Failed to fetch ChatHistory for : \(uniqueId)")
        }
    }
    
    func increaseUnReadMessageCountInChatHistory(for uniqueId : String) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.chatHistoryList.rawValue)
        request.predicate = NSPredicate(format: "uniqueId = %@", uniqueId)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            if result.count > 0
            {
                let chatHistoryList = result.first as? ChatHistoryList
                chatHistoryList?.unReadMessageCount = chatHistoryList?.unReadMessageCount ?? 0 + 1
                do {
                    try context.save()
                } catch {
                    print("\(TAG) Failed to update un read status in ChatHistory for : \(uniqueId)")
                }
            }
        } catch {
            print("\(TAG) Failed to fetch ChatHistory for : \(uniqueId)")
        }
    }
    
    func updateAvatarUrlInChatHistory(for uniqueId : String, avatarUrl : String) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.chatHistoryList.rawValue)
        request.predicate = NSPredicate(format: "uniqueId = %@", uniqueId)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            if result.count > 0
            {
                let chatHistoryList = result.first as? ChatHistoryList
                chatHistoryList?.avatarUrl = avatarUrl
                do {
                    try context.save()
                } catch {
                    print("\(TAG) Failed to update avatar url in ChatHistory for : \(uniqueId)")
                }
            }
        } catch {
            print("\(TAG) Failed to fetch ChatHistory for : \(uniqueId)")
        }
    }
    
    func updateNameInChatHistory(for uniqueId : String, name : String) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.chatHistoryList.rawValue)
        request.predicate = NSPredicate(format: "uniqueId = %@", uniqueId)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            if result.count > 0
            {
                let chatHistoryList = result.first as? ChatHistoryList
                chatHistoryList?.name = name
                do {
                    try context.save()
                } catch {
                    print("\(TAG) Failed to update name in ChatHistory for : \(uniqueId)")
                }
            }
        } catch {
            print("\(TAG) Failed to fetch ChatHistory for : \(uniqueId)")
        }
    }
    
    func deleteChatHistory(for uniqueId : String)
    {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.chatHistoryList.rawValue)
        fetchRequest.predicate = NSPredicate(format: "uniqueId == %@", uniqueId)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        do {
            try context.execute(deleteRequest)
            
        } catch let error as NSError {
            print("\(TAG) Could not delete chatHistory for : \(uniqueId). Error \(error), \(error.userInfo)")
        }
    }
    
    func deleteAllChatHistory()
    {
        self.deleteAllDataFor(entityName: EntityName.chatHistoryList.rawValue)
    }
    
    func deleteChatFromChatId(chatModel: ChatModel){
        if let chatId = chatModel.chatId {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.chatHistoryList.rawValue)
            fetchRequest.predicate = NSPredicate(format: "chatId == %@", chatId)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
            do {
                try context.execute(deleteRequest)
                
            } catch let error as NSError {
                print("\(TAG) Could not delete chatHistory for chatId- : \(chatId). Error \(error), \(error.userInfo)")
            }
        }
        
    }
    
    
    //MARK:- Chat
    func saveUpdateChat(chat : ChatModel)
    {
        guard let chatId = chat.chatId else {
            return
        }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.chatList.rawValue)
        request.predicate = NSPredicate(format: "chatId = %@", chatId)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            var chatList : ChatList?
            
            if result.count > 0
            {
                chatList = result.first as? ChatList
            }else {
                let entity = NSEntityDescription.entity(forEntityName: EntityName.chatList.rawValue , in: context)
                let chatObjList = NSManagedObject.init(entity: entity!, insertInto: context)
                chatList = chatObjList as? ChatList
            }
            chatList?.chatId = chat.chatId
            chatList?.uniqueId = chat.uniqueId
            chatList?.messageSource = Int16(chat.messageSource)
            chatList?.type = chat.type
            chatList?.message = chat.message
            chatList?.messageDate = chat.messageDate
            chatList?.media = chat.media
            chatList?.messageSentStatus = Int16(chat.messageSentStatus)
            chatList?.messageReadStatus = Int16(chat.messageReadStatus)
            
            do {
                try context.save()
            } catch {
                print("\(TAG) Failed to save chat")
            }
        } catch {
            print("\(TAG) Failed to fetch chat")
        }
    }
    
    
    func getChatList(for uniqueId : String) -> [ChatModel]?
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.chatList.rawValue)
        request.sortDescriptors = [NSSortDescriptor.init(key: "messageDate", ascending: true)]
        request.predicate = NSPredicate(format: "uniqueId == %@", uniqueId)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            
            if result.count > 0
            {
                var chatList = [ChatModel]()
                
                for chatObjList in result
                {
                    if let chatObj = chatObjList as? ChatList
                    {
                        var chat = ChatModel.init()
                        chat.chatId = chatObj.chatId
                        chat.uniqueId = chatObj.uniqueId
                        chat.messageSource = Int(chatObj.messageSource)
                        chat.type = chatObj.type
                        chat.message = chatObj.message
                        chat.messageDate = chatObj.messageDate
                        chat.media = chatObj.media
                        chat.messageSentStatus = Int(chatObj.messageSentStatus)
                        chat.messageReadStatus = Int(chatObj.messageReadStatus)
                        
                        chatList.append(chat)
                    }
                }
                return chatList
            }
        } catch {
            print("\(TAG) Failed to fetch chat for  : \(uniqueId)")
        }
        return nil
    }
    
    func updateMessageSentStatus(chatId : String, uniqueId : String, sentStatus : Int)
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.chatList.rawValue)
        request.predicate = NSPredicate(format: "uniqueId == %@ && chatId = %@",uniqueId, chatId)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            if result.count > 0
            {
                let chatList = result.first as? ChatList
                chatList?.messageSentStatus = Int16(sentStatus)
            }
            do {
                try context.save()
            } catch {
                print("\(TAG) Failed to save sentStatus in chat for chatId : \(chatId)")
            }
        } catch {
            print("\(TAG) Failed to fetch sentStatus in chat for chatId : \(chatId)")
        }
    }
    
    func updateMessageReadStatus(chatId : String, uniqueId : String, readStatus : Int)
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.chatList.rawValue)
        request.predicate = NSPredicate(format: "uniqueId == %@ && chatId = %@",uniqueId, chatId)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            if result.count > 0
            {
                let chatList = result.first as? ChatList
                chatList?.messageReadStatus = Int16(readStatus)
            }
            do {
                try context.save()
            } catch {
                print("\(TAG) Failed to save readStatus in chat for chatId : \(chatId)")
            }
        } catch {
            print("\(TAG) Failed to fetch unReadMessageCount in chat for chatId : \(chatId)")
        }
    }
    
    func isConnectedUser(for uniqueId : String) -> Bool
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.chatList.rawValue)
        request.predicate = NSPredicate(format: "uniqueId == %@ && fromMe == %d", uniqueId,true)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            if result.count > 0
            {
                return true
            }
        } catch {
            print("\(TAG) Failed to fetch chat")
        }
        return false
    }
    
    func deleteChats(for uniqueId : String)
    {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.chatList.rawValue)
        fetchRequest.predicate = NSPredicate(format: "uniqueId == %@", uniqueId)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            print("\(TAG) Could not delete chats for uniqueId : \(uniqueId). Error :  \(error), \(error.userInfo)")
        }
    }
    
    func deleteAllChats()
    {
        self.deleteAllDataFor(entityName: EntityName.chatList.rawValue)
    }
    
    
    //MARK:- Event Log
    func saveEventLog(eventName : String, parameter : String)
    {
        let eventId = UUID().uuidString
        
        let entity = NSEntityDescription.entity(forEntityName: EntityName.eventLog.rawValue , in: context)
        let eventLogObj = NSManagedObject.init(entity: entity!, insertInto: context)
        let eventLog = eventLogObj as? EventLog
        
        eventLog?.eventId = eventId
        eventLog?.eventName = eventName
        eventLog?.eventParameter = parameter
        
        do {
            try context.save()
        } catch {
            print("\(TAG) Failed to save chat")
        }
    }
    
    func getEventLogCount() -> Int
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.eventLog.rawValue)
        request.includesSubentities = false
        request.includesPropertyValues = false
        do {
            return try context.count(for: request)
        }catch {
            print("\(TAG) Failed to fetch event log")
        }
        return 0
    }
    
    func getEventLogs() -> [Event]?
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.eventLog.rawValue)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            if result.count > 0
            {
                var events = [Event]()
                for eventLogObj in result
                {
                    if let eventLog = eventLogObj as? EventLog
                    {
                        let event = Event.init(id: eventLog.eventId, name: eventLog.eventName, parameter: eventLog.eventParameter)
                        events.append(event)
                    }
                }
                return events
            }
            
        } catch {
            print("\(TAG) Failed to fetch event log")
        }
        return nil
    }
    
    func deleteEventLogs(eventLogs : [Event])
    {
        for eventLog in eventLogs {
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.eventLog.rawValue)
            fetchRequest.predicate = NSPredicate(format: "eventId == %@", eventLog.id ?? "")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
            do {
                try context.execute(deleteRequest)
            } catch let error as NSError {
                print("\(TAG) Could not delete event log for eventId : \(String(describing: eventLog.id)). Error :  \(error), \(error.userInfo)")
            }
        }
    }
    
    
    //MARK:- Delete
    func deleteAllDataFor(entityName : String)
    {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            print("\(TAG) Could not delete entityName : \(entityName). Error : \(error), \(error.userInfo)")
        }
    }
    
    func clearAllStoredData(exceptChat : Bool)
    {
        self.deleteAllBookmark()
        self.deleteAllBlockList()
        
        if !exceptChat {
            self.deleteAllProfile()
            self.deleteAllChatHistory()
            self.deleteAllChats()
        }
    }
    
    
    func updateChatPlicy() {
        
    }
    
    
    func getChatUserCounts() -> Int{
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.appChatPolicy.rawValue)
        request.includesSubentities = false
        request.includesPropertyValues = false
        do {
            return try context.count(for: request)
        }catch {
            print("\(TAG) Failed to fetch getChatUserCounts()")
        }
        return 0
    }
    
    
    func getUserChatCount(userId: String) -> Int
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.appChatPolicy.rawValue)
        request.predicate = NSPredicate(format: "userId == %@", userId)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            if result.count > 0
            {
                let appChatPolicy = result.first as? AppChatPolicy
                return Int(appChatPolicy?.sendSms ?? 0)
            }
        } catch {
            print("\(TAG) Failed to fetch appChatPolicy")
            return 0
        }
        return 0
    }
    
    
    func insertAndUpdateAppPolicyData(userId: String, chatCount: Int){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.appChatPolicy.rawValue)
        request.predicate = NSPredicate(format: "userId == %@", userId)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            if result.count > 0
            {
                let appChatPolicy = result.first as? AppChatPolicy
                appChatPolicy?.sendSms = Int32(chatCount)

            }else {
                let entity = NSEntityDescription.entity(forEntityName: EntityName.appChatPolicy.rawValue , in: context)
                let appChatObj = NSManagedObject.init(entity: entity!, insertInto: context)
                let chatPolicyModel = appChatObj as? AppChatPolicy
                chatPolicyModel?.userId = userId
                chatPolicyModel?.sendSms = 1
                chatPolicyModel?.receiveSms = 0
            }
            try context.save()

        } catch {
            print("\(TAG) Failed to fetch appChatPolicy")
        }
    }

}
