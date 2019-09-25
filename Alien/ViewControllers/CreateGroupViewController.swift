//
//  CreateGroupViewController.swift
//  Alien
//
//  Created by Ken Yeh on 2019/8/27.
//  Copyright © 2019 Ken Yeh. All rights reserved.
//

import Foundation
import Firebase

class CreateGroupViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBOutlet weak var gameListTableViewController: UITableView!
    
    @IBOutlet weak var gameSelectorText: UIButton!
    
    @IBOutlet weak var inputGroupTitle: UITextField!
    
    @IBOutlet weak var dateSelectorText: UIButton!
    
    @IBOutlet weak var groupMemberSelectorText: UIButton!

    @IBOutlet weak var createGroupButton: UIButton!
    
    
    var groupMemberArrayForPickerView: [String] = ["", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"]
    var gameListArray: [String] = ["傳說對決","Auto Chess : Origin","Mario Cart Tour","極速領域","第五人格","PUBG Mobile 絕地求生","Free Fire  我要活下起去","荒野行動 - Knives Out", "楓之谷 M ","魔力寶貝 M ","神魔之塔", "Pokemon Go 精靈寶可夢","黑色沙漠 MOBILE","天堂 M ","RO仙境傳說：守護永恆的愛"]
    
    var groupMemberString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inputGroupTitle.attributedPlaceholder = NSAttributedString(string: "請輸入揪團名稱", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        self.createGroupButton.layer.borderWidth = 2
        self.createGroupButton.layer.borderColor = UIColor(red: 98.0/255.0, green: 179/255.0, blue: 156/255.0, alpha: 1).cgColor
        self.gameListTableViewController.isHidden = true
        
    }
    
    
    @IBAction func gameSelectorButtonPressed(_ sender: Any) {
        
        if self.gameListTableViewController.isHidden == true {
            UIView.animate(withDuration: 0.3) {
                self.gameListTableViewController.isHidden = false
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.gameListTableViewController.isHidden = true
            }
        }
    }
    
    @IBAction func timeSelectorButtonPressed(_ sender: Any) {
        //生成DatePicker
        let datePicker: UIDatePicker = UIDatePicker()
        //調整時區
        datePicker.datePickerMode = .dateAndTime
        //設置語言
        datePicker.locale = Locale(identifier: "zh_TW")
        //datePicker.timeZone = NSTimeZone.local
        datePicker.minimumDate = Date().self
        datePicker.maximumDate = Date().addingTimeInterval(60 * 60 * 24 * 90)
        //生成alert
        let dateSelectorAlert = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        dateSelectorAlert.view.addSubview(datePicker)
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.default, handler: nil)
        let selectAction = UIAlertAction(title: "確認", style: UIAlertAction.Style.default, handler: { _ in
            
            let dateValue = DateFormatter()
            // 設定要顯示在Text Field的日期時間格式
            dateValue.dateFormat = "yyyy-MM-dd HH:mm"
            let buttonText: String = dateValue.string(from: datePicker.date)
            self.dateSelectorText.setTitle(buttonText, for: .normal)
            
        })
        dateSelectorAlert.addAction(selectAction)
        dateSelectorAlert.addAction(cancelAction)
        present(dateSelectorAlert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func numberOfMemberSelectorButtonPressed(_ sender: Any) {
        let groupMemberAlert = UIAlertController(title: "選擇揪團成員人數", message: "\n\n\n\n\n\n", preferredStyle: UIAlertController.Style.alert)
        groupMemberAlert.isModalInPopover = true
        
        let groupMemberPickerView: UIPickerView = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
        groupMemberAlert.view.addSubview(groupMemberPickerView)
        groupMemberPickerView.delegate = self
        groupMemberPickerView.dataSource = self
        groupMemberAlert.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
        groupMemberAlert.addAction(UIAlertAction(title: "確認", style: .default, handler: { (UIAlertAction) in
            self.groupMemberSelectorText.setTitle("\(self.groupMemberString)", for: .normal)
        }))
        self.present(groupMemberAlert ,animated: true, completion: nil)
    }
    
    
    @IBAction func createGroupButtonPressed(_ sender: Any) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let groupAutoIDRef = Database.database().reference(withPath: "groups").childByAutoId()
        if self.inputGroupTitle.text != "" {
            if self.dateSelectorText.currentTitle != "選擇時間" {
                if self.groupMemberSelectorText.currentTitle != "選擇人數" && self.groupMemberSelectorText.currentTitle != "" {
                    if self.gameSelectorText.currentTitle != "選擇遊戲" {
                        let groupValueDict: [String:Any] = ["groupTitle": self.inputGroupTitle.text!,"gameTitle": self.gameSelectorText.currentTitle!, "groupOwner": userID, "groupActivityTime": self.dateSelectorText.currentTitle!, "maxNumberOfMemberInGroup": self.groupMemberSelectorText.currentTitle!]
                            groupAutoIDRef.setValue(groupValueDict)
                            //將創建人儲存至目前揪團成員
                            let currentMemberRef = groupAutoIDRef.child("currentMemberInGroup")
                            let currentMemberDict: [String: Any] = ["0": userID]
                            currentMemberRef.setValue(currentMemberDict)
                            //創建完之後跳轉畫面至揪團首頁
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let groupView = storyboard.instantiateViewController(withIdentifier: "GroupListTabBarView")
                            appDelegate.window?.rootViewController = groupView
                            appDelegate.window?.makeKeyAndVisible()
                    } else {
                        let alert = UIAlertController(title: "發生錯誤", message: "請選擇遊戲", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true)
                        
                    }
                } else {
                    let alert = UIAlertController(title: "發生錯誤", message: "請選擇有效的揪團成員人數", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            } else {
                let alert = UIAlertController(title: "發生錯誤", message: "請選擇有效的活動日期", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        } else {
         let alert = UIAlertController(title: "發生錯誤", message: "請輸入有效的揪團名稱", preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
             self.present(alert, animated: true)
        }
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return groupMemberArrayForPickerView.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return groupMemberArrayForPickerView[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        groupMemberString = groupMemberArrayForPickerView[row]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! GroupCreatorTableViewCell
        cell.gameListText.text = gameListArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.gameSelectorText.setTitle(gameListArray[indexPath.row], for: .normal)
        
        UIView.animate(withDuration: 0.3) {
            self.gameListTableViewController.isHidden = true
        }
    }
    
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
}


