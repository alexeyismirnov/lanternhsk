//
//  ContentView.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 12/15/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import SwiftUI
import CoreData

struct CardView: View {
    let list: ListEntity
    @State var cards: [VocabCard] = []
        
    private var didSave =  NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)

    init(_ list: ListEntity) {
        self.list = list
        let cards = getCards()
        self._cards = State(initialValue: cards)
    }
    
    func getCards() -> [VocabCard] {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let request: NSFetchRequest<CardEntity> = CardEntity.fetchRequest()
        let charType = SettingsCharType(rawValue: SettingsModel.shared.language)!

        request.predicate = NSPredicate(format: "list.id == %@", list.id! as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CardEntity.objectID, ascending: true)]
        
        let cards = try! context.fetch(request)
        
        return cards.map { VocabCard(entity: $0, charType: charType) }
    }
    
    func buildItem(_ index: Int) -> CardRow {
        return CardRow(card: self.$cards[index])
    }
    
    var body: some View {
        let content = List {
            ForEach(cards.indices, id:\.self ){ index in
                self.buildItem(index)
            }
        }
        .onReceive(self.didSave) { _ in
            self.cards = self.getCards()
        }
        
        #if os(watchOS)
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
        #else
        return content.navigationBarTitle(list.name!)
        #endif
        
    }
}

struct VocabList_Previews: PreviewProvider {
    static var previews: some View {
        CardView(ListEntity())
    }
}
