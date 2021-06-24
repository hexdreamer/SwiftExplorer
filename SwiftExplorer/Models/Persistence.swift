//
//  Persistence.swift
//  SwiftExplorer
//
//  Created by Zach Young on 6/24/21.
//  Copyright © 2021 Kenny Leung. All rights reserved.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // Match the name of the xcdatamdodeld file
        container = NSPersistentContainer(name: "SEModel")

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }

    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Unexpected error in MOC save(): \(error)")
            }
        }
    }
}
