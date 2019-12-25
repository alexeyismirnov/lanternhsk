//
//  StudyTab.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 12/19/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import SwiftUI

struct StudyTab: View {
    @EnvironmentObject var studyManager: StudyManager
    @State var studyLists = [StudyDeck]()
    
    func getContent() -> AnyView {
        if studyLists.count == 0 {
            return AnyView(Text("You did not select any words for study")
                .multilineTextAlignment(.center))
        }
        
        let list = List(studyLists) { item in
            VStack(alignment: .leading) {
                Text(item.name).font(.headline)
                Text("Words: \(item.cards.count)").font(.subheadline)
            }.padding()
        }
        
        #if os(watchOS)
        return AnyView(list.focusable(true))
        #else
        return AnyView(list)
        #endif
    }
    
    func reload() {
        studyLists = [StudyDeck]()
        
        for list in lists {
            if let deck = StudyDeck(deck: list, studyManager: studyManager) {
                studyLists.append(deck)
            }
        }
    }
    
    var body: some View {
        getContent()
            .navigationBarTitle("Study")
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
        StudyTab()
    }
}
