//
//  ListsTab.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 12/18/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import SwiftUI

struct ListsTab<DeckView: View>: View {
    
    let producer: (VocabDeck) -> DeckView
    
    var body: some View {
        List(lists) { item in
            NavigationLink(destination: self.producer(item)) {
                VStack(alignment: .leading) {
                    Text(item.name).font(.headline)
                    Text("Words: \(item.wordCount)").font(.subheadline)
                }.padding()
            }
            
        }.navigationBarTitle("Lists")
    }
}

#if os(watchOS)
typealias DeckView = VocabListWatch
#else
typealias DeckView = VocabList
#endif

struct ListsTab_Previews: PreviewProvider {
    static var previews: some View {
        ListsTab() { DeckView(deck: $0) }
    }
}
