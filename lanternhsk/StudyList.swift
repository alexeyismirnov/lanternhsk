//
//  StudyList.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 12/31/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import SwiftUI

struct StudyList: View {
    var deck: StudyDeck
    
    var body: some View {
        GeometryReader { geometry in
                        
            List {
                StudyRow(card: self.deck.cards[0])
            }
             
        }
    }
}

struct StudyList_Previews: PreviewProvider {
    static var previews: some View {
        let cards: [VocabCard] = lists[0].load()
        let deck = StudyDeck(id: 0, name:"", cards: cards)
        
        return StudyList(deck: deck)
    }
}
