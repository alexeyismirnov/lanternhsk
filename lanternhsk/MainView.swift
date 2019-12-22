//
//  MainView.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 12/19/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import SwiftUI

struct TabLabel: View {
    let imageName: String
    let label: String
    
    var body: some View {
        VStack {
            Image(systemName: imageName)
            Text(label)
        }
    }
}

struct MainView: View {
    var body: some View {
        TabView {
            NavigationView { ListsTab(producer: { VocabList(deck: $0) }) }
             .tabItem({ TabLabel(imageName: "list.bullet", label: "Lists") })
            
            NavigationView { StudyTab() }
             .tabItem({ TabLabel(imageName: "book.fill", label: "Study") })
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}