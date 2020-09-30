//
//  VocabDetails.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 2/20/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import SwiftUI
import CoreData

struct CardDetails: View {
    let card: VocabCard
    let dictionary: [DictionaryEntity]
    
    init(_ card: VocabCard) {
        self.card = card
        
        let context = CoreDataStack.shared.persistentContainer.viewContext
        
        var dictionary = [DictionaryEntity]()
        var uniqueChars = Set<Character>()
        
        for char in card.word {
            if uniqueChars.contains(char) {
                continue
            } else {
                uniqueChars.insert(char)
            }
            
            let request: NSFetchRequest<DictionaryEntity> = DictionaryEntity.fetchRequest()
            request.predicate = NSPredicate(format: "character == %@", String(char) as CVarArg)
            
            let dict = try! context.fetch(request)
            if let dict = dict.first {
                dictionary.append(dict)
            }
        }
        
        self.dictionary = dictionary
    }
    
    var body: some View {
        let dictView = dictionary.count > 0
            ?
                AnyView(Section(header: Text("Characters")) {
                    ForEach(self.dictionary, id: \.character) { entry in
                        VStack(alignment: .leading) {
                        Text(entry.character ?? "").font(.title)
                        Text(entry.definition ?? "")
                        }}
                })
            : AnyView(EmptyView())
        
        return List {
            Section(header: Text("Writing")) {
                Text(card.word).font(.title)
            }
            Section(header: Text("Pinyin")) {
                Text(card.pinyin)
            }
            Section(header: Text("Translation")) {
                Text(card.translation)
            }
            
            dictView
        }
        .listStyle(PlainListStyle())
        .environment(\.defaultMinListRowHeight, 10)
    }
}

struct VocabDetails_Previews: PreviewProvider {
    static var previews: some View {
        Rectangle()
            .fill(Color.yellow)
            .frame(width: 50, height: 50)
    }
}
