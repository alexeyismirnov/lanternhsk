//
//  ContentView.swift
//  WatchLanternhsk Extension
//
//  Created by Alexey Smirnov on 12/15/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import SwiftUI

struct VocabListWatch: View {
    let deck: VocabDeck
    let cards: [VocabCard]
    
    init(deck: VocabDeck) {
        self.deck = deck
        self.cards = deck.load()
    }
    
    var body: some View {
        GeometryReader { geometry in
            List(self.cards) { VocabRow(card: $0)
            }.environment(\.defaultMinListRowHeight, geometry.size.height)
                .listStyle(CarouselListStyle()).focusable(true)
        }.contextMenu(menuItems: {
            Button(action: {
                print("Refresh")
            }, label: {
                VStack{
                    Image(systemName: "arrow.clockwise")
                        .font(.title)
                    Text("Refresh view")
                }
            })
        }).navigationBarTitle(deck.name)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        VocabListWatch(deck: lists[0])
    }
}
