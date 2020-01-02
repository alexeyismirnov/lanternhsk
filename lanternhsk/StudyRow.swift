//
//  StudyRow.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 12/31/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import SwiftUI

struct StudyRow: View {
    let card: VocabCard
    @Binding var answerType: AnswerType
    @Binding var answerStr: String

    init(card: VocabCard, answerType: Binding<AnswerType>, answerStr: Binding<String>) {
        self.card = card
        self._answerType = answerType
        self._answerStr = answerStr
    }

    var body: some View {
        Group {
            if self.answerType == .none {
                VStack {
                    Text(card.word).font(.title)
                    TextField("Translate", text: $answerStr, onCommit: validate)
                    .multilineTextAlignment(.center)

                }
                
            } else if self.answerType == .correct {
                VStack {
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.green)
                        .frame(height: 50)
                    Text("Correct")
                        .font(.title)
                        .foregroundColor(.green)

                }
                
            } else {
                VStack {
                    Image(systemName: "multiply.circle")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.red)
                        .frame(height: 50)
                    
                    Text("Incorrect")
                        .font(.title)
                        .foregroundColor(.red)

                }
            }
            
        }
    }
    
    func validate() {
        if card.translation.lowercased().contains(answerStr.lowercased()) {
            answerType = .correct
        } else {
            answerType = .incorrect
        }
    }
   
}

extension StudyRow {
    public enum AnswerType {
           case none, correct, incorrect
       }
}

struct StudyRow_Previews: PreviewProvider {
    @State static var answerType : StudyRow.AnswerType = .none
    @State static var answerStr : String = ""

    static let cards: [VocabCard] = lists[0].load()

    static var previews: some View {
        StudyRow(card: cards[0], answerType: $answerType, answerStr: $answerStr)
    }
}
