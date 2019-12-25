//
//  Data.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 12/15/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import Combine
import UIKit
import SwiftUI

let lists: [VocabDeck] = [
    VocabDeck(id: 1, name: "HSK 1", filename: "hsk1.json", wordCount: 150),
    VocabDeck(id: 2, name: "HSK 2", filename: "hsk2.json", wordCount: 150),
    VocabDeck(id: 3, name: "HSK 3", filename: "hsk3.json", wordCount: 300),
]

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

typealias StudyCards = [StudyCard]

class StudyManager: ObservableObject {
    let cardsKey = "study-cards"

    @Published var cards: StudyCards = StudyCards()
    
    let cardsChanged = PassthroughSubject<Void, Never>()

    func load() {
        if let data = UserDefaults.standard.value(forKey: cardsKey) as? Data {
            if let cards = try? PropertyListDecoder().decode(StudyCards.self, from: data) {
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
    
    func clear() {
      UserDefaults.standard.removeObject(forKey: cardsKey)
    }
}

struct VocabCard: Hashable, Codable, Identifiable {
    var id: Int
    var word: String
    var pinyin: String
    var translation: String
}

struct VocabDeck: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    var filename: String
    var wordCount: Int
    
    func load<T: Decodable>() -> T {
        let data: Data
        
        guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
            else {
                fatalError("Couldn't find \(filename) in main bundle.")
        }
        
        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
        }
    }
}




