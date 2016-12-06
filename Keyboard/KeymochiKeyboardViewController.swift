//
//  KeymochiKeyboardViewController.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 4/13/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import UIKit
import CoreMotion


import PAM

class KeymochiKeyboardViewController: KeyboardViewController {
    
    var motionManager: CMMotionManager!
    
    var backspaceKeyEvent: BackspaceKeyEvent?
    var symbolKeyEventMap: [String: SymbolKeyEvent]!
    var overlay = UIView()
    
    var phraseGlobal: NSArray = []
    var sentence: String = ""
       

	var currentWord: String = "" {
		didSet {
			updateAutoCorrectionSelector()
		}
	}
	var autoCorrectionSelector: AutoCorrectionSelector {
		return self.bannerView as! AutoCorrectionSelector
	}
    var emotion: Emotion?
    var timer: Timer!
    var assessmentSheet: PAMAssessmentSheet!
	var defaults: UserDefaults { return UserDefaults.standard }	
	
	let lastOpenThreshold: TimeInterval = 5.0
	let keepUsingThreshold: TimeInterval = 10.0
    
    var keys = [String]()
    var touchTimestamps = [TouchTimestamp]()
    
    var lastText: String!
    var currentTexts =  [String]()
	
	class var kHasAssessedEmotion: String { return "KeyboardHasAssessedEmotion" }
	class var kKeepUsingTime: String { return "KeyboardKeepUsingTime" }
	class var kLastOpenTime: String { return "KeyboardLastOpenTime" }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        symbolKeyEventMap = [String: SymbolKeyEvent]()
        print(symbolKeyEventMap)
        
        // Make sure the container is empty.
        DataManager.sharedInatance.reset()
        
        self.forwardingView.delegate = self
        
        motionManager = CMMotionManager()
        let motionUpdateInterval: TimeInterval = 0.1
        motionManager.deviceMotionUpdateInterval = motionUpdateInterval
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (deviceMotioin, error) in
            guard error == nil else { return }
            guard let deviceMotioin = deviceMotioin else { return }
            
            let accelerationDataPoint = MotionDataPoint(acceleration: deviceMotioin.userAcceleration, atTime: deviceMotioin.timestamp)
            let gyroDataPoint = MotionDataPoint(rotationRate: deviceMotioin.rotationRate, atTime: deviceMotioin.timestamp)
            DataManager.sharedInatance.addMotionDataPoint(accelerationDataPoint, ofSensorType: .acceleration)
            DataManager.sharedInatance.addMotionDataPoint(gyroDataPoint, ofSensorType: .gyro)
        }
		
		self.autoCorrectionSelector.delegate = self
		if defaults.object(forKey: KeymochiKeyboardViewController.kHasAssessedEmotion) == nil {
			defaults.set(false, forKey: KeymochiKeyboardViewController.kHasAssessedEmotion)
		}
		if defaults.object(forKey: KeymochiKeyboardViewController.kKeepUsingTime) == nil {
			defaults.set(0.0, forKey: KeymochiKeyboardViewController.kKeepUsingTime)
		}
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print(self.currentTexts)
        motionManager.stopDeviceMotionUpdates()
        
        assert(keys.count == touchTimestamps.count)
        
		let hasAssessedEmotion = defaults.bool(forKey: KeymochiKeyboardViewController.kHasAssessedEmotion)
        if hasAssessedEmotion {
            
            let words = (self.currentTexts.reduce([], { return $0 + $1.components(separatedBy: CharacterSet(charactersIn: " \n")) })
                + wholeSentence.components(separatedBy: CharacterSet(charactersIn: " \n"))).filter { $0 != "" }
            
            let sentiment = getSentiment(words: words)
            
            for (key, touchTimestamp) in zip(keys, touchTimestamps) {
                
                var keyEvent: KeyEvent!
                
                if key.characters.count == 1 {
                    keyEvent = SymbolKeyEvent()
                    (keyEvent as! SymbolKeyEvent).key = key
                } else {
                    let components = key.components(separatedBy: " ")
                    keyEvent = BackspaceKeyEvent()
                    (keyEvent as! BackspaceKeyEvent).numberOfDeletions = Int(components[1])!
                }
                
                keyEvent.downTime = touchTimestamp.down
                keyEvent.upTime = touchTimestamp.up
                
                DataManager.sharedInatance.addKeyEvent(keyEvent)
            }
            DataManager.sharedInatance.dumpCurrentData(withEmotion: emotion!, withSentiment: sentiment)
        }
		defaults.set(0.0, forKey: KeymochiKeyboardViewController.kKeepUsingTime)
		
        super.viewDidDisappear(animated)
    }
    
    override func symbolKeyUp(_ sender: KeyboardKey) {
        guard let key = self.layout?.keyForView(key: sender)?.outputForCase(self.shiftState.uppercase()) else {
            return
        }
        
        keys.append(key)
		
		if let word = textDocumentProxy.documentContextBeforeInput?.components(separatedBy: CharacterSet(charactersIn: " \n")).last! {
			currentWord = word
		}
        if key == " " || key == "\n" {
			if let firstGuess = getSuggestedWords()?.gussess.first {
				replaceWord(replacement: firstGuess)
			}
			currentWord = ""
        } else {
			currentWord += key
		}
    }
	
	private func getSuggestedWords() -> (completions: [String], gussess: [String])? {
		if currentWord == "" {
			return ([], [])
		}
		let textChecker = UITextChecker()
		let range = NSRange(location: 0, length: currentWord.characters.count)
		let completions: [String] = textChecker.completions(forPartialWordRange: range, in: currentWord, language: "en_US")!
		var guesses: [String]
		let misspelledRange = textChecker.rangeOfMisspelledWord(
			in: currentWord, range: range, startingAt: 0, wrap: false, language: "en_US")
		if misspelledRange.location != NSNotFound {
			guesses = textChecker.guesses(forWordRange: range, in: currentWord, language: "en_US")!
		} else {
			guesses = [currentWord]
		}
		return (completions, guesses)
	}
	
	func replaceWord(replacement: String){
		for _ in 0..<currentWord.characters.count {
			textDocumentProxy.deleteBackward()
		}
		textDocumentProxy.insertText(replacement)
	}
    
   
	
	private func updateAutoCorrectionSelector() {
		if currentWord == "" {
			self.autoCorrectionSelector.updateButtonArray(words: [])
		}
		else if let completions = getSuggestedWords()?.completions.filter({ $0 != currentWord }) {
			var partialGuesses: [String]
			if completions.count < 2 {
				partialGuesses = ["\"" + currentWord + "\""] + completions
			} else {
				partialGuesses = ["\"" + currentWord + "\""] + Array(completions[0...1])
			}
			self.autoCorrectionSelector.updateButtonArray(words: partialGuesses)
		} else {
			self.autoCorrectionSelector.updateButtonArray(words: ["\"" + currentWord + "\""])
		}
	}
	
    override func symbolKeyDown(_ sender: KeyboardKey) {
        switchAssessmentState()
        guard let key = self.layout?.keyForView(key: sender)?.outputForCase(self.shiftState.uppercase()) else {
            return
        }
        
        let symbolKeyEvent = SymbolKeyEvent()
        symbolKeyEvent.downTime = CACurrentMediaTime()
        symbolKeyEvent.key = key
        symbolKeyEventMap[key] = symbolKeyEvent
    }
    
    override func backspaceDown(_ sender: KeyboardKey) {
        switchAssessmentState()
        let keyEvent = BackspaceKeyEvent()
        keyEvent.downTime = CACurrentMediaTime()
        backspaceKeyEvent = keyEvent
		if let word = textDocumentProxy.documentContextBeforeInput?.components(separatedBy: CharacterSet(charactersIn: " \n")).last! {
			currentWord = word
			if currentWord != "" {
				currentWord.remove(at: currentWord.index(before: currentWord.endIndex))
			}
		}
        super.backspaceDown(sender)
    }
    
    override func backspaceUp(_ sender: KeyboardKey) {
        if let numberOfDeletions = numberOfDeletions {
            keys.append("\\b \(numberOfDeletions)")
        }
        super.backspaceUp(sender)
    }
	
	override func createBanner() -> ExtraView? {
		return AutoCorrectionSelector(globalColors: type(of: self).globalColors, darkMode: false, solidColorMode: self.solidColorMode())
	}

    func switchAssessmentState() {
		
		if defaults.object(forKey: KeymochiKeyboardViewController.kLastOpenTime) == nil {
			defaults.set(Date(), forKey: KeymochiKeyboardViewController.kLastOpenTime)
		}
		
		let hasAssessedEmotion = defaults.bool(forKey: KeymochiKeyboardViewController.kHasAssessedEmotion)
		let lastOpenTimeInterval = -(defaults.object(forKey: KeymochiKeyboardViewController.kLastOpenTime) as! Date).timeIntervalSince(Date())
		let keepUsingTime = defaults.double(forKey: KeymochiKeyboardViewController.kKeepUsingTime)
		
		if lastOpenTimeInterval < lastOpenThreshold {
			defaults.set(keepUsingTime + lastOpenTimeInterval, forKey: KeymochiKeyboardViewController.kKeepUsingTime)
		} else {
			defaults.set(0.0, forKey: KeymochiKeyboardViewController.kKeepUsingTime)
		}
		
		if hasAssessedEmotion && lastOpenTimeInterval > lastOpenThreshold {
			defaults.set(false, forKey: KeymochiKeyboardViewController.kHasAssessedEmotion)
		} else if !hasAssessedEmotion && keepUsingTime > keepUsingThreshold {
            
            createOverlay()
			
		}
		defaults.set(Date(), forKey: KeymochiKeyboardViewController.kLastOpenTime)
	}
	
	func promptAssessmentSheet() {
        assessmentSheet = PAMAssessmentSheet(frame: self.view.bounds, option: .intermediate)
        assessmentSheet.backgroundColor = UIColor.yellow
        assessmentSheet.delegate = self
        view.addSubview(assessmentSheet)
    }
    

    func buttonAction(sender: UIButton!) {
        print("Button tapped")
        overlay.removeFromSuperview()
        promptAssessmentSheet()
    }
    
    func  createOverlay(){
        
        overlay.frame = self.view.bounds
        overlay.backgroundColor = UIColor.black
        
        // create button
        let originX = self.view.frame.midX
        let originY = self.view.frame.midY
        let buttonWidth = self.view.frame.size.width / 2.0
        let buttonHeight = self.view.frame.size.height / 4.0
        
        let button = UIButton(frame: CGRect(x: originX, y: originY, width: buttonWidth, height: buttonHeight))
        button.backgroundColor = Colors.mainColor
        button.setTitle("Click to Proceed", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
       
        // label generation
        let label = UILabel(frame: CGRect(x: originX, y: (originY - buttonHeight), width: self.view.frame.size.width, height: 100))
        let labelY = originY - label.frame.height + 40
        label.textColor = .white
        label.textAlignment = .center
        label.text = "On the next screen, select the photo that best captures how you feel right now"
        label.numberOfLines = 4
        label.font = UIFont.boldSystemFont(ofSize: 24.0)
        
        // label and button centering
        label.center = CGPoint(x: view.frame.midX, y: labelY)
        let buttonY = labelY + label.frame.height
        button.center = CGPoint(x: view.frame.midX, y: buttonY)
        // add both label and button to the overlay view
        overlay.addSubview(label)
        overlay.addSubview(button)
        
        // add the overlay to the subview
        view.addSubview(overlay)
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        print("textWillChange")
        lastText = self.wholeSentence
        
        super.textWillChange(textInput)
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        print("texDidChange")
        if wholeSentence == "" && lastText != "" {
            currentTexts.append(lastText)
        }
        
        super.textDidChange(textInput)
    }
    
    private var wholeSentence: String {
        if textDocumentProxy.documentContextBeforeInput == nil && textDocumentProxy.documentContextAfterInput == nil {
            return ""
        }
        
        if let before = textDocumentProxy.documentContextBeforeInput, let after = textDocumentProxy.documentContextAfterInput   {
            return before + after
        }
        
        return ((textDocumentProxy.documentContextBeforeInput != nil) ?
            textDocumentProxy.documentContextBeforeInput! :
            textDocumentProxy.documentContextAfterInput!)
    }
}

// MARK: - AutoCorrectionSelectorDelegate Methods
extension KeymochiKeyboardViewController: AutoCorrectionSelectorDelegate {
	func autoCorrectionSelector(_: AutoCorrectionSelector, correctWithWord word: String) {
		var replacement = word
		if replacement[replacement.startIndex] == "\"" {
			replacement = replacement.replacingOccurrences(of: "\"", with: "")
		}
		replaceWord(replacement: replacement)
		currentWord = ""
	}
}

// MARK: - PAMAssessmentSheetDelegate Methods
extension KeymochiKeyboardViewController: PAMAssessmentSheetDelegate {
    public func assessmentSheet(_: PAMAssessmentSheet, didSelectEmotion emotion: Emotion) {
        self.emotion = emotion
        assessmentSheet.removeFromSuperview()
//        overlay.removeFromSuperview()
        defaults.set(true, forKey: KeymochiKeyboardViewController.kHasAssessedEmotion)
    }
}

// MARK: - FowardingViewDelegate Methods
extension KeymochiKeyboardViewController: FowardingViewDelegate {
    func fowardingView(_: ForwardingView,
                       didOutputTouchTimestamp touchTimestamp: TouchTimestamp,
                       onView view: UIView) {
        guard let keyboardKey = view as? KeyboardKey else { return }
        guard let key = layout!.keyForView(key: keyboardKey) else { return }
        if key.hasOutput || key.type == .backspace {
            touchTimestamps.append(touchTimestamp)
        }
    }
}

// MARK: - Sentiment Analysis
extension KeymochiKeyboardViewController {
    func getSentiment(words : [String]) -> Float {
        guard !words.isEmpty else { return 0.0 }
        return words
            .map { $0.lowercased() }
            .map { self.getSentimentScore($0) }
            .reduce(0.0, +) / Float(words.count)
    }
    
    private func getSentimentScore(_ word: String) -> Float {
        return WordManager.positiveWords.contains(word) ? 1.0 : (WordManager.negativeWords.contains(word) ? -1.0 : 0.0)
    }
}
