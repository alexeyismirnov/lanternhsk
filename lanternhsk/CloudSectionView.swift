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
    @State private var alertInput = ""
    #endif

    @State private var trigger: Bool = false

    init(_ list: CloudListEntity) {
        self.list = list
        self._sections = State(initialValue: getSections())
    }
    
    func buildItem(_ section:CloudSectionEntity) -> some View {
        let view = LazyView(CloudCardView(self.list, section))
        
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
                
            })
                .navigationBarTitle(list.name ?? ""))
        }
        
        
        #if os(iOS)
        return content.navigationBarItems(trailing:
            HStack {
                Button(action: {
                    self.alertInput = ""
                    withAnimation {
                        self.isShowingAlert.toggle()
                    }
                },
                       label: {
                        Text("Add")
                })
                
            }
        )
            .textFieldAlert(isShowing: $isShowingAlert,
                            text: $alertInput,
                            title: "Add Section") {
                                DispatchQueue.main.async {
                                    let section = CloudSectionEntity(context: context)
                                    section.id = UUID()
                                    section.list = self.list
                                    section.name = self.alertInput
                                    section.wordCount = 0
                                    
                                    try! context.save()
                                    self.sections = self.getSections()
                                    self.trigger.toggle()
                                }
                                
        }
        
        #else
        return content
        #endif
        
    }
}

