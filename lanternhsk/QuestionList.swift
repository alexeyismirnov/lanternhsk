//
//  QuestionList.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 2/18/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import SwiftUI

struct QuestionList: View {    
    @State var answerType = AnswerType.none
    @State var answerStr : String = ""

    @ObservedObject var model: QuestionModel
        
    init(model: QuestionModel) {
        self.model = model
    }
    
    var body: some View {
        if model.index == model.totalQuestions {
            return AnyView(Text("All questions answered")
                          .multilineTextAlignment(.center))
        }
        
        if answerType != .none {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.model.getNextQuestion(answer: self.answerType)
                self.answerType = .none
                self.answerStr = ""
            }
        }
        
        var content: some View {
            #if os(watchOS)
            return GeometryReader { geometry in
                List {
                    StudyRow(card: self.model.cards[self.model.index],
                             answerType: self.$answerType,
                             answerStr: self.$answerStr)
                    
                }.environment(\.defaultMinListRowHeight, geometry.size.height)
            }
            
            #else
            return StudyRow(card: self.model.cards[self.model.index],
                            answerType: $answerType,
                            answerStr: $answerStr)
            #endif
        }
        
        return AnyView(content)
    }

}

struct QuestionList_Previews: PreviewProvider {
    static var previews: some View {
        let cards: [VocabCard] = lists[0].load()
               let deck = StudyDeck(id: 0, name:"", cards: cards)
        return QuestionList(model: QuestionModel(deck: deck))
    }
}
