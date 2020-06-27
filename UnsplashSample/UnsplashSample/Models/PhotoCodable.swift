//
//  PhotoCodable.swift
//  UnsplashSample
//
//  Created by Gilwan Ryu on 2020/06/26.
//  Copyright © 2020 GilwanRyu. All rights reserved.
//

import UIKit

struct SearchPhoto: Codable {
    var totalPages: Int
    var totalCount: Int
    var results: [Photo]
    
    enum CodingKeys: String, CodingKey {
        case totalPages = "total_pages"
        case totalCount = "total"
        case results
    }
}

struct Photo: Codable {
    var color: String
    var height: Int
    var width: Int
    var user: User
    var urls: Urls
}

struct User: Codable {
    var name: String
}

struct Urls: Codable {
    var full: String
    var regular: String
    var small: String
}
