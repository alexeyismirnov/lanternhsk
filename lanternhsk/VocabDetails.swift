//
//  VocabDetails.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 2/20/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import SwiftUI

struct VocabDetails: View {
    let card: VocabCard
    
    var body: some View {
        List {
            Section(header: Text("Writing")) {
                Text(card.word)
            }
            Section(header: Text("Pinyin")) {
                Text(card.pinyin)
            }
            Section(header: Text("Translation")) {
                Text(card.translation)
            }
            
        }
    }
}

struct VocabDetails_Previews: PreviewProvider {
    static let cards: [VocabCard] = lists[0].load()

    static var previews: some View {
        VocabDetails(card: cards[0])
    }
}
