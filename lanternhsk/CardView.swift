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
    let cards: [VocabCard]
    
    init(_ list: ListEntity) {
        self.list = list
        
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let request: NSFetchRequest<CardEntity> = CardEntity.fetchRequest()
        request.predicate = NSPredicate(format: "list.id == %@", list.id! as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CardEntity.objectID, ascending: true)]

        let cards = try! context.fetch(request)
                
        self.cards = cards.map { VocabCard(id: $0.id!,
                                           word: $0.wordTrad!,
                                           pinyin: $0.pinyin!,
                                           translation: $0.translation!,
                                           starred: $0.starred
            )}
        
    }
    
    var body: some View {
        let content = List(cards) { CardRow(card: $0, in: self.list.id!) }
        
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
