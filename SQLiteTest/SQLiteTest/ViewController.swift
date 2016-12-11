//
//  ViewController.swift
//  SQLiteTest
//
//  Created by tsuchiyamamasaru on 2016/12/10.
//  Copyright © 2016年 tsuchiyamamasaru. All rights reserved.
//

import Cocoa
import SQLite

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func buttonClicked(_ sender: Any) {
        
        let path = NSSearchPathForDirectoriesInDomains(
            .applicationSupportDirectory, .userDomainMask, true
            ).first! + Bundle.main.bundleIdentifier!
        
        print("\(path)")
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
                print("Removal successful")
            } catch let error {
                print("Error: \(error.localizedDescription)")
            }
        }
        
        let id = Expression<Int64>("id")
        let email = Expression<String>("email")
        let name = Expression<String?>("name")
        let users = Table("users")
        do
        {
            // create parent directory iff it doesn’t exist
            try FileManager.default.createDirectory(
                atPath: path, withIntermediateDirectories: true, attributes: nil
            )
            
            let db = try Connection("\(path)/db.sqlite3")
            
            try db.run(users.create { t in     // CREATE TABLE "users" (
                t.column(id, primaryKey: true) //     "id" INTEGER PRIMARY KEY NOT NULL,
                t.column(email, unique: true)  //     "email" TEXT UNIQUE NOT NULL,
                t.column(name)                 //     "name" TEXT
            })                                 // )
            
            try db.run(users.insert(email <- "alice@mac.com", name <- "Alice"))
            // INSERT INTO "users" ("email", "name") VALUES ('alice@mac.com', 'Alice')
            
            try db.run(users.insert(email <- "test@mac.com", name <- "test"))
            // INSERT INTO "users" ("email", "name") VALUES ('test@mac.com', 'test')
            
            for user in try db.prepare(users.select(id, email)) {
                print("id: \(user[id]), email: \(user[email])")
                // id: 1, email: alice@mac.com
                // id: 2, email: test@mac.com
            }
        } catch {
            print("insertion failed: \(error)")
        }
    }

}

