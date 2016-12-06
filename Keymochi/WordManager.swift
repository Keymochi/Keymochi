//
//  WordSentiment.swift
//  Keymochi
//
//  Created by Claire Opila on 10/26/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import Foundation

class WordManager  {

    private static var _positiveWords : Set<String>!
    private static var _negativeWords: Set<String>!
    
    public class var positiveWords: Set<String> {
        if _positiveWords == nil {
            _positiveWords = self.wordSetFromFile("positive-words")
        }
        return _positiveWords
    }
    
    public class var negativeWords: Set<String> {
        if _negativeWords == nil {
            _negativeWords = self.wordSetFromFile("negative-words")
        }
        return _negativeWords
    }
    
    private class func wordSetFromFile(_  fileName: String) -> Set<String> {
        let text = stringFromFile(fileName)!
        let words = text.characters.split { $0 == "\n" }.map { String($0) }
        return Set(words)
    }
    
    private class func stringFromFile(_ file: String) -> String? {
        guard let path = Bundle.main.path(forResource: file, ofType: "txt") else { return nil }
        do { return try String(contentsOfFile: path) }
        catch { return .none }
    }
}










