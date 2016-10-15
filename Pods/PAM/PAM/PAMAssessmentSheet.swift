//
//  PAMAssessmentSheet.swift
//  PAM
//
//  Created by Huai-Che Lu on 9/23/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import Foundation

public protocol PAMAssessmentSheetDelegate {
    func assessmentSheet(_: PAMAssessmentSheet, didSelectEmotion emotion: Emotion)
}

public enum PAMAssessmentSheetOption: Int {
    case minimum = 4
    case intermediate = 8
    case full = 16
    
    static let emotionTable: [PAMAssessmentSheetOption: [Emotion]] = [
        .minimum: [
            Emotion(position: 1)!, Emotion(position: 4)!,
            Emotion(position: 13)!, Emotion(position: 16)!
        ],
        .intermediate: [
            Emotion(position: 1)!, Emotion(position: 6)!,
            Emotion(position: 4)!, Emotion(position: 7)!,
            Emotion(position: 13)!, Emotion(position: 10)!,
            Emotion(position: 16)!, Emotion(position: 11)!,
        ],
        .full: [
            Emotion(position: 1)!, Emotion(position: 2)!, Emotion(position: 3)!, Emotion(position: 4)!,
            Emotion(position: 5)!, Emotion(position: 6)!, Emotion(position: 7)!, Emotion(position: 8)!,
            Emotion(position: 9)!, Emotion(position: 10)!, Emotion(position: 11)!, Emotion(position: 12)!,
            Emotion(position: 13)!, Emotion(position: 14)!, Emotion(position: 15)!, Emotion(position: 16)!,
        ]
    ]
}

open class PAMAssessmentSheet: UIView {
    var buttons = [UIButton]()
    var rows = [UIStackView]()
    open var delegate: PAMAssessmentSheetDelegate?
    var option: PAMAssessmentSheetOption!
    
    let collectionView: UICollectionView
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate let reuseIdentifier = "PAMCell"
    
    public init(frame: CGRect, option: PAMAssessmentSheetOption) {
        
        let flowLayout = UICollectionViewFlowLayout()
        let cellDimension = (frame.size.width - flowLayout.minimumInteritemSpacing * 3) / 4
        flowLayout.itemSize = CGSize(width: cellDimension, height: cellDimension)
        flowLayout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.clear
        
        super.init(frame: frame)
        self.option = option
        self.addSubview(collectionView)
        
        setUpCollectionView()
    }
    
    func setUpCollectionView() {
        collectionView.register(PAMEmotionCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.black
    }
    
    func buttonSelected(_ sender: UIButton) {
        guard let index = self.buttons.index(of: sender) else {
            return
        }
        
        guard let emotion = PAMAssessmentSheetOption.emotionTable[self.option]?[index] else {
            return
        }
        self.delegate?.assessmentSheet(self, didSelectEmotion: emotion)
    }
}

extension PAMAssessmentSheet: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let emotion = PAMAssessmentSheetOption.emotionTable[option]?[indexPath.row] else {
            return
        }
        self.delegate?.assessmentSheet(self, didSelectEmotion: emotion)
    }
}

extension PAMAssessmentSheet: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.option.rawValue
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PAMEmotionCell
        if let emotion = PAMAssessmentSheetOption.emotionTable[option]?[indexPath.row] {
            cell.imageView.image = PAMImage.loadRandomImage(forEmotion: emotion)
        }
        return cell
    }
}
