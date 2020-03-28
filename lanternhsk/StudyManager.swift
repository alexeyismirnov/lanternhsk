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
    init?(deck: VocabDeck, studyManager: StudyManager) {
        self.id = deck.id
        self.name = deck.name
        self.cards = []
        
        /*
        let vocabCards: [VocabCard] = deck.load()
        let studyCards = studyManager.cards.filter() { $0.deckId == deck.id }
        
        self.cards = vocabCards.filter()
            { card in studyCards.filter() { card.id == $0.cardId }.count > 0  }
        
        if cards.isEmpty {
            return nil
        }
 */
    }
}

class StudyManager: ObservableObject {
    let cardsKey = "study-cards"

    @Published var cards = [StudyCard]()
    
    let cardsChanged = PassthroughSubject<Void, Never>()
    
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
