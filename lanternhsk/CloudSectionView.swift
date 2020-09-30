//
//  CloudSectionView.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 3/25/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import SwiftUI
import CoreData

struct CloudSectionView: View {
    var list: CloudListEntity

    var request : NSFetchRequest<CloudSectionEntity> =  CloudSectionEntity.fetchRequest()
    @State var sections: [CloudSectionEntity] = []
    
    private var didSave =  NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)
    
    #if os(iOS)
    @State private var isShowingAlert = false
    #endif

    @State private var trigger: Bool = false

    @EnvironmentObject var studyManager: StudyManager

    init(_ list: CloudListEntity) {
        self.list = list
        self._sections = State(initialValue: getSections())
    }
    
    func buildItem(_ section:CloudSectionEntity) -> some View {
        let view = LazyView(CloudCardView(self.list, section).environmentObject(studyManager))
        
        return NavigationLink(destination: view) {
            VStack(alignment: .leading) {
                Text((section as CloudSectionEntity).name!).font(.headline)
                Text("Words: " + String((section as CloudSectionEntity).wordCount)).font(.subheadline)
            }.padding()
        }
    }
    
    func getSections() -> [CloudSectionEntity] {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CloudSectionEntity.objectID, ascending: true)]
        
        if let listId = list.id {
            request.predicate = NSPredicate(format: "list.id == %@", listId as CVarArg)
            return try! context.fetch(self.request)
        } else {
            return []
        }
        
    }
    
    var body: some View {
        print("build \(trigger)")

        let context = CoreDataStack.shared.persistentContainer.viewContext
        var content: AnyView
               
        if sections.count == 0 {
            content = AnyView(Text("No sections")
                .multilineTextAlignment(.center))
            
        } else {
            content = AnyView(List {
                ForEach(sections, id: \.id) { section in
                    self.buildItem(section)
                    
                }.onDelete { offsets in
                    for index in offsets {
                        self.list.wordCount -= self.sections[index].wordCount
                        context.delete(self.sections[index])
                        self.sections.remove(at: index)
                    }
                    try! context.save()
                }
                
            }.onReceive(self.didSave) { _ in
                self.sections = self.getSections()
                self.trigger.toggle()
                
            }.onAppear(perform: {
                self.sections = self.getSections()
                self.trigger.toggle()
                
            }))
        }
        
        return content.toolbar {
            #if os(iOS)
            // FIXME: without this, back button will disappear
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {}, label: {})
            }
            ToolbarItem {
                Button(action: {
                    self.alert(TextAlert(title: "Enter Name", action: {
                        if let input = $0  {
                            DispatchQueue.main.async {
                                let section = CloudSectionEntity(context: context)
                                section.id = UUID()
                                section.list = self.list
                                section.name = input
                                section.wordCount = 0
                                
                                try! context.save()
                                self.sections = self.getSections()
                                self.trigger.toggle()
                            }
                        }
                    }))
                    
                },
                label: {
                    Text("Add")
                })
            }
            #endif
        }
        .navigationTitle(list.name ?? "")
    }
}

