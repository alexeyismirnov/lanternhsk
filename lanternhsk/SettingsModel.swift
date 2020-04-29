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
    
    @Published var settings: SettingsEntity = SettingsEntity()
    let settingsChanged = PassthroughSubject<Void, Never>()

    init() {
        self.reload()
    }
    
    func reload() {
        let request: NSFetchRequest<SettingsEntity> = SettingsEntity.fetchRequest()

        let results = try! context.fetch(request)

        if let settings = results.first {
            self.settings = settings
            
        } else {
            let settings = SettingsEntity(context: context)
            settings.language = 0
            settings.numQuestions = 3
            self.settings = settings
        }
    }
    
    var language: Int  {
        get {
            return Int(settings.language)
        }
        set (newValue) {
            settings.language = Int32(newValue)
            try! context.save()

            settingsChanged.send()
        }
    }
    
    var numQuestions: Double  {
        get {
            return Double(settings.numQuestions)
        }
        set (newValue) {
            settings.numQuestions = Int32(newValue.rounded())
            try! context.save()
            
            settingsChanged.send()
        }
    }
}

