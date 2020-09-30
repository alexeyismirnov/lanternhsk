//
//  StudyTab.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 12/19/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import SwiftUI
import CoreData

enum StudyType {
    case translation
    case pinyin
    case tone
}

extension StudyType {
    func getView(deck: StudyDeck) -> some View {
        switch self {
        case .translation:
            return AnyView(StudyVocab(StudyVocabModel(.translation, deck: deck)))
        case .pinyin:
            return AnyView(StudyVocab(StudyVocabModel(.pinyin, deck: deck)))
        #if os(iOS)
        case .tone:
            return AnyView(StudyTone(StudyToneModel(deck: deck)))
        #else
        default:
            return AnyView(EmptyView())
        #endif
        }
    }
}

struct StudyView: View {
    @EnvironmentObject var studyManager: StudyManager
    @State var studyLists = [StudyDeck]()
    
    @State var actionViewMode = StudyType.translation
    @State var showActionView = [UUID: Bool]()
    @State var showActionSheet = [UUID: Bool]()
    
    init() {
        let (lists, actionViews, actionSheets) = getLists()
        self._studyLists = State(initialValue: lists)
        self._showActionView = State(initialValue: actionViews)
        self._showActionSheet = State(initialValue: actionSheets)
    }
    
    func getLists() -> ([StudyDeck], [UUID: Bool], [UUID: Bool]) {
        var studyLists = [StudyDeck]()
        let context = CoreDataStack.shared.persistentContainer.viewContext

        let request : NSFetchRequest<ListEntity> = ListEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ListEntity.objectID, ascending: true)]
        
        let lists = try! context.fetch(request)
        
        for list in lists {
            if let deck = StudyDeck(entity: list) {
                studyLists.append(deck)
            }
        }
        
        let request2 : NSFetchRequest<CloudSectionEntity> =  CloudSectionEntity.fetchRequest()
        request2.sortDescriptors = [NSSortDescriptor(keyPath: \CloudSectionEntity.objectID, ascending: true)]
               
        let sections = try! context.fetch(request2)
        
        for section in sections {
            if let deck = StudyDeck(entity: section) {
                studyLists.append(deck)
            }
        }
        
        var showActionSheet = [UUID: Bool]()
        var showActionView = [UUID: Bool]()
        
        for deck in studyLists {
            showActionSheet[deck.id] = false
            showActionView[deck.id] = false
        }
       
        return (studyLists, showActionView, showActionSheet)
    }
    
    func getActionSheet(deck: StudyDeck) -> ActionSheet {
        let translation =  ActionSheet.Button.default(Text("Translation")) {
            self.actionViewMode = .translation
            self.showActionView[deck.id] = true
        }
        
        let pinyin = ActionSheet.Button.default(Text("Pinyin")) {
            self.actionViewMode = .pinyin
            self.showActionView[deck.id] = true
        }
        
        let tone = ActionSheet.Button.default(Text("Tone")) {
            #if os(iOS)
            self.actionViewMode = .tone
            self.showActionView[deck.id] = true
            #else
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.studyManager.deck = deck
                self.studyManager.addQuestion()
            }
            #endif
        }
        
        let remove = ActionSheet.Button.destructive(Text("Remove")) {
            self.showActionSheet[deck.id] = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                let context = CoreDataStack.shared.persistentContainer.viewContext
                let request: NSFetchRequest<StarCardEntity> = StarCardEntity.fetchRequest()
                
                if let entity = deck.entity as? ListEntity,
                    let listId = entity.id {
                    request.predicate = NSPredicate(format: "listId == %@ && sectionId == %@ && starred == %@",
                                                    listId as CVarArg, listId as CVarArg, NSNumber(value: true))
                    
                    let starCards = try! context.fetch(request)
                    
                    for sc in starCards {
                        sc.starred = false
                        try! context.save()
                    }
                    
                } else if let entity = deck.entity as? CloudSectionEntity,
                    let listId = entity.list?.id,
                    let sectionId = entity.id {
                    request.predicate = NSPredicate(format: "listId == %@ && sectionId == %@ && starred = %@",
                                                    listId as CVarArg, sectionId as CVarArg, NSNumber(value: true))
                    
                    let starCards = try! context.fetch(request)
                    
                    for sc in starCards {
                        sc.starred = false
                        try! context.save()
                    }
                }
                
                self.reload()
            }
        }
        
        let cancel = ActionSheet.Button.cancel(Text("Cancel")) {
            print("hit abort")
        }
        
        #if os(iOS)
        return ActionSheet(title: Text("Study type"),  buttons: [
            translation, pinyin, tone, remove, cancel
        ])
        #elseif os(watchOS)
        return ActionSheet(title: Text("Study type"),  buttons: [
            tone, pinyin, translation, remove
        ])
        #endif
        
    }
    
    func getContent() -> AnyView {
        if studyLists.count == 0 {
            return AnyView(Text("You did not select any words for studying")
                .multilineTextAlignment(.center))
        }
        
        let list = List(studyLists) { item in
            VStack(alignment: .leading) {
                NavigationLink(destination: LazyView(self.actionViewMode.getView(deck: item)),
                               isActive: Binding(
                                   get: { return self.showActionView[item.id] ?? false },
                                   set: { (newValue) in return self.showActionView[item.id] = newValue}
                               ),
                               label: { EmptyView() })
                
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
        }
        
        #if os(watchOS)
        return AnyView(list.focusable(true))
        #else
        return AnyView(list)
        #endif
    }
    
    func reload() {
        let (lists, actionViews, actionSheets) = getLists()
        studyLists = lists
        showActionView = actionViews
        showActionSheet = actionSheets
    }
    
    var body: some View {
        return getContent()
            .onAppear(perform: {
                self.reload()
            })
            .onReceive(studyManager.cardsChanged, perform: { _ in
                self.reload()
            })
            .navigationTitle("Study")
    }
}

struct StudyTab_Previews: PreviewProvider {
    static var previews: some View {
        StudyView()
    }
}
