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
    
    @IBOutlet weak var textFieldLogInEmail: UITextField!
    
    @IBOutlet weak var textFieldLogInPassword: UITextField!
    
    @IBOutlet weak var textFieldRegisterEmail: UITextField!
    
    @IBOutlet weak var textFieldRegisterPassword: UITextField!
    
    @IBOutlet weak var textFieldCreateNickname: UITextField!
    
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
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        
        if let email: String = textFieldRegisterEmail.text, let password: String = textFieldRegisterPassword.text {
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if let error = error {
                   print(error.localizedDescription)
                   print("Sign up Failed")
                    
                   let alert = UIAlertController(title: "註冊發生錯誤", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                   let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                       alert.addAction(alertAction)
                   self.present(alert, animated: true, completion: nil)
                    
                   return
                }
                print("Sign up Successfully")
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                let logInViewController = self.storyboard?.instantiateViewController(withIdentifier: "LogInView")
                appDelegate.window?.rootViewController = logInViewController
                appDelegate.window?.makeKeyAndVisible()
            }
        }
    }
    
    @IBAction func createNicknameButtonPressed(_ sender: UIButton) {
        
        guard let userID: String = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference()
        let usersRef = ref.child("users").child(userID)
        //檢測使用者是否輸入暱稱
        if textFieldCreateNickname.text != "" {
            if let nickName: String = textFieldCreateNickname.text {
                //將使用者存進firebase
                let nameValue:[String:Any] = ["name":nickName]
                usersRef.setValue(nameValue)
                print("firebase updates")
                //畫面跳轉至首頁
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let groupListView = self.storyboard?.instantiateViewController(withIdentifier: "GroupListTabBarView")
                appDelegate.window?.rootViewController = groupListView
                appDelegate.window?.makeKeyAndVisible()
                
            }
        } else {
            let alert = UIAlertController(title: "創建暱稱錯誤", message: "請輸入有效的暱稱", preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func returnButtonPressed(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let logInView = self.storyboard?.instantiateViewController(withIdentifier: "LogInView")
        appDelegate.window?.rootViewController = logInView
        appDelegate.window?.makeKeyAndVisible()
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
        
        print("Alien")
        
    }
}


