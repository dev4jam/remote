//
//  ModelCache.swift
//  Remote
//
//  Created by Dmitry Klimkin on 18/12/17.
//  Copyright © 2017 Dev4Jam. All rights reserved.
//

import Foundation
import RealmSwift

@objc
class CacheObject: Object {
    func copyToSave() -> CacheObject {
        return self
    }
}

struct ModelCache {
    private let realmDbSchemaVersion: UInt64 = 0

    init(cacheContainerId: String, encryptionKey: Data? = nil, fileManager: FileManager = FileManager.default) {

        var config = Realm.Configuration()
        
        config.schemaVersion = realmDbSchemaVersion
        config.encryptionKey = encryptionKey
        
        config.migrationBlock = {(migration: Migration, oldSchemaVersion: UInt64) in
            if oldSchemaVersion < 1 {
            }
        }
        
        let containerUrl = fileManager.containerURL(forSecurityApplicationGroupIdentifier: cacheContainerId)
        
        if let containerUrl = containerUrl {
            let directory: URL = containerUrl
            let realmPath = "\(directory.path)/db.realm"
            
            config.fileURL = URL(fileURLWithPath:realmPath)
        }
        
        Realm.Configuration.defaultConfiguration = config
    }
    
    func getContext() -> Realm? {
        let realm = try? Realm()
        
        return realm
    }
    
    func save(_ object: CacheObject) {
        let objectToSave = object.copyToSave()
        guard let context = getContext() else { return }
        
        try? context.write {
            context.add(objectToSave, update: true)
        }
    }

    func save(_ objects: [CacheObject]) {
        let objectsToSave = objects.map { $0.copyToSave() }
        guard let context = getContext() else { return }

        try? context.write {
            for object in objectsToSave {
                context.add(object, update: true)
            }
        }
    }
    
    func delete(_ object: CacheObject) {
        guard let context = getContext() else { return }

        try? context.write {
            context.delete(object)
        }
    }
    
    func update(_ block: @escaping (() -> Void)) {
        guard let context = getContext() else { return }

        try? context.write {
            block()
        }
    }
    
    func wipe() {
        guard let context = getContext() else { return }

        try? context.write {
            context.deleteAll()
        }
    }
}

fileprivate extension Date {
    var timestamp: String {
        return String(format: "%.0f", timeIntervalSince1970 * 1000)
    }
    
    var timestampInt: Int {
        return Int(round(timeIntervalSince1970 * 1000))
    }
}

final class CachedServiceResponse: CacheObject {
    @objc dynamic var key: String = ""
    @objc dynamic var data: Data?
    
    convenience init(key: String, data: Data) {
        self.init()
        
        self.key = key
        self.data = data
    }
    
    override class func primaryKey() -> String? {
        return "key"
    }
    
    override func copyToSave() -> CacheObject {
        guard !key.isEmpty else {
            fatalError("`key` must have a value")
        }
        
        let newObject = CachedServiceResponse()
        
        newObject.key  = key
        newObject.data = data
        
        return newObject
    }
}

extension ModelCache {
    func loadResponse(for key: String) -> Data? {
        guard let context = getContext() else { return nil }

        let filter = NSPredicate(format: "key ==[c] %@", key)
        let cachedResponses = context.objects(CachedServiceResponse.self).filter(filter)

        guard !cachedResponses.isEmpty else { return nil }
        
        return cachedResponses[0].data
    }
}
