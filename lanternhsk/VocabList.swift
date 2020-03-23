//
//  ContentView.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 12/15/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import SwiftUI
import CoreData

struct VocabList: View {
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
        List(cards) { VocabRow(card: $0, in: self.list.id!) }
            .navigationBarTitle(list.name!)
    }
}

struct VocabList_Previews: PreviewProvider {
    static var previews: some View {
        VocabList(ListEntity())
    }
}
