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
    /*
    VocabDeck(id: 1, name: "HSK 1", filename: "hsk1.json", wordCount: 150),
    VocabDeck(id: 2, name: "HSK 2", filename: "hsk2.json", wordCount: 150),
    VocabDeck(id: 3, name: "HSK 3", filename: "hsk3.json", wordCount: 300),
 */
]

enum Tone: Int {
    case none = 0, first = 1, second = 2, third = 3, fourth = 4
}

extension Tone {
    init?(_ str: String) {
        let scalars = str.decomposedStringWithCanonicalMapping
            .unicodeScalars
            .map { $0.value }
            .filter { [0x300, 0x301, 0x304, 0x30C].contains($0) }
        
        if scalars.count == 0 {
            self = .none
            
        } else if scalars.count == 1 {            
            switch scalars[0] {
            case 0x304:
                self = .first
            case 0x301:
                self = .second
            case 0x30C:
                self = .third
            case 0x300:
                self = .fourth
            default:
                self = .none
            }
            
        } else {
            return nil
        }
    }
}

struct VocabCard: Hashable, Codable, Identifiable {
    var id: UUID
    var word: String
    var pinyin: String
    var translation: String
   
    func getTones() -> [Tone] {
        var tones = [Tone]()
        for str in pinyin.components(separatedBy: " ") {
            if let tone = Tone(str) {
                tones.append(tone)
            }
        }
        
        return tones
    }
}

struct VocabDeck: Hashable, Codable, Identifiable {
    var id: UUID
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



