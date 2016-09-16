//
//  AppDelegate.swift
//  Keymochi
//
//  Created by Huai-Che Lu on 2/28/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import Parse
import RealmSwift
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    @nonobjc func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: Any]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Crashlytics.self])
        
        let keysDictionary = NSDictionary.init(contentsOfFile: Bundle.main.path(forResource: "keys", ofType: "plist")!)
        let applicationId = keysDictionary!["parseApplicationId"] as! String
        let clientKey = keysDictionary!["parseClientKey"] as! String
        
        Parse.initialize(
            with: ParseClientConfiguration {
                $0.applicationId = applicationId
                $0.clientKey = clientKey
            }
        )
        
        let directoryURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.groupIdentifier)
        let realmPath = (directoryURL?.appendingPathComponent("db.realm").path)!
        var realmConfig = Realm.Configuration()
        realmConfig.fileURL = URL.init(string: realmPath)
        realmConfig.schemaVersion = 2
        realmConfig.migrationBlock = { (migration, oldSchemaVersion) in
            if oldSchemaVersion < 1 {
                migration.enumerateObjects(ofType: DataChunk.className(), { (oldObject, newObject) in
                    newObject!["appVersion"] = "0.2.0"
                })
            }
            
            if oldSchemaVersion < 2 {
                migration.enumerateObjects(ofType: DataChunk.className(), { (oldObject, newObject) in
                    guard let emotionDescription = oldObject!["emotionDescription"] else {
                        return
                    }
                    
                    if emotionDescription as! String == Emotion.Neutral.description {
                        newObject!["emotionDescription"] = nil
                    }
                })
            }
        }
        Realm.Configuration.defaultConfiguration = realmConfig
        FIRApp.configure()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

