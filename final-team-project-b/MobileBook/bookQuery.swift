//
//  bookQuery.swift
//  MobileBook
//
//  Created by Yan on 4/19/22.
//

import Foundation
import FirebaseFirestore

class bookQuery {
    let database = Firestore.firestore()

    func get(collectionID: String, handler: @escaping ([books]) -> Void) {
        database.collection("books")
            .addSnapshotListener { querySnapshot, err in
                if let error = err {
                    print(error)
                    handler([])
                } else {
                    handler(books.build(from: querySnapshot?.documents ?? []))
                }
            }
    }
}
