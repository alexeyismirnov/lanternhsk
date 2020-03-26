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
        request.predicate = NSPredicate(format: "list.id == %@ && section.id == %@", list.id! as CVarArg, section.id! as CVarArg)
        
        let cloudCards : [CloudCardEntity] = try! context.fetch(request)
        
        let cards = cloudCards.map { card in VocabCard(id: card.id!,
                                                    word: card.word!,
                                                    pinyin: card.pinyin!,
                                                    translation: card.translation!) }
        
        return (cloudCards, cards)
    }
    
    var body: some View {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        
        let content = List {
            ForEach(cards, id: \.id) {
                CardRow(card: $0, in: self.list.id!)
                
            }.onDelete { offsets in
                for index in offsets {
                    self.list.wordCount -= 1
                    self.section.wordCount -= 1
                    context.delete(self.cloudCards[index])
                }
                try! context.save()
            }
            
        }.onReceive(self.didSave) { _ in
            (self.cloudCards, self.cards) = self.getCards()
        }
        
        #if os(iOS)
        return content
            .navigationBarTitle(section.name ?? "")
            .navigationBarItems(trailing:
            HStack {
                Button(action: {
                    withAnimation {
                        self.sheetVisible.toggle()
                    }
                },
                       label: {
                        Text("Add")
                })
            }
        ).sheet(isPresented: $sheetVisible) {
            AddCard(sheetVisible: self.$sheetVisible, list: self.list, section: self.section)
        }
        
        #else
        return GeometryReader { geometry in
            content
                .environment(\.defaultMinListRowHeight, geometry.size.height)
                .listStyle(CarouselListStyle()).focusable(true)
        }.contextMenu(menuItems: {
            Button(action: {
                print("Refresh")
            }, label: {
                VStack{
                    Image(systemName: "arrow.clockwise").font(.title)
                    Text("Refresh view")
                }
            })
        }).navigationBarTitle(list.name!)
        #endif
        
    }
}
