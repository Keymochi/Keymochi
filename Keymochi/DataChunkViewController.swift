//
//  DataChunkViewController.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 4/7/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import UIKit
import Parse
import RealmSwift
import Firebase

class DataChunkViewController: UITableViewController {
    
    var realm: Realm!
    var dataChunk: DataChunk!
    var emotionSegmentedControl: UISegmentedControl!
    var ref: FIRDatabaseReference!
    var uid: NSString!
    
    @IBOutlet weak var emotionContainer: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = FIRDatabase.database().reference()
        // Do any additional setup after loading the view.
        let segmentedControlWidth = UIScreen.main.bounds.width - 30
        emotionSegmentedControl = UISegmentedControl.init(frame: CGRect(x: 15, y: 7, width: segmentedControlWidth, height: 30))
        for (index, emotion) in Emotion.all.enumerated() {
            emotionSegmentedControl
                .insertSegment(withTitle: emotion.description, at: index, animated: false)
        }
        
        if let emotion = dataChunk.emotion, let index = Emotion.all.index(of: emotion) {
            emotionSegmentedControl.selectedSegmentIndex = index
        }
        
        emotionSegmentedControl.addTarget(self, action: #selector(changeEmotion(_:)), for: UIControlEvents.valueChanged)
        
        emotionContainer.addSubview(emotionSegmentedControl)
    }
    
    func changeEmotion(_ sender: UISegmentedControl) {
        let emotion = Emotion.all[sender.selectedSegmentIndex]
        DataManager.sharedInatance.updateDataChunk(dataChunk, withEmotion: emotion)
    }
    
    @IBAction func uploadDataChunk(_ sender: AnyObject) {
        if let userId = UserDefaults.standard.object(forKey: "userid_preference") {
            self.uid = userId as! String as NSString!
            var emotion: Emotion!
            
            if emotionSegmentedControl.selectedSegmentIndex != -1 {
                emotion = Emotion.all[emotionSegmentedControl.selectedSegmentIndex]
                if let totalNumberOfDeletions = dataChunk.totalNumberOfDeletions {
                    self.ref.child("users").child(uid as String).child("\(emotion)").updateChildValues(["totalNumDel": totalNumberOfDeletions])
                }
                
                if let interTapDistances = dataChunk.interTapDistances {
                    self.ref.child("users").child(uid as String).child("\(emotion)").updateChildValues(["interTapDist": interTapDistances])
                }
                
                if let tapDurations = dataChunk.tapDurations {
                    self.ref.child("users").child(uid as String).child("\(emotion)").updateChildValues(["tapDur": tapDurations])
                }
                
                if let accelerationMagnitudes = dataChunk.accelerationMagnitudes {
                    self.ref.child("users").child(uid as String).child("\(emotion)").updateChildValues(["accelMag": accelerationMagnitudes])
                }
                
                if let gyroMagnitudes = dataChunk.gyroMagnitudes {
                    self.ref.child("users").child(uid as String).child("\(emotion)").updateChildValues(["gyroMag": gyroMagnitudes])
                }
                
                if let appVersion = dataChunk.appVersion {
                    self.ref.child("users").child(uid as String).child("\(emotion)").updateChildValues(["appVer": appVersion])
                }
                
                
                if let symbolCounts = dataChunk.symbolCounts {
                    var puncuationCount = 0
                    for (symbol, count) in symbolCounts {
                        for scalar in symbol.unicodeScalars {
                            let value = scalar.value
                            if (value >= 65 && value <= 90) || (value >= 97 && value <= 122) || (value >= 48 && value <= 57) {
                                self.ref.child("users").child(uid as String).child("\(emotion)").updateChildValues(["symbol": count])
                            } else {
                                puncuationCount += count
                                switch symbol {
                                case " ":
                                    self.ref.child("users").child(uid as String).child("\(emotion)").updateChildValues([ "symbol_space": count])
                                case "!":
                                    self.ref.child("users").child(uid as String).child("\(emotion)").updateChildValues(["symbol_exclamation_mark": count])
                                case ".":
                                    self.ref.child("users").child(uid as String).child("\(emotion)").updateChildValues([ "symbol_period": count])
                                case "?":
                                    self.ref.child("users").child(uid as String).child("\(emotion)").updateChildValues(["symbol_question_mark": count])
                                default:
                                    continue
                                }
                            }
                        }
                    }
                    self.ref.child("users").child(uid as String).child("\(emotion)").updateChildValues(["symbol_punctuation": puncuationCount])
                }
            }
            
            
            
        } else {
            let alert = UIAlertController.init(title: "Error", message: "Please label the emotion for this data chunk.", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        let vc = segue.destination as! DataChunkDetailsTableViewController
        func bindData(_ data: [String], andTimestamps timeStamps: [String]?, withTitle title: String) {
            vc.data = data
            vc.timestamps = timeStamps
            vc.title = "\(title) (\(data.count))"
        }
        
        switch identifier {
        case "ShowKey":
            bindData(dataChunk.keyEvents?.map { $0.description } ?? [],
                     andTimestamps: dataChunk.keyEvents?.map { $0.timestamp } ?? [],
                     withTitle: "Key")
        case "ShowITD":
            bindData(dataChunk.interTapDistances?.map(String.init) ?? [],
                     andTimestamps: nil,
                     withTitle: "Inter-Tap Distance")
        case "ShowAcceleration":
            bindData(dataChunk.accelerationDataPoints?.map { $0.description } ?? [],
                     andTimestamps: dataChunk.accelerationDataSequence?.timestamps ?? [],
                     withTitle: "Acceleration")
        case "ShowGyro":
            bindData(dataChunk.gyroDataPoints?.map { $0.description } ?? [],
                     andTimestamps: dataChunk.gyroDataSequence?.timestamps ?? [],
                     withTitle: "Gyro")
        default:
            break
        } 
    }
}
