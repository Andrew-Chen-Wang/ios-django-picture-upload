//
//  NetworkResponse.swift
//  jwt-ios
//
//  Created by Andrew Chen Wang on 3/3/20.
//  Copyright © 2020 Andrew Chen Wang. All rights reserved.
//

import Foundation

enum NetworkResponse: String {
    case success
    case authenticationError = "You need to be authenticated first."
    case badRequest = "Bad request"
    case serverError = "There was an issue on the server."
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
}

enum Result<String> {
    case success
    case failure(String)
}

fileprivate struct ErrorResponse: Decodable {
    let error: String
    
    private enum CodingKeys: String, CodingKey {
        case error
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        error = try container.decode(String.self, forKey: .error)
    }
}

func returnDefaultErrorMessage(code: Int) -> String {
    switch code {
    case 401: return NetworkResponse.authenticationError.rawValue
    case 400...500: return NetworkResponse.badRequest.rawValue
    case 501...599: return NetworkResponse.serverError.rawValue
    case 600: return NetworkResponse.outdated.rawValue
    default: return NetworkResponse.failed.rawValue
    }
}

func handleNetworkResponse(_ response: HTTPURLResponse, _ data: Data?) -> Result<String> {
    if (200...299).contains(response.statusCode) {
        return .success
    } else {
        guard let responseData = data else {
            return .failure(returnDefaultErrorMessage(code: response.statusCode))
        }
        do {
            print(responseData)
            let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
            print(jsonData)
            let apiResponse = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
            return .failure(apiResponse.error)
        } catch {
            print("WTF")
            return .failure(returnDefaultErrorMessage(code: response.statusCode))
        }
    }
}
