//
//  VocabRow.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 12/15/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import SwiftUI

struct ImageButton: View {
    let iconName: String
    let handler: () -> Void
    
    var body: some View {
        VStack() {
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .foregroundColor(.yellow)
                .padding(10.0)
                
        }.onTapGesture {
            self.handler()
        }
        .frame(width: 40, height: 40)
    }
}

struct VocabRow: View {
    let card: VocabCard
    
    @State var starred: Bool = false
    
    var body: some View {
        ZStack() {
            HStack(spacing: 0) {
                Spacer()
                ImageButton(iconName: starred ? "star.fill": "star", handler: {
                    self.starred = !self.starred
                    print("action2") })
                ImageButton(iconName: "ellipsis", handler: { print("action1") })
                
            }.frame(maxHeight: .infinity, alignment: .top)
            
            VStack(alignment: .leading) {
                Text(card.word).font(.title)
                Text(card.pinyin).font(.subheadline)
            }.frame(maxWidth: .infinity, alignment: .leading)
            
        }
    }
}

struct VocabRow_Previews: PreviewProvider {
    static var previews: some View {
        let cards: [VocabCard] = lists[0].load()
        return Group {
            VocabRow(card: cards[0])
            VocabRow(card: cards[5])

        }
        .previewLayout(.fixed(width: 300, height: 70))

    }
}
