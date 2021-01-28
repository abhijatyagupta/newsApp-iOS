//
//  FirestoreManager.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 26/01/21.
//
import Firebase

class FirestoreManager {
    private let db = Firestore.firestore()
    private var documentReference: DocumentReference?
    private var snapshotListener: ListenerRegistration?
    
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
    
    func get(document: String, fromCollection collection: String = "markedNews", callback: @escaping (DocumentSnapshot?, Error?) -> Void = { _, _  in }) {
        db.collection(collection).document(document).getDocument { (document, error) in
            callback(document, error)
        }
    }
    
    func update(document: String, fromCollection collection: String = "markedNews",  withData data: [AnyHashable : Any], callback: @escaping (Error?) -> Void = { _ in }) {
        db.collection(collection).document(document).updateData(data) { error in
            callback(error)
        }
    }
    
    func addSnapshotListener(forDocument document: String, fromCollection collection: String = "markedNews", callback: @escaping (DocumentSnapshot?, Error?) -> Void = { _, _  in }) {
        snapshotListener = db.collection(collection).document(document).addSnapshotListener { (document, error) in
            callback(document, error)
        }
    }
    
    func detachSnapshotListener() {
        if let listener = snapshotListener {
            listener.remove()
            print("listener detached!")
        }
    }
    
}
