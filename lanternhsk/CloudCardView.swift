//
//  CloudCardView.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 3/26/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//


import SwiftUI
import CoreData

struct CloudCardView: View {
    var list: CloudListEntity
    var section: CloudSectionEntity
    
    @State var cards: [VocabCard] = []
    @State private var sheetVisible = false

    private var didSave =  NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)
    
    init(_ list: CloudListEntity, _ section: CloudSectionEntity) {
        self.list = list
        self.section = section
        
        self._cards = State(initialValue: getCards())
    }
    
    func getCards() -> [VocabCard] {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        
        let request : NSFetchRequest<CloudCardEntity> =  CloudCardEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CloudCardEntity.objectID, ascending: true)]
        
        if let listId = list.id, let sectionId = section.id {
            request.predicate = NSPredicate(format: "list.id == %@ && section.id == %@", listId as CVarArg, sectionId as CVarArg)
            
            let cloudCards : [CloudCardEntity] = try! context.fetch(request)
            return cloudCards.map { VocabCard(entity: $0) }
            
        } else {
            return []
        }
    }
    
    var body: some View {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        var content: AnyView
        
        if cards.count == 0 {
            content = AnyView(
                VStack(alignment: .center) {
                    Text("No cards")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center))
            
        } else {
            content = AnyView(List {
                ForEach(cards.indices, id:\.self ){ index in
                    CardRow(card: self.cards[index]) }
                    .onDelete { offsets in
                        for index in offsets {
                            self.list.wordCount -= 1
                            self.section.wordCount -= 1
                            
                            context.delete(self.cards[index].entity as! CloudCardEntity)
                            self.cards.remove(at: index)
                        }
                        try! context.save()
                        
                }
            })
        }
                
        content = AnyView(
            VStack {
                #if os(iOS)
                NavigationLink(destination: AddCard(sheetVisible: self.$sheetVisible, list: self.list, section: self.section),
                               isActive: $sheetVisible,
                               label: { EmptyView() })
                #endif
                
                content

            }
            .onReceive(self.didSave) { _ in
                self.cards = self.getCards()
                
            }.onAppear(perform: {
                self.cards = self.getCards()
            })
            .toolbar {
                #if os(iOS)
                // FIXME: without this, back button will disappear
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {}, label: {})
                }
                #endif
                
                ToolbarItem {
                    #if os(iOS)
                    Button(action: {
                        withAnimation {
                            self.sheetVisible = true
                        }
                    },
                    label: {
                        Text("Add")
                    })
                    #endif
                }}
            .navigationTitle(section.name ?? "")
        )
        
        #if os(iOS)
        return content

        #else
        return GeometryReader { geometry in
            content
                .environment(\.defaultMinListRowHeight, geometry.size.height)
                .listStyle(CarouselListStyle()).focusable(true)
        }
        #endif
        
    }
}
