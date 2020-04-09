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
    @State private var language = 1
    @State private var numQuestions: Double = 5
    
    var body: some View {
       let content =
            VStack {
            List {
                Text("Characters").font(.headline)
                
                Picker(selection: $language, label: Text("")) {
                    Text("Traditional").tag(1)
                    Text("Simplified").tag(2)
                }
                .labelsHidden()
                .clipped()
                .frame(height: 100)
                
                Text("Questions: \(Int(numQuestions))").font(.headline)
                
                Slider(value: $numQuestions, in: 1...20, step: 1, onEditingChanged: {
                    print("\($0)")
                })
            }
                
               
        }
        
        #if os(watchOS)
        return content.navigationBarTitle("Options")
        #else
        return content
            .navigationBarTitle("Options", displayMode: .inline)
            .onAppear { UITableView.appearance().separatorStyle = .none }
            .onDisappear { UITableView.appearance().separatorStyle = .singleLine }
        #endif

    }
}

