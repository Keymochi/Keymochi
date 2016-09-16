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
//import FirebaseDatabase
//import FirebaseStorage
import FirebaseAnalytics
import FirebaseDatabase

class DataChunkViewController: UITableViewController {
    
    var realm: Realm!
    var dataChunk: DataChunk!
    var emotionSegmentedControl: UISegmentedControl!
    var ref: FIRDatabaseReference!
    var uid: String!
    var ref2: FIRDatabaseReference!
    
    @IBOutlet weak var emotionContainer: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = FIRDatabase.database().reference()
        
        
//        var ref = Firebase(url: "https://docs-examples.firebaseio.com/web/saving-data/fireblog")
//        self.ref = "https://keymochi-82adb.firebaseio.com/"

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
//        if let userId = UserDefaults.standard.object(forKey: "userid_preference"){
        self.uid = UserDefaults.standard.object(forKey: "userid_preference") as! String!
        if (uid).isEmpty {
            let alert = UIAlertController.init(title: "Error", message: "Please set your userId by going to Settings --> Keymochi --> And Enter a Value in the UserID field", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return

           
        } else{
//        if let userId = UserDefaults.standard.object(forKey: "userid_preference") {
                print(uid)
//                self.uid = userId as! String as NSString!
                var emotion: Emotion!
            let titleFailure = "Error"
            let messageFailure = "There was a problem uploading the Data, please try again!"
            let titleSuccess = "Success"
            let messageSuccess = "The data has been uploaded successfully"
            let alertSuccess = UIAlertController.init(title: titleSuccess, message: messageSuccess, preferredStyle: .alert)
            let alertFailure = UIAlertController.init(title: titleFailure, message: messageFailure, preferredStyle: .alert)
            alertFailure.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            alertSuccess.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            
            
            
                if emotionSegmentedControl.selectedSegmentIndex != -1 {
                    emotion = Emotion.all[emotionSegmentedControl.selectedSegmentIndex]
                    print(emotion)
                    
                    self.ref2 = self.ref.child("users").child(uid as String).child("\(emotion)").childByAutoId()
                    if let totalNumberOfDeletions = dataChunk.totalNumberOfDeletions {
                        self.ref2.updateChildValues(["totalNumDel": totalNumberOfDeletions], withCompletionBlock: {
                            (error, ref) in
                            if (error != nil) {
                                print("totalNumDelcould not be saved.")
                                
                            } else {
                                print("totalNumDel saved successfully!")
                            }
                        })
                    }
                
                    
                    
                    if let interTapDistances = dataChunk.interTapDistances {
                        self.ref2.updateChildValues(["interTapDist": interTapDistances], withCompletionBlock: {
                            (error, ref) in
                            if (error != nil) {
                                print("interTapDist could not be saved.")
                            } else {
                                print("interTapDist saved successfully!")
                            }
                        })

                    }
                    
                    if let tapDurations = dataChunk.tapDurations {
                        self.ref2.updateChildValues(["tapDur": tapDurations],  withCompletionBlock: {
                            (error, ref) in
                            if (error != nil) {
                                print("tapDur could not be saved.")
                            } else {
                                print("tapDur saved successfully!")
                            }
                        })
                    }
                    
                    if let accelerationMagnitudes = dataChunk.accelerationMagnitudes {
                        self.ref2.updateChildValues(["accelMag": accelerationMagnitudes],  withCompletionBlock: {
                            (error, ref) in
                            if (error != nil) {
                                print("accelMag could not be saved.")
                            } else {
                                print("accelMag saved successfully!")
                            }
                        })
                    }
                    
                    if let gyroMagnitudes = dataChunk.gyroMagnitudes {
                        self.ref2.updateChildValues(["gyroMag": gyroMagnitudes],  withCompletionBlock: {
                            (error, ref) in
                            if (error != nil) {
                                print("gyroMag could not be saved.")
                            } else {
                                print("gyroMag saved successfully!")
                            }
                        })
                    }
                    
                    if let appVersion = dataChunk.appVersion {
                        self.ref2.updateChildValues(["appVer": appVersion], withCompletionBlock: {
                            (error, ref) in
                            if (error != nil) {
                                print("appVercould not be saved.")
                                
                                self.present(alertFailure, animated: true, completion: nil)
                            } else {
                                print("appVer saved successfully!")
                                self.present(alertSuccess, animated: true, completion: nil)
                            }
                        })

                    }
                    
                    
                    if let symbolCounts = dataChunk.symbolCounts {
                        var puncuationCount = 0
                        for (symbol, count) in symbolCounts {
                            for scalar in symbol.unicodeScalars {
                                let value = scalar.value
                                if (value >= 65 && value <= 90) || (value >= 97 && value <= 122) || (value >= 48 && value <= 57) {
                                    self.ref2.updateChildValues(["symbol": count],  withCompletionBlock: {
                                        (error, ref) in
                                        if (error != nil) {
                                            print("symbol could not be saved.")
                                        } else {
                                            print("symbol saved successfully!")
                                        }
                                    })
                                } else {
                                    puncuationCount += count
                                    switch symbol {
                                    case " ":
                                        self.ref2.updateChildValues([ "symbol_space": count],  withCompletionBlock: {
                                            (error, ref) in
                                            if (error != nil) {
                                                print("symbol_space could not be saved.")
                                            } else {
                                                print("symbol_space saved successfully!")
                                            }
                                        })
                                    case "!":
                                        self.ref2.updateChildValues(["symbol_exclamation_mark": count],  withCompletionBlock: {
                                            (error, ref) in
                                            if (error != nil) {
                                                print("symbol_exclamation_mark could not be saved.")
                                            } else {
                                                print("symbol_exclamation_mark saved successfully!")
                                            }
                                        })
                                    case ".":
                                        self.ref2.updateChildValues([ "symbol_period": count],  withCompletionBlock: {
                                            (error, ref) in
                                            if (error != nil) {
                                                print("symbol_period could not be saved.")
                                            } else {
                                                print("symbol_period saved successfully!")
                                            }
                                        })
                                    case "?":
                                        self.ref2.updateChildValues(["symbol_question_mark": count],  withCompletionBlock: {
                                            (error, ref) in
                                            if (error != nil) {
                                                print("symbol_question_mark could not be saved.")
                                            } else {
                                                print("symbol_question_mark saved successfully!")
                                            }
                                        })
                                    default:
                                        continue
                                    }
                                }
                            }
                        }
                        self.ref2.updateChildValues(["symbol_punctuation": puncuationCount],  withCompletionBlock: {
                            (error, ref) in
                            if (error != nil) {
                                print("symbol_punctuation could not be saved.")
                            } else {
                                print("symbol_punctuation saved successfully!")
                            }
                        })
                    }
                }
                
                
                else {
                    print(emotion)
                    let alert = UIAlertController.init(title: "Error", message: "Please label the emotion for this data chunk.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
            }
//        }
        
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
