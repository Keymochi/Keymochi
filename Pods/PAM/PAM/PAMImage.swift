//
//  PAMImage.swift
//  PAM
//
//  Created by Huai-Che Lu on 9/22/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import Foundation

private enum Constant {
    static let bundleName = "Frameworks/PAM.framework/ResourceBundle.bundle"
    static let imageExtension = "jpg"
}

open class PAMImage {
    open static func loadAllImages(_ emotion: Emotion) -> [UIImage] {
        let position = emotion.position
        var images = [UIImage]()
        for i in 1...3 {
            let imagePath = Constant.bundleName.appending("/\(position)_\(i)")
            let url = Bundle.main.url(forResource: imagePath, withExtension: Constant.imageExtension)
            let imageData = try! Data(contentsOf: url!)
            images.append(UIImage(data: imageData)!)
        }
        
        return images
    }
    
    open static func loadImage(forEmotion emotion: Emotion, atIndex index: Int) -> UIImage {
        let emotionIndex = emotion.position
        let imagePath = Constant.bundleName.appending("/\(emotionIndex)_\(index)")
        let url = Bundle.main.url(forResource: imagePath, withExtension: Constant.imageExtension)
        let imageData = try! Data(contentsOf: url!)
        
        return UIImage(data: imageData)!
    }
    
    open static func loadRandomImage(forEmotion emotion: Emotion) -> UIImage {
        let index = Int(arc4random_uniform(3) + 1)
        return loadImage(forEmotion: emotion, atIndex: index)
    }
}
