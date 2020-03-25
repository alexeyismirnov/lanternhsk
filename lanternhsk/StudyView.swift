//
//  StudyTab.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 12/19/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import SwiftUI

enum ActionViewMode {
    case first
    case second
}

extension ActionViewMode {
    func getView(deck: StudyDeck) -> some View {
        switch self {
            case .first: return  QuestionList(model: QuestionModel(deck: deck))
            case .second: return QuestionList(model: QuestionModel(deck: deck))
        }
    }
}

struct StudyView: View {
    @EnvironmentObject var studyManager: StudyManager
    @State var studyLists = [StudyDeck]()
    
    @State var showActionSheet = [UUID: Bool]()
    
    @State var actionViewMode = ActionViewMode.first
    @State var showActionView = [UUID: Bool]()

    func getActionSheet(deck: StudyDeck) -> ActionSheet {

        return ActionSheet(title: Text("Study type"),  buttons: [
            .default(
            Text("Translation")) {
                self.actionViewMode = .first
                self.showActionView[deck.id] = true
            },
            .default(Text("Pinyin")) {
                self.actionViewMode = .second
                self.showActionView[deck.id] = true
            },
            .default(Text("Tone")) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.studyManager.deck = deck
                    self.studyManager.addQuestion()
                }
                
            },
        ])
    }
    
    func getContent() -> AnyView {
        if studyLists.count == 0 {
            return AnyView(Text("You did not select any words for study")
                .multilineTextAlignment(.center))
        }
        
        let list = List(studyLists) { item in
            VStack(alignment: .leading) {
                Text(item.name).font(.headline)
                Text("Words: \(item.cards.count)").font(.subheadline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .contentShape(Rectangle())
            .onTapGesture {
                self.showActionSheet[item.id] = true
            }
            .actionSheet(isPresented: Binding(
                get: { return self.showActionSheet[item.id]! },
                set: { (newValue) in return self.showActionSheet[item.id] = newValue}
                ),
                         content: { self.getActionSheet(deck: item) })
            .sheet(isPresented: Binding(
                get: { return self.showActionView[item.id]! },
                set: { (newValue) in return self.showActionView[item.id] = newValue}
            )) { self.actionViewMode.getView(deck: item) }
            
        }
        
        #if os(watchOS)
        return AnyView(list.focusable(true))
        #else
        return AnyView(list)
        #endif
    }
    
    func reload() {
        studyLists = [StudyDeck]()
        
        /*
        for list in lists {
            if let deck = StudyDeck(deck: list, studyManager: studyManager) {
                studyLists.append(deck)
            }
        }
        */
        
        for deck in studyLists {
            showActionSheet[deck.id] = false
            showActionView[deck.id] = false
        }
    }
    
    var body: some View {
        getContent().navigationBarTitle("Study")
            .onAppear(perform: {
                self.reload()
            })
            .onReceive(studyManager.cardsChanged, perform: { _ in
                self.reload()
            })
        
    }
}

struct StudyTab_Previews: PreviewProvider {
    static var previews: some View {
        StudyView()
    }
}
