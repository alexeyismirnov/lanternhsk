//
//  ListsTab.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 12/18/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import SwiftUI
import CoreData

struct ListView: View {
    @State var lists: [ListEntity] = []

    @State private var isShowingAlert = false
    @State private var searchInput = ""
    
    @State private var searchPresented = false
    
    init() {
        let request : NSFetchRequest<ListEntity> = ListEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ListEntity.objectID, ascending: true)]
        
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let lists = try! context.fetch(request)
        
        self._lists = State(initialValue: lists)
    }
    
    func buildItem(_ list:ListEntity) -> some View {
        let view = LazyView(CardView(list))

        return NavigationLink(destination: view) {
            VStack(alignment: .leading) {
                Text((list as ListEntity).name!).font(.headline)
                Text("Words: " + String((list as ListEntity).wordCount)).font(.subheadline)
            }.padding()
        }
    }
    
    var body: some View {
        let list = List {
            ForEach(lists, id: \.id) { list in
                self.buildItem(list)
            }
            NavigationLink(destination: LazyView(CloudListView())) {
                VStack(alignment: .leading) {
                    Text("Custom...").font(.headline)
                }
                .padding()
                .frame(height: 50)
            }
            
            NavigationLink(destination: LazyView(SearchView(query: self.searchInput)),
                           isActive: $searchPresented,
                           label: { EmptyView() }
            )
        }

        #if os(watchOS)
        return list
            .navigationBarTitle("Lists")
            .focusable(true)
        #else
        return list
            .textFieldAlert(isShowing: $isShowingAlert,
                            text: $searchInput,
                            title: "Search") {
                                self.searchPresented = true
                                
        }
        .navigationBarTitle("Lists", displayMode: .inline)
        .navigationBarItems(trailing:
            Button(action: {
                self.searchInput = ""
                withAnimation {
                    self.isShowingAlert.toggle()
                }
            }) {
                Image(systemName: "magnifyingglass").imageScale(.large)
            }
                
        )
        #endif
    }
}

struct VocabTab_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
