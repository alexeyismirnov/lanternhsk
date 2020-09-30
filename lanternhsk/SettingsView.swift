//
//  SettingsView.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 4/9/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import SwiftUI
import CoreData

struct SettingsView: View {    
    @ObservedObject var model = SettingsModel.shared
    @State private var trigger: Bool = false

    private var didSave =  NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)

    var body: some View {
        print("\(trigger)")
        
        let content =
            VStack {
                List {
                    Text("Characters").font(.headline)
                    
                    Picker(selection: $model.language, label: Text("")) {
                        Text("Traditional").tag(SettingsCharType.traditional.rawValue)
                        Text("Simplified").tag(SettingsCharType.simplified.rawValue)
                    }
                    .labelsHidden()
                    .clipped()
                    
                    Text("Questions: \(Int(model.numQuestions))").font(.headline)
                    
                    Slider(value: $model.numQuestions, in: 1...20, step: 1)
                    
                    #if os(iOS)
                    Button(action: {
                        let app_id = 1511448888
                        let link = "itms-apps://itunes.apple.com/xy/app/foo/id\(app_id)?action=write-review"
                        
                        guard let url = URL(string: link) else { return }
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }) {
                        Text("Rate app...").font(.headline).padding(.vertical)
                    }
                    #endif
                }.listStyle(PlainListStyle())
            }
            .onReceive(model.settingsChanged, perform: { _ in
                self.trigger.toggle()
            })
            .onReceive(self.didSave) { _ in
                self.model.reload()
                self.trigger.toggle()
                    
            }.onAppear(perform: {
                self.model.reload()
                self.trigger.toggle()
                
            })
            .navigationTitle("Options")
        
        #if os(watchOS)
        return content
        #else
        return content
            .onAppear { UITableView.appearance().separatorStyle = .none }
            .onDisappear { UITableView.appearance().separatorStyle = .singleLine }
        #endif

    }
}

