//
//  FileManager.swift
//  Fyndr
//
//  Created by BlackNGreen on 13/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

class AppFileManager : NSObject {
    
    let directoryName = "fyndr"
    
    func copyAndDeleteRecordingFile(from : URL) {
        let fileManager = FileManager.default
        let destinationPath = self.getFolderPath().appendingPathComponent("story.mp4")
        do {
            try fileManager.copyItem(at: from, to: URL(fileURLWithPath: destinationPath))
            try fileManager.removeItem(at: from)
        }
        catch let error as NSError {
            print("Unable to copy And Delete Recording File : \(error)")
        }
    }
    
    func getRecodingFilePath() -> String
    {
        let filePath = self.getFolderPath().appendingPathComponent("story.mp4")
        print("getRecodingFilePath()   path- \(filePath)" )

        return self.getFolderPath().appendingPathComponent("story.mp4")
        
        
    }
    
    func deleteMyRecodingFile()
    {
        self.deleteFile(fileName: "story.mp4")
    }
    
    func getRecodingFileUrl() -> URL?
    {
        let filePath = "file://\(self.getFolderPath().appendingPathComponent("story.mp4"))"
        print("getRecodingFileUrl()   path- \(filePath)" )
        return URL.init(string: filePath)
    }
    
    func getRecodingThumFilePath() -> String
    {
        return self.getFolderPath().appendingPathComponent("story_thumb.jpg")
    }
    
    func saveThumImage(image : UIImage) {
        let fileManager = FileManager.default
        let paths = self.getFolderPath().appendingPathComponent("story_thumb.jpg")
        let imageData = image.jpegData(compressionQuality: 1)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
    }
    
    func saveThumImageAt(atPath : String, image : UIImage) {
        let fileManager = FileManager.default
        let imageData = image.jpegData(compressionQuality: 1)
        fileManager.createFile(atPath: atPath as String, contents: imageData, attributes: nil)
    }
    
    func deleteFileFrom(url: URL)
    {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: url.absoluteString) {
            do{
                try fileManager.removeItem(atPath: url.absoluteString)
            }catch let error as NSError {
                print("Fail to delete file : \(error)")
            }
        }else {
            print("Fail not found for deletion : \(url)")

        }
    }
    func deleteFileFromPath(filePath : String)
    {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            do{
                try fileManager.removeItem(atPath: filePath)
            }catch let error {
                print("Fail to delete file : \(error)")
            }
        }else {
            print("deleteFileFromPathf()  file not found to delete filePath -\(filePath)")
        }
    }

    
    func isFileExistAt(path : String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }

    
    func getFolderPath() -> NSString {
        let fileManager = FileManager.default
        let paths = self.getDirectoryPath().appendingPathComponent(directoryName)
        if !fileManager.fileExists(atPath: paths){
            try! fileManager.createDirectory(atPath: paths, withIntermediateDirectories: true, attributes: nil)
        }
        return paths as NSString
    }
    
    func getDirectoryPath() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory as NSString
    }
    
    
    
    
    func getViodeRecordingFilePath() -> URL?
    {
        let videoPath =  self.getFolderPath().appendingPathComponent("tempvideo.mov")
        return URL(fileURLWithPath: videoPath)
    }
    
    
    
    
    // Pass file name with extension
    func saveFile(fileData : Data , name : String) -> Bool{
        let fileManager = FileManager.default
        let paths = self.getFolderPath().appendingPathComponent(name)
        return fileManager.createFile(atPath: paths as String, contents: fileData, attributes: nil)
    }
    
    func saveImage(image : UIImage , name : String) {
        let fileManager = FileManager.default
        let paths = self.getFolderPath().appendingPathComponent(name)
        let imageData = image.jpegData(compressionQuality: 1)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
    }
    
    func getImage(name : String) -> UIImage? {
        let fileManager = FileManager.default
        let imagePath = self.getFolderPath().appendingPathComponent(name)
        if fileManager.fileExists(atPath: imagePath){
            return UIImage(contentsOfFile: imagePath)
        }
        return nil
    }
    
    func isFileExist(fileName : String) -> Bool {
        let paths = self.getFolderPath().appendingPathComponent(fileName)
        return FileManager.default.fileExists(atPath: paths)
    }
    
    func filePath(fileNameWithExtension : String) -> String {
        return self.getFolderPath().appendingPathComponent(fileNameWithExtension)
    }
    
    func fileNameFromUrl(url : String?) -> String? {
        
        if url != nil {
            let urlComponents = url?.components(separatedBy: "/")
            if (urlComponents != nil && (urlComponents?.count)! > 0 ){
                return urlComponents?.last
            }
        }
        return nil
    }
    
    
    func isFileExistInBundle(fileName : String, fileExtension: String) -> Bool{
        guard Bundle.main.path(forResource: fileName, ofType: fileExtension) != nil else {
            return false
        }
        return true
    }
    
    func filePathInBundle(fileName : String, fileExtension: String) -> String? {
        return Bundle.main.path(forResource: fileName, ofType: fileExtension)
    }
    
    
    func copyFile(from : URL, fileName : String) {
        let fileManager = FileManager.default
        let destinationPath = self.getFolderPath().appendingPathComponent(fileName)
        do {
            try fileManager.copyItem(at: from, to: URL(fileURLWithPath: destinationPath))
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
    
    
    func deleteFile(fileName : String)
    {
        let fileManager = FileManager.default
        let filePath = self.getFolderPath().appendingPathComponent(fileName)
        if fileManager.fileExists(atPath: filePath){
            do{
                try fileManager.removeItem(atPath: filePath)
            }catch let error as NSError {
                print("Fail to delete file : \(error)")
            }
        }
    }
    
    func deleteDirectory(){
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(directoryName)
        if fileManager.fileExists(atPath: paths){
            try! fileManager.removeItem(atPath: paths)
        }else{
            print("Unable to delete directory")
        }
    }
    
    
    func deleteViodeRecordingFile()
    {
        let fileManager = FileManager.default
        let filePath = self.getFolderPath().appendingPathComponent("tempvideo.mov")
        
        if fileManager.fileExists(atPath: filePath){
            do{
                try fileManager.removeItem(atPath: filePath)
            }catch let error as NSError {
                print("Fail to delete file : \(error)")
            }
        }
    }
    
    func getFinalViodeFilePath() -> URL?
    {
        let videoPath =  self.getFolderPath().appendingPathComponent("mystorey.mp4")
        return URL(fileURLWithPath: videoPath)
    }
    
    func deleteFinalViodeFile()
    {
        let fileManager = FileManager.default
        let filePath = self.getFolderPath().appendingPathComponent("mystorey.mp4")
        if fileManager.fileExists(atPath: filePath){
            do{
                try fileManager.removeItem(atPath: filePath)
            }catch let error as NSError {
                print("Fail to delete final video file : \(error)")
            }
        }
    }
    
}
