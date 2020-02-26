//
//  StudyManager.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 12/25/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import SwiftUI
import Combine

struct StudyCard: Codable {
    var deckId: Int
    var cardId: Int
    var totalAnswers: Int
    var correctAnswers: Int
    
    init(deckId: Int, cardId: Int) {
        self.deckId = deckId
        self.cardId = cardId
        self.totalAnswers = 0
        self.correctAnswers = 0
    }
}

struct StudyDeck: Codable, Identifiable {
    var id: Int
    var name: String
    var cards: [VocabCard]
}

extension StudyDeck {
    init?(deck: VocabDeck, studyManager: StudyManager) {
        self.id = deck.id
        self.name = deck.name
        
        let vocabCards: [VocabCard] = deck.load()
        let studyCards = studyManager.cards.filter() { $0.deckId == deck.id }
        
        self.cards = vocabCards.filter()
            { card in studyCards.filter() { card.id == $0.cardId }.count > 0  }
        
        if cards.isEmpty {
            return nil
        }
    }
}

class StudyManager: ObservableObject {
    let cardsKey = "study-cards"

    @Published var cards = [StudyCard]()
    
    let cardsChanged = PassthroughSubject<Void, Never>()
    let questionAdded = PassthroughSubject<Void, Never>()

    func load() {
        if let data = UserDefaults.standard.value(forKey: cardsKey) as? Data {
            if let cards = try? PropertyListDecoder().decode([StudyCard].self, from: data) {
                self.cards = cards
            }
        }
    }
    
    func save() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(cards), forKey: cardsKey)
    }
        
    func isStarred(card: VocabCard, in deckId: Int) -> Bool {
        cards.filter() { $0.cardId == card.id && $0.deckId == deckId }.count > 0
    }
    
    func addToStudy(card: VocabCard, in deckId: Int) {
        cards.append(StudyCard(deckId: deckId, cardId: card.id))
        save()
        cardsChanged.send()
    }
    
    func removeFromStudy(card: VocabCard, in deckId: Int) {
        cards.removeAll(where: { $0.cardId == card.id && $0.deckId == deckId })
        save()
        cardsChanged.send()
    }
    
    func addQuestion() {
        questionAdded.send()
    }
    
    func clear() {
      UserDefaults.standard.removeObject(forKey: cardsKey)
    }
}
