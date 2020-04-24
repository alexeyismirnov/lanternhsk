//
//  SearchView.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 4/24/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import SwiftUI
import CoreData

struct SearchView: View {
    let query: String
    @State var cards: [VocabCard] = []

    init(query: String) {
        self.query = query
        
        let context = CoreDataStack.shared.persistentContainer.viewContext

        let pattern = ".*\\b\(NSRegularExpression.escapedPattern(for: query))\\b.*"
        
        let request: NSFetchRequest<CardEntity> = CardEntity.fetchRequest()
        request.predicate = NSPredicate(format: "translation MATCHES[c] %@", pattern)
        
        let cards = try! context.fetch(request)
        
        let charType = SettingsCharType(rawValue: SettingsModel.shared.language)!
        self._cards = State(initialValue: cards.map { VocabCard(entity: $0, charType: charType) })
    }
    
    func buildItem(_ index: Int) -> CardRow {
        return CardRow(card: self.$cards[index], showListName: true)
    }
    
    var body: some View {
        let content = List {
            ForEach(cards.indices, id:\.self ){ index in
                self.buildItem(index)
            }
        }
        
        return content.navigationBarTitle("Search results")
    }
}
