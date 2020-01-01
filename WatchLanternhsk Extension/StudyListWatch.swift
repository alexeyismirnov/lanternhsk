//
//  StudyListView.swift
//  WatchLanternhsk Extension
//
//  Created by Alexey Smirnov on 1/1/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import SwiftUI

struct StudyListWatch: View {
    var deck: StudyDeck
    
    var body: some View {
        
        GeometryReader { geometry in
            List {
                StudyRow(card: self.deck.cards[0])
            }.environment(\.defaultMinListRowHeight, geometry.size.height)
            
        }
    }
}

struct StudyListWatch_Previews: PreviewProvider {
    static var previews: some View {
        let cards: [VocabCard] = lists[0].load()
        let deck = StudyDeck(id: 0, name:"", cards: cards)
        
        return StudyListWatch(deck: deck)
    }
}
