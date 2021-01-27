//
//  FirestoreManager.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 26/01/21.
//

import Foundation
import Firebase

class FirestoreManager {
    private let db = Firestore.firestore()
    private var documentReference: DocumentReference?
    
    func add(document: [String : Any], toCollection collection: String, withName documentName: String, callback: @escaping (Error?) -> Void = { _ in }) {
        db.collection(collection).document(documentName).setData(document) { error in
            callback(error)
        }
    }
    
    func delete(document: String, fromCollection collection: String = "markedNews", callback: @escaping (Error?) -> Void = { _ in }) {
        db.collection(collection).document(document).delete() { error in
            callback(error)
        }
    }
    
}
