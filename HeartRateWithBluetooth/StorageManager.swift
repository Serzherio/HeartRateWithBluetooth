import RealmSwift


let realm = try! Realm()

class StorageManager {
    
    static func saveObject (_ train: Train) {
        try! realm.write {
            realm.add(train)
        }
    }
    
    static func deleteObject (_ train: Train) {
        try! realm.write {
            realm.delete(train)
        }
    }
}
