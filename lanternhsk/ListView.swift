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
    @EnvironmentObject var studyManager: StudyManager
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
        print("build \(searchInput)")
        
        let list =
            VStack {
                NavigationLink(destination: LazyView(SearchView(query: searchInput)),
                               isActive: $searchPresented,
                               label: { EmptyView() }
                ).frame(width: 0, height: 0)
                
                List {
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
                }.listStyle(PlainListStyle())
        }
            
        #if os(watchOS)
        return list
            .navigationBarTitle("Lists")
            .focusable(true)
            .contextMenu(menuItems: {
                Button(action: {
                    self.studyManager.searchStarted.send()

                }, label: {
                    VStack{
                        Image(systemName: "magnifyingglass").font(.title)
                        Text("Search")
                    }
                })
            })
        #else
        return list
            .alert(isPresented: $isShowingAlert, TextAlert(title: "Search", action: {
                if let input = $0  {
                    searchInput = input
                    self.searchPresented = true
                    
                }
            }))
            /*
            .textFieldAlert(isShowing: $isShowingAlert,
                            text: $searchInput,
                            title: "Search") {
                print("input \(searchInput)")
                                self.searchPresented = true
                                
        }
 */
        .navigationBarTitle("Lists", displayMode: .inline)
        .navigationBarItems(trailing:
            Button(action: {
                self.searchInput = ""
                withAnimation {
                    self.isShowingAlert.toggle()
                }
            }, label: {
                Text("Search")
            })
                
        )
        #endif
    }
}

struct VocabTab_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
