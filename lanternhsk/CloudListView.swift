//
//  CloudVocabList.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 3/25/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import SwiftUI
import CoreData

struct CloudListView: View {
    var request : NSFetchRequest<CloudListEntity> =  CloudListEntity.fetchRequest()
    @State var lists: [CloudListEntity] = []
    
    private var didSave =  NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)

    #if os(iOS)
    @State private var isShowingAlert = false
    @State private var alertInput = ""
    #endif
    
    @State private var trigger: Bool = false
    
    init() {
        let context = CoreDataStack.shared.persistentContainer.viewContext

        request.sortDescriptors = [NSSortDescriptor(keyPath: \CloudListEntity.objectID, ascending: true)]
        
        let lists = try! context.fetch(request)
        self._lists = State(initialValue: lists)
    }
    
    func buildItem(_ list:CloudListEntity) -> some View {
        let view = LazyView(CloudSectionView(list))
        
        return NavigationLink(destination: view) {
            VStack(alignment: .leading) {
                Text((list as CloudListEntity).name!).font(.headline)
                Text("Words: " + String((list as CloudListEntity).wordCount)).font(.subheadline)
            }.padding()
        }
    }
    
    func reload() {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        self.lists = try! context.fetch(self.request)
        self.trigger.toggle()
    }
    
    var body: some View {
        print("build \(trigger)")

        let context = CoreDataStack.shared.persistentContainer.viewContext
        var content: AnyView
        
        if lists.count == 0 {
            content = AnyView(Text("No lists")
                .multilineTextAlignment(.center))
        } else {
            content = AnyView(List {
                ForEach(lists, id: \.id)  { list in
                    self.buildItem(list)
                    
                }.onDelete { offsets in
                    for index in offsets {
                        context.delete(self.lists[index])
                        self.lists.remove(at: index)
                    }
                    try! context.save()
                }
                
            }.onReceive(self.didSave) { _ in
                self.reload()
                
            }.onAppear(perform: {
                self.reload()
            }))
        }
        
        #if os(iOS)
        return content
            .navigationBarTitle("Flashcards", displayMode: .inline)
            .navigationBarItems(trailing:
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
        ).textFieldAlert(isShowing: $isShowingAlert,
                         text: $alertInput,
                         title: "Add List") {
                            let list1 = CloudListEntity(context: context)
                            list1.id = UUID()
                            list1.name = self.alertInput
                            list1.wordCount = 0
                            
                            try! context.save()
                            
                            self.reload()
                            
        }
        
        #else
        return content
        #endif
    }

   
}


