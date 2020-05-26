//
//  StringExtension.swift
//  Fyndr
//
//  Created by BlackNGreen on 13/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import UIKit
import CommonCrypto

extension String
{
    func unformattedPhoneNumber() -> String{
        let correctChars : Set<Character> =
            Set("1234567890+")
        return String(self.filter {correctChars.contains($0) })
    }
    
    
    func removeSpecialCharsFromString() -> String {
        let correctChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+")
        return String(self.filter {correctChars.contains($0) })
    }
    
    
    func replaceCharacters(characters: String, toSeparator: String) -> String {
        let characterSet = NSCharacterSet(charactersIn: characters)
        let components = self.components(separatedBy: characterSet as CharacterSet)
        let result = components.joined(separator: "")
        return result
    }
    
    func removeCharacters(characters: String) -> String {
        return self.replaceCharacters(characters: characters, toSeparator: "")
    }
    
    func removePlus() -> String {
        return self.replaceCharacters(characters: "+", toSeparator: "")
    }
    
    
    func removeWhiteSpace() -> String {
       return self.replaceCharacters(characters: " ", toSeparator: "")
    }
    

    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = from16.samePosition(in: self),
            let to = to16.samePosition(in: self)
            else { return nil }
        return from ..< to
    }
    
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    enum RegularExpressions: String {
        case phone = "^\\s*(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*$"
    }
    
    func isValid(regex: RegularExpressions) -> Bool {
        return isValid(regex: regex.rawValue)
    }
    
    func isValid(regex: String) -> Bool {
        let matches = range(of: regex, options: .regularExpression)
        return matches != nil
    }
    
    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter{CharacterSet.decimalDigits.contains($0)}
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }
    
    func makeCall() {
        if isValid(regex: .phone) {
            if let url = URL(string: "tel://\(self.onlyDigits())"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    func sha256() -> String{
        if let stringData = self.data(using: String.Encoding.utf8) {
            return hexStringFromData(input: digest(input: stringData as NSData))
        }
        return ""
    }
    
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
    
    
    
    
    func byteUTF8ToString() -> String{
        let base64Encoded = self.removeCharacters(characters: "\n")
        if let decodedData = Data(base64Encoded: base64Encoded) {
            let decodedString = String(data: decodedData, encoding: .utf8)
            return decodedString ?? self
        }
        print("byteUTF8ToString error \(self) not able to convert")
        return self
    }
    
    
    func stringToUTF8Byte() -> String {
        let byte = self.data(using: .utf8)
        let utfString = byte?.base64EncodedString()
        let remainString = String(utfString ?? "")
        return remainString
    }
    
    
    
}
