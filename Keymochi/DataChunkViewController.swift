//
//  DataChunkViewController.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 4/7/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import Foundation
import UIKit

import Firebase
import FirebaseAnalytics
import FirebaseDatabase
import PAM
import RealmSwift

class DataChunkViewController: UITableViewController {
    
    var dataChunk: DataChunk!
    var uid: String!
    
    @IBOutlet weak var emotionContainer: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func alertSetupUserId() {
        let alert = UIAlertController.init(title: "Error", message: "Please set your userId by going to Settings --> Keymochi --> And Enter a Value in the UserID field", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func uploadDataChunk(_ sender: AnyObject) {
        DataManager.sharedInatance.upload(dataChunk: dataChunk)
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
