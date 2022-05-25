//
//  Book.swift
//  MobileBook
//
//  Created by Yan on 4/19/22.
//

import Foundation
import FirebaseFirestore

struct Book: Identifiable,Codable{
    var id: String? = UUID().uuidString
    var name: String
    var author: String
    var year: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case author
        case year
    }
}
