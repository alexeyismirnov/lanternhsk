//
//  StudyRow.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 12/31/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import SwiftUI

struct StudyVocab: View {
    let card: VocabCard
    @Binding var answerType: AnswerType
    @Binding var answerStr: String
    @Binding var review: Bool

    @State var show: Bool = false

    init(card: VocabCard, answerType: Binding<AnswerType>, answerStr: Binding<String>, review: Binding<Bool>) {
        self.card = card
        self._answerType = answerType
        self._answerStr = answerStr
        self._review = review
    }
    
    var body: some View {
        VStack {
            if self.answerType == .none {
                VStack {
                    Spacer()

                    VStack {
                        Text(card.word).font(.title)
                        TextField("Translate", text: $answerStr, onCommit: validate)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "arrow.right.circle")
                        Text("Skip").font(.headline)
                    }
                    .padding()
                    .frame(width: 150, alignment: .center)
                    .onTapGesture {
                        self.answerType = .ignored
                    }
                    
                }
                .transition(AnyTransition.opacity
                .animation(.easeInOut(duration: 0.5)))
                
                
            } else if self.answerType == .correct {
                VStack {
                    Spacer()

                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.green)
                        .frame(height: 50)
                    Text("Correct")
                        .font(.title)
                        .foregroundColor(.green)
                    
                    Spacer()

                    HStack {
                        Image(systemName: "info.circle")
                        Text("Review").font(.headline)
                    }
                    .padding()
                    .frame(width: 150, alignment: .center)
                    .onTapGesture {
                        self.review = true
                    }
                }
                    
                .transition(AnyTransition.opacity
                .animation(.easeInOut(duration: 0.5)))
                
            } else if self.answerType == .incorrect  {
                VStack {
                    Spacer()

                    Image(systemName: "multiply.circle")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.red)
                        .frame(height: 50)
                    Text("Incorrect")
                        .font(.title)
                        .foregroundColor(.red)
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "info.circle")
                        Text("Review").font(.headline)
                    }
                    .padding()
                    .frame(width: 150, alignment: .center)
                    .onTapGesture {
                        self.review = true
                    }

                }
                .transition(AnyTransition.opacity
                .animation(.easeInOut(duration: 0.5)))
            } else {
                Rectangle().fill(Color.clear)
            }
            
        }
    }
    
    func validate() {
        if card.translation.lowercased().contains(answerStr.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()) {
            answerType = .correct
        } else {
            answerType = .incorrect
        }
    }
}

struct StudyRow_Previews: PreviewProvider {
    static var previews: some View {
        Rectangle()
            .fill(Color.yellow)
            .frame(width: 50, height: 50)
    }
}
