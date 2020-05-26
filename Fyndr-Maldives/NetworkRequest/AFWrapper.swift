//
//  AFWrapper.swift
//  Fyndr
//
//  Created by BlackNGreen on 21/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class AFWrapper {
    
    open class fyndrServerTrustPolicyManager: ServerTrustPolicyManager {
        // Override this function in order to trust any self-signed https
        open override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
            return ServerTrustPolicy.disableEvaluation
        }
    }
    
    static let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(timeoutIntervalForRequest)
        //let sessionManager = Alamofire.SessionManager(configuration: configuration)
       
        let trustPolicies = fyndrServerTrustPolicyManager(policies: [:])
        let sessionManager = Alamofire.SessionManager(configuration: configuration, delegate: SessionDelegate(), serverTrustPolicyManager: trustPolicies)
        return sessionManager
    }()
    
    func downloadRequest(_ url:String, destinationUrl : String,param:[String: Any]?,headers: [String : String]?,completionHandler:@escaping (JSON?, Error?,Progress?) -> Void)
    {
        let encodedUrlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        print("URL : \(String(describing: encodedUrlString))")
        
        guard let urlString = encodedUrlString else {
            completionHandler(nil,AppError.invalidRequestURL,nil)
            return
        }
        
        /*
         guard let documentsURL = AppFileManager.init().getRecodingFileUrl() else {
         completionHandler(nil,AppError.custom(message: "Destination URL not found"),nil)
         return
         }
         */
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (URL.init(fileURLWithPath: destinationUrl), [.removePreviousFile])
        }
        
        AFWrapper.sessionManager.download(urlString, method: .get, parameters: param, encoding: JSONEncoding.default, headers: headers, to: destination).downloadProgress { (progress) in
            
           //print("Progress : \(progress.fractionCompleted)")
                completionHandler(nil,nil,progress)
            }.response { (downloadResponse) in
                let response = downloadResponse
                print("download Response statusCode : \(String(describing: response.response?.statusCode))")

                if response.response?.statusCode == 200 {
                    print(" destinationURL : \(String(describing: response.destinationURL))")
                    completionHandler(JSON(),nil,nil)
                    return
                    
                } else if response.response?.statusCode == 401 {
                    APP_DELEGATE.sessionExpired()
                    completionHandler(nil,AppError.invalidAuthCredentials,nil)
                    return
                }
                else if response.response?.statusCode == 500 {
                    completionHandler(nil,AppError.serverNotResponding,nil)
                    return
                }else if response.response?.statusCode == 400 {
                    
                }
                if response.error == nil {
                    completionHandler(nil, AppError.genricError,nil)
                    return
                }
                completionHandler(nil,response.error,nil)
                return
        }
    }
    
    //MARK:- Get Service Call
    func getRequest(_ url:String,param:[String: Any]?, headers: [String : String]?,completionHandler:@escaping (JSON?,Error?) -> Void){
        
        let encodedUrlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        print("URL : \(String(describing: encodedUrlString))")
        
        guard let urlString = encodedUrlString else {
            completionHandler(nil,AppError.invalidRequestURL)
            return
        }
        
        AFWrapper.sessionManager.request(urlString, method:.get, parameters:nil,encoding:JSONEncoding.default, headers: headers).responseJSON { (response) in
            if response.response?.statusCode == 200 {
                //  if(response.result.isSuccess) {
                if let data = response.result.value {
                    let post = JSON(data)
                    
                    let response = Response.init(json: post)
                    if response.isLogout
                    {
                        APP_DELEGATE.logoutFromDevice(message: response.reason ?? NSLocalizedString("M_LOG_OUT", comment: ""))
                        return
                    }
                    
                    if let _ = post.dictionary {
                        completionHandler(post,nil)
                        return
                    }
                }
                completionHandler(nil,AppError.invalidReponseJson)
                return
                // }
            } else if response.response?.statusCode == 401 {
                
                APP_DELEGATE.sessionExpired()
                completionHandler(nil,AppError.invalidAuthCredentials)
                return
            }
            else if response.response?.statusCode == 500 {
                completionHandler(nil,AppError.serverNotResponding)
                return
            }else if response.response?.statusCode == 400 {
                if let data = response.result.value {
                    let post = JSON(data)
                    if let _ = post.dictionary {
                        completionHandler(post,nil)
                        return
                    }
                }
            }
            if response.result.error == nil {
                completionHandler(nil, AppError.genricError)
                return
            }
            completionHandler(nil,response.result.error)
            return
        }
    }
    
    
    func deleteVideoGetRequest(_ url:String,param:[String: Any]?, headers: [String : String]?,completionHandler:@escaping (JSON?,Error?) -> Void){
        
        let encodedUrlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        print("URL : \(String(describing: encodedUrlString))")
        
        guard let urlString = encodedUrlString else {
            completionHandler(nil,AppError.invalidRequestURL)
            return
        }
        
        AFWrapper.sessionManager.request(urlString, method:.delete, parameters:param,encoding:JSONEncoding.default, headers: headers).responseJSON { (response) in
            if response.response?.statusCode == 200 {
                //  if(response.result.isSuccess) {
                if let data = response.result.value {
                    let post = JSON(data)
                    
                    let response = Response.init(json: post)
                    if response.isLogout
                    {
                        APP_DELEGATE.logoutFromDevice(message: response.reason ?? NSLocalizedString("M_LOG_OUT", comment: ""))
                        return
                    }
                    
                    if let _ = post.dictionary {
                        completionHandler(post,nil)
                        return
                    }
                }
                completionHandler(nil,AppError.invalidReponseJson)
                return
                // }
            } else if response.response?.statusCode == 401 {
                
                APP_DELEGATE.sessionExpired()
                completionHandler(nil,AppError.invalidAuthCredentials)
                return
            }
            else if response.response?.statusCode == 500 {
                completionHandler(nil,AppError.serverNotResponding)
                return
            }else if response.response?.statusCode == 400 {
                if let data = response.result.value {
                    let post = JSON(data)
                    if let _ = post.dictionary {
                        completionHandler(post,nil)
                        return
                    }
                }
            }
            if response.result.error == nil {
                completionHandler(nil, AppError.genricError)
                return
            }
            completionHandler(nil,response.result.error)
            return
        }
    }
    
    
    
    
    func postRequest(_ url:String, param:[String: Any]?, headers:[String : String]?, completionHandler:@escaping (JSON?, Error?) -> Void){
        
        let encodedUrlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        print("API URL : \(String(describing: encodedUrlString))")
        param?.printInputJson(withParams: param)
        
        guard let urlString = encodedUrlString else {
            completionHandler(nil,AppError.invalidRequestURL)
            return
        }
        
        AFWrapper.sessionManager.request(urlString, method: .post, parameters: param, encoding:JSONEncoding.default, headers: headers).responseJSON { (response) in
            
            print("API response url : \(url)")
            print("API response status : \(String(describing: response.response?.statusCode)) : \((JSON(response.result.value ?? "")))")
            
            if response.response?.statusCode == 200 {
                // if(response.result.isSuccess) {
                if let data = response.result.value {
                    let post = JSON(data)
                    let response = Response.init(json: post)
                    if response.isLogout
                    {
                        APP_DELEGATE.logoutFromDevice(message: response.reason ?? NSLocalizedString("M_LOG_OUT", comment: ""))
                        return
                    }
                    
                    if let _ = post.dictionary {
                        completionHandler(post,nil)
                        return
                    }
                }
                completionHandler(nil,AppError.invalidReponseJson)
                return
                
                //  }
            } else if response.response?.statusCode == 401 {
                APP_DELEGATE.sessionExpired()
                completionHandler(nil,AppError.invalidAuthCredentials)
                return
            }
            else if response.response?.statusCode == 500 {
                completionHandler(nil,AppError.serverNotResponding)
                return
            }else if response.response?.statusCode == 400 {
                if let data = response.result.value {
                    let post = JSON(data)
                    if let _ = post.dictionary {
                        completionHandler(post,nil)
                        return
                    }
                }
            }
            if response.result.error == nil {
                completionHandler(nil, AppError.genricError)
                return
            }
            completionHandler(nil,response.result.error)
            return
        }
    }
    
    
    func uploadRequest1(fromUrl : String ,toUrl:String, headers:[String : String]?, completionHandler:@escaping (JSON?, Error?) -> Void) {
        
        let encodedUrlString = toUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        print("URL : \(String(describing: encodedUrlString))")
        
        guard let urlString = encodedUrlString else {
            completionHandler(nil,AppError.invalidRequestURL)
            return
        }
        
        guard let fromUrl = URL.init(string: fromUrl) else {
            completionHandler(nil,AppError.invalidRequestURL)
            return
        }
        
        AFWrapper.sessionManager.upload(fromUrl , to: urlString, method: .post, headers: headers).responseJSON { (response) in
            if response.response?.statusCode == 200 {
               // if(response.result.isSuccess) {
                    if let data = response.result.value {
                        let post = JSON(data)
                        if let _ = post.dictionary {
                            completionHandler(post,nil)
                            return
                        }
                    }
                completionHandler(nil,AppError.invalidReponseJson)
                return
              //  }
            } else if response.response?.statusCode == 401 {
                APP_DELEGATE.sessionExpired()
                completionHandler(nil,AppError.invalidAuthCredentials)
                return
            }
            else if response.response?.statusCode == 500 {
                completionHandler(nil,AppError.serverNotResponding)
                return
            }else if response.response?.statusCode == 400 {
                if let data = response.result.value {
                    let post = JSON(data)
                    if let _ = post.dictionary {
                        completionHandler(post,nil)
                        return
                    }
                }
            }
            if response.result.error == nil {
                completionHandler(nil, AppError.genricError)
                return
            }
            completionHandler(nil,response.result.error)
            return
        }
    }
    
    func uploadRequest(data : Data, fileName : String,  resourceUrl:String, param:[String: String]?, headers:[String : String]?, completionHandler:@escaping (JSON?, Error?,Progress?) -> Void) {
        
        let encodedUrlString = resourceUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        print("URL : \(String(describing: encodedUrlString))")
        
        guard let urlString = encodedUrlString else {
            completionHandler(nil,AppError.invalidRequestURL,nil)
            return
        }
        
        AFWrapper.sessionManager.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(data, withName: "file", fileName: fileName , mimeType: "image/jpg")
            
            if let parameter = param
            {
                for (key, value) in parameter {
                    
                    if let data = value.data(using: String.Encoding.utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                }
            }            
        },to: urlString, headers : Request.requestHeaderParameter()) { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    // print("Upload Progress: \(progress.fractionCompleted)")
                    completionHandler(nil,nil,progress)
                })
                
                upload.responseJSON { response in
                    print(response.result.value ?? "")
                    
                    if response.response?.statusCode == 200 {
                        //if(response.result.isSuccess) {
                            if let data = response.result.value {
                                let post = JSON(data)
                                if let _ = post.dictionary {
                                    completionHandler(post,nil,nil)
                                    return
                                }
                            }
                        completionHandler(nil,AppError.invalidReponseJson,nil)
                        return
                       // }
                    } else if response.response?.statusCode == 401 {
                        APP_DELEGATE.sessionExpired()
                        completionHandler(nil,AppError.invalidAuthCredentials,nil)
                        return
                    }
                    else if response.response?.statusCode == 500 {
                        completionHandler(nil,AppError.serverNotResponding,nil)
                        return
                    }else if response.response?.statusCode == 400 {
                        if let data = response.result.value {
                            let post = JSON(data)
                            if let _ = post.dictionary {
                                completionHandler(post,nil,nil)
                                return
                            }
                        }
                    }
                    
                    if response.result.error == nil {
                        completionHandler(nil, AppError.genricError,nil)
                        return
                    }
                    completionHandler(nil,response.result.error,nil)
                    
                }
            case .failure(let encodingError):
                print("Failed \(encodingError)" )
                completionHandler(nil, AppError.custom(message: encodingError.localizedDescription) ,nil)
            }
        }
    }
    
    
    func deleteRequest(_ url:String, param:[String: Any]?, headers:[String : String]?, completionHandler:@escaping (JSON?, Error?) -> Void) {
        
        param?.printInputJson(withParams: param)
        
        let encodedUrlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let urlString = encodedUrlString else {
            completionHandler(nil,AppError.invalidRequestURL)
            return
        }
        
        AFWrapper.sessionManager.request(urlString, method: .delete, parameters: param, encoding:JSONEncoding.default, headers: headers).responseJSON { (response) in
            if response.response?.statusCode == 200 {
                // if(response.result.isSuccess) {
                if let data = response.result.value {
                    let post = JSON(data)

                    let response = Response.init(json: post)
                    if response.isLogout
                    {
                        APP_DELEGATE.logoutFromDevice(message: response.reason ?? NSLocalizedString("M_LOG_OUT", comment: ""))
                        return
                    }
                    
//                    let isLogout = post["isLogout"].boolValue
//                    if isLogout {
//                        APP_DELEGATE.logoutFromDevice(message : "")
//                    }
                    
                    if let _ = post.dictionary {
                        completionHandler(post,nil)
                        return
                    }
                }
                completionHandler(nil,AppError.invalidReponseJson)
                return
                //}
            } else if response.response?.statusCode == 401 {
                APP_DELEGATE.sessionExpired()
                completionHandler(nil,AppError.invalidAuthCredentials)
                return
            }
            else if response.response?.statusCode == 500 {
                completionHandler(nil,AppError.serverNotResponding)
                return
            }else if response.response?.statusCode == 400 {
                if let data = response.result.value {
                    let post = JSON(data)
                    if let _ = post.dictionary {
                        completionHandler(post,nil)
                    }
                }
            }
            if response.result.error == nil {
                completionHandler(nil, AppError.genricError)
                return
            }
            completionHandler(nil,response.result.error)
            return
        }
    }
    
    func cancelRequestWithUrl(url : String)
    {
        print("Cancelling request with URL : \(url)")
        AFWrapper.sessionManager.session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
            dataTasks.forEach({
                if ($0.originalRequest?.url?.absoluteString == url){
                    $0.cancel()
                    print("Data Request cancelled with URL : \(url)")
                }
            })
            uploadTasks.forEach({
                if ($0.originalRequest?.url?.absoluteString == url){
                    $0.cancel()
                    print("Upload request cancelled with URL : \(url)")
                }
            })
            downloadTasks.forEach({
                if ($0.originalRequest?.url?.absoluteString == url){
                    $0.cancel()
                    print("Downlaod request cancelled with URL : \(url)")
                }
            })
        }
    }
    
    func cancelAllRequest()
    {
        AFWrapper.sessionManager.session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
            print("Cancelling all request")
            
            dataTasks.forEach { $0.cancel() }
            uploadTasks.forEach { $0.cancel() }
            downloadTasks.forEach { $0.cancel() }
        }
    }
    
    func isRequestInProgress(url : String) -> Bool
    {
        /*
        AFWrapper.sessionManager.session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
            dataTasks.forEach({
                if ($0.originalRequest?.url?.absoluteString == url){
                   return true
                }
            })
            downloadTasks.forEach({
                if ($0.originalRequest?.url?.absoluteString == url){
                    return true
                }
            })
        }
        */
        return false
    }
    
    
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

extension Dictionary {
    func printInputJson(withParams params: [String: Any]?) {
        guard let paramsValue = params else {
            return
        }
        let jsonData = try? JSONSerialization.data(withJSONObject: paramsValue, options: [])
        guard let jsonDataObj = jsonData else {
            return
        }
        let jsonString = String(data: jsonDataObj, encoding: .utf8)
        print("API Input Json :\(jsonString ?? "No Json")")
    }
}
