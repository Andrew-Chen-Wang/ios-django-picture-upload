//
//  AWSApiResponse.swift
//  jwt-ios
//
//  Created by Andrew Chen Wang on 5/20/20.
//  Copyright © 2020 Andrew Chen Wang. All rights reserved.
//

import Foundation

struct AWSApiResponse: Decodable {
    let url: URL
    let fields: [String: String]

    private enum CodingKeys: String, CodingKey {
        case url
        case fields
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try container.decode(URL.self, forKey: .url)
        fields = try container.decode([String: String].self, forKey: .fields)
    }
}
