//
//  PersonalPageViewController.swift
//  Alien
//
//  Created by Ken Yeh on 2019/9/4.
//  Copyright © 2019 Ken Yeh. All rights reserved.
//

import Foundation
import Firebase
import UIKit

class PersonalPageViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Welcome to Personal Page")
        
        
    }
    
    @IBAction func logOutButtonPressed(_ sender: UIButton) {
        if Auth.auth().currentUser?.uid != nil {
            do {
                
                try Auth.auth().signOut()
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let loginView = self.storyboard?.instantiateViewController(withIdentifier: "LogInView")
                appDelegate.window?.rootViewController = loginView
                appDelegate.window?.makeKeyAndVisible()
                
            } catch let error as NSError {
                
                print(error.localizedDescription)
                
            }
                
                
        }
    }
}
