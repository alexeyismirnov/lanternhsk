//
//  StudyManager.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 12/25/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import SwiftUI
import Combine
import CoreData

struct StudyCard: Codable {
    var deckId: UUID
    var cardId: UUID
    var totalAnswers: Int
    var correctAnswers: Int
    
    init(deckId: UUID, cardId: UUID) {
        self.deckId = deckId
        self.cardId = cardId
        self.totalAnswers = 0
        self.correctAnswers = 0
    }
}

struct StudyDeck:  Identifiable {
    var id: UUID
    var name: String
    var cards: [VocabCard]
}

extension StudyDeck {
    init?(entity: AnyObject) {
        self.id = UUID()
        self.cards = [VocabCard]()
        
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let request: NSFetchRequest<StarCardEntity> = StarCardEntity.fetchRequest()
        
        if let entity = entity as? ListEntity {
            let charType = SettingsCharType(rawValue: SettingsModel.shared.language)!

            self.name = entity.name!
            
            if let listId = entity.id {               
                request.predicate = NSPredicate(format: "listId == %@ && sectionId == %@ && starred == %@",
                                                listId as CVarArg, listId as CVarArg, NSNumber(value: true))
                
                let starCards = try! context.fetch(request)

                if starCards.count == 0 {
                    return nil
                }
                
                for sc in starCards {
                    let request2: NSFetchRequest<CardEntity> = CardEntity.fetchRequest()
                    request2.predicate = NSPredicate(format: "list.id == %@ && id == %@",
                                                     sc.listId! as CVarArg,
                                                     sc.cardId! as CVarArg)
                    
                    if let card = try! context.fetch(request2).first {
                        cards.append(VocabCard(entity: card, charType: charType))
                    }
                }
                
            } else {
                return nil
            }
            
        } else if let entity = entity as? CloudSectionEntity {
            let listName = entity.list?.name ?? ""
            self.name = "\(listName) - \(entity.name!)"
            
            if let listId = entity.list?.id,
                let sectionId = entity.id {
                request.predicate = NSPredicate(format: "listId == %@ && sectionId == %@ && starred = %@",
                                                listId as CVarArg, sectionId as CVarArg, NSNumber(value: true))
                
                let starCards = try! context.fetch(request)
                
                if starCards.count == 0 {
                    return nil
                }
                
                for sc in starCards {
                    let request2: NSFetchRequest<CloudCardEntity> = CloudCardEntity.fetchRequest()
                    request2.predicate = NSPredicate(format: "list.id == %@ && section.id == %@ && id == %@",
                                                     sc.listId! as CVarArg,
                                                     sc.sectionId! as CVarArg,
                                                     sc.cardId! as CVarArg)
                    
                    if let card = try! context.fetch(request2).first {
                        cards.append(VocabCard(entity: card))
                    }
                }
                
            } else {
                return nil
            }
            
        } else {
            return nil
        }
        
    }
    
    func shuffle(totalQuestions: Int) -> [VocabCard] {
        var result = [VocabCard]()
        var lastIndex: Int?
        
        for _ in 0..<totalQuestions {
            var newIndex: Int

            if cards.count == 1 {
                newIndex = 0
                
            } else {
                repeat {
                    newIndex = Int.random(in: 0..<cards.count)
                    
                } while (newIndex == lastIndex ?? -1)
            }

            lastIndex = newIndex
            result.append(cards[newIndex])
        }
        
        return result
    }
}

class StudyManager: ObservableObject {
    let cardsKey = "study-cards"

    @Published var cards = [StudyCard]()
    
    let cardsChanged = PassthroughSubject<Void, Never>()
    let searchStarted = PassthroughSubject<Void, Never>()

    @Published var searchQuery: String = ""
    
    var deck: StudyDeck?
    let questionAdded = PassthroughSubject<Void, Never>()
    
    func fetchOrCreate(listId: UUID, sectionId: UUID, cardId: UUID) -> StarCardEntity {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let request: NSFetchRequest<StarCardEntity> = StarCardEntity.fetchRequest()
        
        request.predicate = NSPredicate(format: "listId == %@ && sectionId == %@ && cardId == %@",
                                        listId as CVarArg,
                                        sectionId as CVarArg,
                                        cardId as CVarArg)
        
        let results = try! context.fetch(request)
        
        if let entity = results.first {
            return entity
            
        } else {
            let entity = StarCardEntity(context: context)
            entity.listId = listId
            entity.sectionId = sectionId
            entity.cardId = cardId
            entity.starred = false
            
            try! context.save()
            
            return entity
        }

    }
    
    func getStarCardEntity(card: VocabCard) -> StarCardEntity? {
        if let entity = card.entity as? CardEntity {
            if let list = entity.list,
                let listId = list.id,
                let cardId = entity.id
            {
                return fetchOrCreate(listId: listId, sectionId: listId, cardId: cardId)
            } else {
                return nil
            }
            
        } else if let entity = card.entity as? CloudCardEntity {
            if let list = entity.list,
                let section = entity.section,
                let listId = list.id,
                let sectionId = section.id,
                let cardId = entity.id {
                return fetchOrCreate(listId: listId, sectionId: sectionId, cardId: cardId)

            } else {
                return nil
            }
            
        } else {
            return nil
        }
    }

    func addToStudy(card: VocabCard) {
        let context = CoreDataStack.shared.persistentContainer.viewContext

        if let starCard = getStarCardEntity(card: card) {
            starCard.starred = true
            try! context.save()
        }
        
        cardsChanged.send()
    }
    
    func removeFromStudy(card: VocabCard) {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        
        if let starCard = getStarCardEntity(card: card) {
            starCard.starred = false
            try! context.save()
        }
        
        cardsChanged.send()
    }
    
    func isStarred(card: VocabCard) -> Bool {
        if let starCard = getStarCardEntity(card: card) {
            return  starCard.starred
        }
        
        return false
    }
    
    func addQuestion() {
        questionAdded.send()
    }
    
}
