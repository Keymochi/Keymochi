//
//  PAMEmotion.swift
//  PAM
//
//  Created by Huai-Che Lu on 9/23/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import Foundation

public typealias Valence = UInt8
public typealias Arousal = UInt8
public typealias Position = UInt8

public struct Emotion {
    public let valence: Valence
    public let arousal: Arousal
    
    public init?(_ valence: Valence, _ arousal: Arousal) {
        guard 1 <= valence && valence <= 4 && 1 <= arousal && arousal <= 4 else {
            return nil
        }
        self.valence = valence
        self.arousal = arousal
    }
    
    public init?(position: Position) {
        guard 1 <= position && position <= 16 else {
            return nil
        }
        let valence = Valence(position % 4 == 0 ? 4 : position % 4)
        let a = position - valence
        let arousal = Arousal(4 - a / 4)
        self.init(valence, arousal)
    }
    
    public var positiveAffectScore: UInt8 {
        return 4 * valence + arousal - 4
    }
    
    public var negativeAffectScore: UInt8 {
        return 4 * (5 - valence) + arousal - 4
    }
    
    public var tag: String {
        return (Emotion.emotionTagDict[arousal]?[valence]!)!
    }
    
    public var position: Position {
        return (4 - arousal) * 4 + valence
    }
    
    fileprivate static let emotionTagDict: [Arousal:[Valence: String]] = [
        4: [
            1: "afraid",
            2: "tense",
            3: "excited",
            4: "delighted"
        ],
        3: [
            1: "frustrated",
            2: "angry",
            3: "happy",
            4: "glad"
        ],
        2: [
            1: "miserable",
            2: "sad",
            3: "calm",
            4: "satisfied"
        ],
        1: [
            1: "gloomy",
            2: "tired",
            3: "sleepy",
            4: "serene"
        ]
    ]
}
