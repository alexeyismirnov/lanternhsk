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
    @State var answerType : StudyRow.AnswerType = .none
    @State var answerStr : String = ""
    @State private var opacity = 0.0

    @State var index: Int
    
    init(deck: StudyDeck) {
        self.deck =  deck
        _index = State(initialValue: Int.random(in: 0..<deck.cards.count))
    }
    
    var body: some View {
        if answerType != .none {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.answerType = .none
                self.answerStr = ""
                self.index = Int.random(in: 0..<self.deck.cards.count)
            }
        }
       
        return Group {
            StudyRow(card: self.deck.cards[index], answerType: $answerType, answerStr: $answerStr).opacity(opacity)
            
        } .onAppear  {
            withAnimation(.linear(duration: 1)) {
                self.opacity = 1.0
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
