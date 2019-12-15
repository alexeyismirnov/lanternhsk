//
//  ContentView.swift
//  WatchLanternhsk Extension
//
//  Created by Alexey Smirnov on 12/15/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader { geometry in
            List(vocabData) { VocabRow(card: $0)
            }.environment(\.defaultMinListRowHeight, geometry.size.height)
                .listStyle(CarouselListStyle()).focusable(true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        VocabList()
    }
}
