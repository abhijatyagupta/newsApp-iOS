//
//  FirestoreManager.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 26/01/21.
//
import Firebase

class FirestoreManager {
    let db = Firestore.firestore()
    private var documentReference: DocumentReference?
    private var snapshotListener: ListenerRegistration?
    var secondListener: ListenerRegistration?
    
    func add(document: [String : Any], toCollection collection: String = K.FStore.markedNewsCollection, withName documentName: String, callback: @escaping (Error?) -> Void = { _ in }) {
        db.collection(collection).document(documentName).setData(document) { error in
            callback(error)
        }
    }
    
    func delete(document: String, fromCollection collection: String = K.FStore.markedNewsCollection, callback: @escaping (Error?) -> Void = { _ in }) {
        db.collection(collection).document(document).delete() { error in
            callback(error)
        }
    }
    
    func get(document: String, fromCollection collection: String = K.FStore.markedNewsCollection, callback: @escaping (DocumentSnapshot?, Error?) -> Void = { _, _  in }) {
        db.collection(collection).document(document).getDocument { (document, error) in
            callback(document, error)
        }
    }
    
    func update(document: String, fromCollection collection: String = K.FStore.markedNewsCollection,  withData data: [AnyHashable : Any], callback: @escaping (Error?) -> Void = { _ in }) {
        db.collection(collection).document(document).updateData(data) { error in
            callback(error)
        }
    }
    
    func getAllDocuments(fromCollection collection: String, callback: @escaping (QuerySnapshot?, Error?) -> Void = { _, _ in }) {
        db.collection(collection).getDocuments { (querySnapshot, error) in
            callback(querySnapshot, error)
        }
    }
    
    func addSnapshotListener(forDocument document: String, fromCollection collection: String = K.FStore.markedNewsCollection, callback: @escaping (DocumentSnapshot?, Error?) -> Void = { _, _  in }) {
        snapshotListener = db.collection(collection).document(document).addSnapshotListener { (document, error) in
//            print("listener attached")
            callback(document, error)
        }
    }
    
    func addCollectionListener(forCollection collection: String, andOrderBy field: String? = nil, descending: Bool = false, callback: @escaping (QuerySnapshot?, Error?) -> Void = { _, _ in }) {
        if let field = field {
            snapshotListener = db.collection(collection)
                .order(by: field, descending: descending)
                .addSnapshotListener { (querySnapshot, error) in
                    callback(querySnapshot, error)
                }
        }
        else {
            snapshotListener = db.collection(collection).addSnapshotListener { (querySnapshot, error) in
                callback(querySnapshot, error)
            }
        }
        
    }
    
    func detachSnapshotListener() {
        if let listener = snapshotListener {
            listener.remove()
//            print("listener detached!")
        }
    }
    
    func getNewListener(forDocument document: String, fromCollection collection: String, callback: @escaping (DocumentSnapshot?, Error?) -> Void = { _, _  in }) -> ListenerRegistration {
        let listener = db.collection(collection).document(document).addSnapshotListener { (document, error) in
            callback(document, error)
        }
        return listener
    }
    
    func detach(thisListener listener: ListenerRegistration?) {
        if let listener = listener {
            listener.remove()
        }
    }
    
}

//class Mark {
//    var realCount: Int
//    var fakeCount: Int
//
//    init(realCount: Int, fakeCount: Int) {
//        self.realCount = realCount
//        self.fakeCount = fakeCount
//    }
//}
