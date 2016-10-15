//
//  SettingsViewController.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 10/15/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var userIdTextField: UITextField!
    var sharedDefaults: UserDefaults {
        return UserDefaults(suiteName: Constants.groupIdentifier)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userIdTextField.text = sharedDefaults.object(forKey: "userid_preference") as? String
    }
    
    @IBAction func removeAllData(_ sender: AnyObject) {
        let alertController = UIAlertController.init(title: "Delete Data", message: "Are you sure to delete all data?", preferredStyle: .alert)
        let actionDelete = UIAlertAction.init(title: "Delete", style: .destructive) { alertAction -> Void in
            DataManager.sharedInatance.clearData()
        }
        
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel) { alertAction -> Void in
            
        }
        
        alertController.addAction(actionCancel)
        alertController.addAction(actionDelete)
        
        present(alertController, animated: true, completion: nil)
    }
    
}

extension SettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case userIdTextField:
            guard let userId = userIdTextField.text else { return }
            sharedDefaults.set(userId, forKey: "userid_preference")
            sharedDefaults.synchronize()
        default:
            break
        }
    }
}
