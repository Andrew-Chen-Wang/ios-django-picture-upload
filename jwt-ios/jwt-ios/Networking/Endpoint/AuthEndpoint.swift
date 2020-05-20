//
//  AuthEndpoint.swift
//  jwt-ios
//
//  Created by Andrew Chen Wang on 3/2/20.
//  Copyright © 2020 Andrew Chen Wang. All rights reserved.
//

import Foundation

public enum AuthAPI {
    case access
    case both
    
    // Other API stuff
    case uploadToServer
}

extension AuthAPI: EndPointType {
    var environmentBaseURL : String {
        switch AuthNetworkManager.environment {
        case .local: return "http://127.0.0.1:8000/api/"
        // Return your actual domain
        case .staging: return "https://staging.themoviedb.org/3/movie/"
        case .production: return "https://api.themoviedb.org/3/movie/"
        }
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL could not be configured.") }
        return url
    }
    
    var httpMethod: HTTPMethod {
        return .post
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .access, .both:
            // Authentication does not need Bearer token for authentication
            return nil
        default:
            return ["Authorization": "Bearer \(getAuthToken(.access))"]
        }
    }
    
    var path: String {
        // The path for api/ is already in baseURL
        switch self {
        case .access:
            return "token/access/"
        case .both:
            return "token/both/"
        case .uploadToServer:
            return "presigned/"
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .access:
            return .requestParameters(
                bodyParameters: [
                    "refresh": getAuthToken(.refresh)
                ],
                bodyEncoding: .jsonEncoding,
                urlParameters: nil
            )
        case .both:
            let (user, pw) = getUserCredentials()
            return .requestParameters(
                bodyParameters: [
                    "username": user ?? "",
                    "password": pw ?? ""
                ],
                bodyEncoding: .jsonEncoding,
                urlParameters: nil
            )
        default:
            return .request
        }
    }
}
