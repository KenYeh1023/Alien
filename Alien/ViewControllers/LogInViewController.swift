//
//  ViewController.swift
//  Alien
//
//  Created by Ken Yeh on 2019/8/23.
//  Copyright © 2019 Ken Yeh. All rights reserved.
//

import UIKit
import Firebase

class LogInViewController: UIViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBOutlet weak var textFieldLogInEmail: UITextField!
    @IBOutlet weak var textFieldLogInPassword: UITextField!
    
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    
    @IBAction func logInButtonPressed(_ sender: UIButton) {
        
        //檢查用戶是否忘記輸入帳號密碼
        if self.textFieldLogInEmail.text == "" || self.textFieldLogInPassword.text == "" {
            
            let alert = UIAlertController(title: "登入發生錯誤", message: "請輸入正確的信箱以及密碼", preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            
            } else {
            
            if let email: String = textFieldLogInEmail.text, let password: String = textFieldLogInPassword.text {
                Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                    if error == nil {
                        
                        print("Log in Successfully")
                        guard let userID: String = Auth.auth().currentUser?.uid else { return }
                        let usersRef = Database.database().reference().child("users").child(userID)
                        //查看使用者是否已經創建過暱稱
                        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
                            if snapshot.hasChild("name") {
                                //若以創建過暱稱畫面跳轉至首頁
                                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                let groupListView = self.storyboard?.instantiateViewController(withIdentifier: "GroupListTabBarView")
                                appDelegate.window?.rootViewController = groupListView
                                appDelegate.window?.makeKeyAndVisible()
                                
                            } else {
                                //若未創建過暱稱之使用者畫面跳轉至創建暱稱頁面
                                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                let nicknameView = self.storyboard?.instantiateViewController(withIdentifier: "CreateNicknameView")
                                appDelegate.window?.rootViewController = nicknameView
                                appDelegate.window?.makeKeyAndVisible()
                                
                            }
                        })
                    } else {
                        
                        let alert = UIAlertController(title: "登入發生錯誤", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(alertAction)
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                }
            }
        }
    }
    
    
    
    @IBAction func registerButtonInLogInViewPressed(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let registerView = self.storyboard?.instantiateViewController(withIdentifier: "RegisterView")
        appDelegate.window?.rootViewController = registerView
        appDelegate.window?.makeKeyAndVisible()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.logInButton.layer.borderColor = UIColor(red: 98.0/255.0, green: 179/255.0, blue: 156/255.0, alpha: 1).cgColor
        self.logInButton.layer.borderWidth = 2
        self.registerButton.layer.borderColor = UIColor(red: 98.0/255.0, green: 179/255.0, blue: 156/255.0, alpha: 1).cgColor
        self.registerButton.layer.borderWidth = 2
        
        self.textFieldLogInEmail.layer.cornerRadius = 5
        self.textFieldLogInEmail.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.textFieldLogInEmail.layer.shadowOpacity = 0.7
        self.textFieldLogInEmail.layer.shadowRadius = 5
        self.textFieldLogInEmail.layer.shadowColor = UIColor(red: 44.0/255.0, green: 62.0/255.0, blue: 80.0/255.0, alpha: 1).cgColor
        self.registerButton.layer.cornerRadius = 10
        self.logInButton.layer.cornerRadius = 10
        
        self.textFieldLogInPassword.layer.cornerRadius = 5
        self.textFieldLogInPassword.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.textFieldLogInPassword.layer.shadowOpacity = 0.7
        self.textFieldLogInPassword.layer.shadowRadius = 5
        self.textFieldLogInPassword.layer.shadowColor = UIColor(red: 44.0/255.0, green: 62.0/255.0, blue: 80.0/255.0, alpha: 1).cgColor
        
    }
}


