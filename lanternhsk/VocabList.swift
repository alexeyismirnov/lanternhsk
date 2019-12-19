//
//  ContentView.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 12/15/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import SwiftUI

struct VocabList: View {
    let deck: VocabDeck
    let cards: [VocabCard]
    
    init(deck: VocabDeck) {
        self.deck = deck
        self.cards = deck.load()
    }
    
    var body: some View {
        List(cards, rowContent: VocabRow.init).navigationBarTitle(deck.name)
    }
}

struct VocabList_Previews: PreviewProvider {
    static var previews: some View {
        VocabList(deck: lists[0])
    }
}
