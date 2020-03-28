//
//  CoreDataStack.swift
//  coredata_populate
//
//  Created by Alexey Smirnov on 3/5/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    let appSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!

    func initDB() {
        let url = appSupportDirectory.appendingPathComponent("coredata_populate.sqlite")
        
        if !FileManager.default.fileExists(atPath: url.path) {
            print("Copying DB...")
            
            do {
                try FileManager.default.createDirectory(at: appSupportDirectory, withIntermediateDirectories: true, attributes: nil)
                
                let sourceURLs = [Bundle.main.url(forResource: "coredata_populate.sqlite", withExtension: nil),
                                  Bundle.main.url(forResource: "coredata_populate", withExtension: "sqlite-shm"),
                                  Bundle.main.url(forResource: "coredata_populate", withExtension: "sqlite-wal")
                ]
                
                let destURLs = [appSupportDirectory.appendingPathComponent("coredata_populate.sqlite"),
                                appSupportDirectory.appendingPathComponent("coredata_populate.sqlite-shm"),
                                appSupportDirectory.appendingPathComponent("coredata_populate.sqlite-wal")
                ]
                
                for (index, _) in sourceURLs.enumerated() {
                    try FileManager.default.copyItem(atPath: sourceURLs[index]!.path, toPath: destURLs[index].path)
                }
            } catch {
                print(error)
            }
        }
    }
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "coredata_populate")
        
        let localStoreLocation = appSupportDirectory.appendingPathComponent("coredata_populate.sqlite")
        let localStoreDescription = NSPersistentStoreDescription(url: localStoreLocation)
        localStoreDescription.configuration = "Local"
        
        let cloudStoreLocation = appSupportDirectory.appendingPathComponent("coredata_cloud.sqlite")
        let cloudStoreDescription = NSPersistentStoreDescription(url: cloudStoreLocation)
        cloudStoreDescription.configuration = "Cloud"
        
        cloudStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.rlc.lanternhsk4")
        
        cloudStoreDescription.setOption(true as NSNumber,
                               forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        let remoteChangeKey = "NSPersistentStoreRemoteChangeNotificationOptionKey"
        cloudStoreDescription.setOption(true as NSNumber, forKey: remoteChangeKey)
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        container.persistentStoreDescriptions = [
            cloudStoreDescription,
            localStoreDescription
        ]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
       //  try! container.initializeCloudKitSchema(options: [.printSchema])
        
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}


