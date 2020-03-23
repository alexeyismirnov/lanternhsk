//
//  ListsTab.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 12/18/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import SwiftUI
import CoreData

struct VocabTab<DeckView: View>: View {
    let producer: (ListEntity) -> DeckView
    @State var lists: [ListEntity] = []

    init(_ producer: @escaping (ListEntity) -> DeckView) {
        self.producer = producer
        let request : NSFetchRequest<ListEntity> = ListEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ListEntity.objectID, ascending: true)]
        
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let lists = try! context.fetch(request)
        
        self._lists = State(initialValue: lists)
    }
    
    func buildItem(_ list:ListEntity) -> some View {
        let view = producer(list)

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
        }.navigationBarTitle("Lists")
        
        #if os(watchOS)
        return list.focusable(true)
        #else
        return list
        #endif
    }
}

#if os(watchOS)
typealias DeckView = VocabListWatch
#else
typealias DeckView = VocabList
#endif

struct VocabTab_Previews: PreviewProvider {
    static var previews: some View {
        VocabTab() { DeckView($0) }
    }
}
