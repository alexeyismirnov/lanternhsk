//
//  VocabDetails.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 2/20/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import SwiftUI

struct CardDetails: View {
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
    static var previews: some View {
        Rectangle()
            .fill(Color.yellow)
            .frame(width: 50, height: 50)
    }
}
