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
    
    @State var cloudCards: [CloudCardEntity] = []
    @State var cards: [VocabCard] = []

    @State private var sheetVisible = false

    private var didSave =  NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)
    
    init(_ list: CloudListEntity, _ section: CloudSectionEntity) {
        self.list = list
        self.section = section
        
        let (cloudCards, cards) = getCards()
        self._cloudCards = State(initialValue: cloudCards)
        self._cards = State(initialValue: cards)
    }
    
    func getCards() -> ([CloudCardEntity], [VocabCard]) {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let request : NSFetchRequest<CloudCardEntity> =  CloudCardEntity.fetchRequest()

        request.sortDescriptors = [NSSortDescriptor(keyPath: \CloudCardEntity.objectID, ascending: true)]
        if let listId = list.id, let sectionId = section.id {
            request.predicate = NSPredicate(format: "list.id == %@ && section.id == %@", listId as CVarArg, sectionId as CVarArg)
            
            let cloudCards : [CloudCardEntity] = try! context.fetch(request)
            let cards = cloudCards.map { VocabCard(entity: $0) }
            
            return (cloudCards, cards)
        } else {
            return ([], [])
        }

    }
    
    var body: some View {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        var content: AnyView
        
        if cards.count == 0 {
            content = AnyView(
                Text("No cards").multilineTextAlignment(.center)
            )
            
        } else {
            content = AnyView(List {
                ForEach(cards.indices, id:\.self ){ index in
                    CardRow(card: self.$cards[index]) }.onDelete { offsets in
                        for index in offsets {
                            self.list.wordCount -= 1
                            self.section.wordCount -= 1
                            context.delete(self.cloudCards[index])
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
                (self.cloudCards, self.cards) = self.getCards()
                
        }.onAppear(perform: {
            (self.cloudCards, self.cards) = self.getCards()
        }))
        
        #if os(iOS)
        return content
            .navigationBarTitle(section.name ?? "")
            .navigationBarItems(trailing:
                HStack {
                    Button(action: {
                        withAnimation {
                            self.sheetVisible = true
                        }
                    },
                           label: {
                            Text("Add")
                    })
                }
        )
        
        #else
        return GeometryReader { geometry in
            content
                .environment(\.defaultMinListRowHeight, geometry.size.height)
                .listStyle(CarouselListStyle()).focusable(true)
        }.navigationBarTitle(list.name!)
        #endif
        
    }
}
