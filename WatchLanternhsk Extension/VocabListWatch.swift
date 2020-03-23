//
//  ContentView.swift
//  WatchLanternhsk Extension
//
//  Created by Alexey Smirnov on 12/15/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import SwiftUI
import CoreData

struct VocabListWatch: View {
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
                                           translation: $0.translation!)}
        
    }
    
    var body: some View {
        GeometryReader { geometry in
            List(self.cards) { VocabRow(card: $0, in: self.list.id!, height: geometry.size.height) }
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
 
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        VocabListWatch(ListEntity())
    }
}
