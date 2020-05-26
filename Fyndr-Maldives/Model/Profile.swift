//
//  Profile.swift
//  Fyndr
//
//  Created by BlackNGreen on 27/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Profile : Codable {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    struct SerializationKeys {
        
        static let uniqueId = "uniqueId"
        static let jabberId = "jabberId"
        static let name = "name"
        static let dob = "dobs"
        static let age = "age"
        static let gender = "gender"
        static let email = "email"
        static let number = "number"
        static let city = "cityS"
        static let profileType = "profileType"
        static let password = "password"
        static var contactNumber = "callerId"
        static var msisdn = "msisdn"
        static let isMute = "isMute"
        static let isVisible = "isVisible"
        static let isVideo = "isVideo"
        static let isAudio = "isAudio"
        static let isImage = "isImage"
        static let isRegister = "isRegister"
        static let isProfile = "isProfile"
        static let isInterest = "isInterest"
        static let about = "bio"
        
        static let imageList = "imageList"
        static let videoList = "videoList"
        static var interests = "interestS"
        static var interestCategory = "interestCategory"
        static let fbId = "fbId"
        static let googleId = "googleId"
        static let registrationMethod = "registrationMethod"
        static let userType = "userType"


        
        // time object 
    }
    
    // MARK: Properties
    public var uniqueId: String?
    public var jabberId: String?
    public var name: String?
    public var dob: String?
    public var age: Int?
    public var gender: String?
    public var email: String?
    public var number: String?
    public var profileType: String?
    public var password: String?
    public var contactNumber: String?
    public var msisdn: String?
    public var about: String?    

    public var isMute: Bool = false
    public var isVisible: Bool = false
    public var isVideo: Bool = false
    public var isAudio: Bool = false
    public var isImage: Bool = false
    public var isRegister: Bool = false
    public var isProfile: Bool = false
    public var isInterest: Bool = false
    
    
    public var videoList: [VideoModel]?
    public var city: City?
    public var imageList: [ImageModel]?
    public var interests: [SubCategory]?
    public var interestCategory: [Interest]?
    
    public var cityString: String?
    public var imageListString: String?
    public var videoListString: String?
    public var interestsString: String?
    public var interestCategoryString: String?
    public var registrationMethod: String?
    public var socialId: String?
    public var userType: String?

    
    public init(json: JSON) {
        
        if let uniqueId = json[SerializationKeys.uniqueId].string
        {
            self.uniqueId = uniqueId
            self.isRegister = true
        }
        jabberId = json[SerializationKeys.jabberId].string
        name = json[SerializationKeys.name].string?.byteUTF8ToString()
        dob = json[SerializationKeys.dob].stringValue
        age = json[SerializationKeys.age].int
        gender = json[SerializationKeys.gender].string
        number = json[SerializationKeys.number].string
        profileType = json[SerializationKeys.profileType].string
        password = json[SerializationKeys.password].string
        contactNumber = json[SerializationKeys.contactNumber].string
        msisdn = json[SerializationKeys.msisdn].string
        
        isMute = json[SerializationKeys.isMute].boolValue
        isVisible = json[SerializationKeys.isVisible].boolValue
        isVideo = json[SerializationKeys.isVideo].boolValue
        isAudio = json[SerializationKeys.isAudio].boolValue
        isImage = json[SerializationKeys.isImage].boolValue
        isProfile = json[SerializationKeys.isProfile].boolValue
        isInterest = json[SerializationKeys.isInterest].boolValue
        about = json[SerializationKeys.about].string?.byteUTF8ToString()
        userType = json[SerializationKeys.userType].string

        city = City.init(json: json[SerializationKeys.city])
        cityString = json[SerializationKeys.city].debugDescription
        
        if let email = json[SerializationKeys.email].string {
            self.email = email
        }
        
        if let fbId = json[SerializationKeys.fbId].string {
            self.socialId = fbId
        }
        
        if let googleId = json[SerializationKeys.googleId].string {
            self.socialId = googleId
        }
        
        if let imageListItem = json[SerializationKeys.imageList].array { imageList = imageListItem.map { ImageModel.init(json: $0) } }
        imageListString = json[SerializationKeys.imageList].debugDescription

        if let videoListItem = json[SerializationKeys.videoList].array { videoList = videoListItem.map { VideoModel.init(json: $0) } }
        videoListString = json[SerializationKeys.videoList].debugDescription

       if let interestCategoryItem = json[SerializationKeys.interestCategory].array { interestCategory = interestCategoryItem.map { Interest.init(json: $0)} }
        interestCategoryString = json[SerializationKeys.interestCategory].debugDescription
        
        if let interestItem = json[SerializationKeys.interests].array {
            interests = interestItem.map {
                SubCategory.init(json: $0)
            }
        }
        interestsString = json[SerializationKeys.interests].debugDescription
    }
    
    public func setCity(json: String) {
    
    }
    
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = uniqueId { dictionary[SerializationKeys.uniqueId] = value }
        if let value = jabberId { dictionary[SerializationKeys.jabberId] = value }
        if let value = name { dictionary[SerializationKeys.name] = value.stringToUTF8Byte() }
        if let value = dob { dictionary[SerializationKeys.dob] = value }
        if let value = age { dictionary[SerializationKeys.age] = value }
        if let value = gender { dictionary[SerializationKeys.gender] = value }
        if let value = email { dictionary[SerializationKeys.email] = value }
        if let value = number { dictionary[SerializationKeys.number] = value }
        if let value = city  {dictionary[SerializationKeys.city] = value}        
        if let value = profileType { dictionary[SerializationKeys.profileType] = value }
        if let value = password { dictionary[SerializationKeys.password] = value }
        if let value = contactNumber { dictionary[SerializationKeys.contactNumber] = value }
        if let value = msisdn { dictionary[SerializationKeys.msisdn] = value }
        if let value = about {dictionary[SerializationKeys.about] = value.stringToUTF8Byte()}
        if let registrationMethod = registrationMethod {
            if RegistrationMethods.FB.rawValue == registrationMethod {
                if let value = socialId { dictionary[SerializationKeys.fbId] = value }
            }else if RegistrationMethods.GOOGLE.rawValue == registrationMethod {
                if let value = socialId { dictionary[SerializationKeys.googleId] = value }
            }
        }

        dictionary[SerializationKeys.isMute] = isMute
        dictionary[SerializationKeys.isVisible] = isVisible
        dictionary[SerializationKeys.isVideo] = isVideo
        dictionary[SerializationKeys.isAudio] = isAudio
        dictionary[SerializationKeys.isImage] = isImage
        dictionary[SerializationKeys.isRegister] = isRegister
        dictionary[SerializationKeys.isProfile] = isProfile
        dictionary[SerializationKeys.isInterest] = isInterest
        dictionary[SerializationKeys.userType] = userType
        if let value = imageList { dictionary[SerializationKeys.imageList] = value.map({$0.dictionaryRepresentation()}) }
        if let value = videoList { dictionary[SerializationKeys.videoList] = value.map({$0.dictionaryRepresentation()}) }
        if let value = interests { dictionary[SerializationKeys.interests] = value.map({$0.dictionaryRepresentation()}) }
        if let value = interestCategory { dictionary[SerializationKeys.interestCategory] = value.map({$0.dictionaryRepresentation()}) }
        
        return dictionary
    }
}


