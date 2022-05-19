//
//  AppDelegate.swift
//  CommunicationFramework
//
//  Created by Conrad Felgentreff on 18.05.22.
//

import UIKit
import CoreData

class AppDelegate: NSObject, UIApplicationDelegate {
    
    private(set) static var instance: AppDelegate! = nil
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ChatStore")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        AppDelegate.instance = self
        return true
    }
}
