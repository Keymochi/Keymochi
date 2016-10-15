//
//  ViewController.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 2/28/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import UIKit

import PAM
import SwiftDate

class DataChunkTableViewController: UIViewController {
    
    var dataChunks = [DataChunk]()
    @IBOutlet weak var eventHistoryTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadData()
    }
    
    func reloadData() {
        dataChunks = DataManager.sharedInatance.getDataChunks()
        eventHistoryTableView.reloadData()
    }
    
    @IBAction func removeAllData(_ sender: AnyObject) {
        
        let alertController = UIAlertController.init(title: "Delete Data", message: "Are you sure to delete all data?", preferredStyle: .alert)
        let actionDelete = UIAlertAction.init(title: "Delete", style: .destructive) { alertAction -> Void in
            DataManager.sharedInatance.clearData()
            self.reloadData()
        }
        
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel) { alertAction -> Void in
            
        }
        
        alertController.addAction(actionCancel)
        alertController.addAction(actionDelete)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DataChunkDetails" {
            let vc: DataChunkViewController = segue.destination as! DataChunkViewController
            vc.dataChunk = sender! as! DataChunk
        }
    }
    
}


// MARK: - UITableViewDataSource
extension DataChunkTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataChunks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dataChunk = dataChunks[(indexPath as NSIndexPath).row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "KeyEventCell", for: indexPath)
        
        let emotionLabel      = cell.viewWithTag(100) as! UILabel
        let updatedAtLabel    = cell.viewWithTag(101) as! UILabel
        let firebaseKeyLabel  = cell.viewWithTag(102) as! UILabel
        
        emotionLabel.text = dataChunk.emotion.tag
        firebaseKeyLabel.text = dataChunk.firebaseKey ?? "(unpushed)"
        updatedAtLabel.text = dataChunk.createdAt.inRegion(Region.defaultRegion).description
        
        return cell
    }
}


// MARK: - UITableViewDelegate
extension DataChunkTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "DataChunkDetails", sender: dataChunks[(indexPath as NSIndexPath).row])
    }
}
