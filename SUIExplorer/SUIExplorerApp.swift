//
//  SUIExplorerApp.swift
//  SUIExplorer
//
//  Created by Kenny Leung on 8/28/20.
//

import SwiftUI

@main
struct SUIExplorerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
