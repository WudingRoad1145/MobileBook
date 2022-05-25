//
//  bookFirebase.swift
//  MobileBook
//
//  Created by Yan on 4/19/22.
//

import Foundation
import FirebaseFirestore

extension books {
    static func build(from documents: [QueryDocumentSnapshot]) -> [books] {
        var userBooks = [books]()
        for document in documents {
            userBooks.append(books(name: document["bookName"] as? String ?? "",
                              author: document["author"] as? String ?? "",
                             year:document["year"] as? String ?? "",
                             coord:document["dropOffLoc"] as? Array ?? [0,0]))
        }
        return userBooks
    }
}
