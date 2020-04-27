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
        self.query = query.trimmingCharacters(in: .whitespacesAndNewlines)
                
        let charType = SettingsCharType(rawValue: SettingsModel.shared.language)!
        let context = CoreDataStack.shared.persistentContainer.viewContext
        
        let request1: NSFetchRequest<CardEntity> = CardEntity.fetchRequest()
        let request2: NSFetchRequest<CloudCardEntity> = CloudCardEntity.fetchRequest()

        if self.query.range(of: "\\p{Han}", options: .regularExpression) != nil {
            request1.predicate = NSPredicate(format: charType == .simplified
                ? "wordSimp CONTAINS %@"
                : "wordTrad CONTAINS %@"
                , self.query as CVarArg)
            
            request2.predicate = NSPredicate(format: "word CONTAINS %@", self.query as CVarArg)
            
        } else {
            let pattern = ".*\\b\(NSRegularExpression.escapedPattern(for: self.query))\\b.*"
            request1.predicate = NSPredicate(format: "translation MATCHES[c] %@", pattern)
            request2.predicate = NSPredicate(format: "translation MATCHES[c] %@", pattern)
        }
        
        let cards1 = try! context.fetch(request1)
        let cards2 = try! context.fetch(request2)
        
        self._cards = State(initialValue:
            cards1.map({ VocabCard(entity: $0, charType: charType) })
            + cards2.map({ VocabCard(entity: $0) }))
    }
    
    func buildItem(_ index: Int) -> CardRow {
        return CardRow(card: self.$cards[index], showListName: true)
    }
    
    var body: some View {
        var content: AnyView
        
        if cards.count == 0 {
            content = AnyView(
                VStack(alignment: .center) {
                    Text("Not found")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center))
                
        } else {
            content = AnyView(List {
                ForEach(cards.indices, id:\.self ){ index in
                    self.buildItem(index)
                }
            })
           
        }
        
        #if os(watchOS)
        return GeometryReader { geometry in
            content
                .environment(\.defaultMinListRowHeight, geometry.size.height)
                .listStyle(CarouselListStyle()).focusable(true)
        }.navigationBarTitle("Search results")
        #else
        return content.navigationBarTitle("Search results")
        #endif
        
    }
}
