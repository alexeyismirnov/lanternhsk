//
//  Data.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 12/15/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import SwiftUI

let lists: [VocabDeck] = [
    VocabDeck(id: 1, name: "HSK 1", filename: "hsk1.json", wordCount: 150),
    VocabDeck(id: 2, name: "HSK 2", filename: "hsk2.json", wordCount: 150),
    VocabDeck(id: 3, name: "HSK 3", filename: "hsk3.json", wordCount: 300),
]

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




