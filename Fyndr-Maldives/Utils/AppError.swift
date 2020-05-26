//
//  AppError.swift
//  Fyndr
//
//  Created by BlackNGreen on 22/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

public enum AppError : Error {
    case invalidRequestURL
    case invalidReponseJson
    case invalidAuthCredentials
    case serverNotResponding
    case badRequest
    case genricError
    case invalidHash
    case custom(message : String)
    case fileNotFound
    case failedTodownlaodVideo
    case noInternet


}

extension AppError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .genricError:
            return NSLocalizedString("Something went wrong", comment: "App Error")
        case .badRequest:
            return NSLocalizedString("Bad Request error", comment: "App Error")
        case .invalidRequestURL:
            return NSLocalizedString("Invalid reques URL", comment: "App Error")
        case .invalidReponseJson:
            return NSLocalizedString("Invalid response", comment: "App Error")
        case .invalidAuthCredentials:
            return NSLocalizedString("Invalid auth credentials", comment: "App Error")
        case .serverNotResponding:
            return NSLocalizedString("Server Not Responding", comment: "App Error")
        case .invalidHash:
            return NSLocalizedString("Invalid Hash", comment: "App Error")
        case .fileNotFound:
            return NSLocalizedString("File not found", comment: "App Error")
        case .failedTodownlaodVideo:
            return NSLocalizedString("Unable to download video", comment: "App Error")
        case .noInternet:
            return NSLocalizedString("Please check your internet connection", comment: "App Error")
        case .custom(let message):
            return NSLocalizedString(message, comment: "App Error")
        }
    }
}
