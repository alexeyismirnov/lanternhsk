//
//  SettingsModel.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 4/9/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//


import SwiftUI
import Combine
import CoreData

enum SettingsCharType: Int {
    case traditional = 0, simplified = 1
}

class SettingsModel: ObservableObject {
    static let shared = SettingsModel()
    
    let context = CoreDataStack.shared.persistentContainer.viewContext
    let request: NSFetchRequest<SettingsEntity> = SettingsEntity.fetchRequest()

    let settingsChanged = PassthroughSubject<Void, Never>()

    func fetchOrCreate() -> SettingsEntity {
        let results = try! context.fetch(request)

        if let settings = results.first {
            return settings
            
        } else {
            let settings = SettingsEntity(context: context)
            settings.language = 0
            settings.numQuestions = 3
            
            return settings
        }
    }
    
    var language: Int  {
        get {
            return Int(fetchOrCreate().language)
        }
        set (newValue) {
            let settings = fetchOrCreate()
            settings.language = Int32(newValue)
            try! context.save()

            settingsChanged.send()
        }
    }
    
    var numQuestions: Double  {
        get {
            return Double(fetchOrCreate().numQuestions)
        }
        set (newValue) {
            let settings = fetchOrCreate()
            settings.numQuestions = Int32(newValue.rounded())
            try! context.save()
            
            settingsChanged.send()
        }
    }
}

