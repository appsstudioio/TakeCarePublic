//
//  ChildEditingViewController.swift
//  TakeCare
//
//  Created by Lim on 2019/11/27.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit
import RealmSwift

class ChildEditingViewController: UIViewController {
    enum EditingType {
        case write, modify
    }
    @IBOutlet weak var conentBoxView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel1: UILabel!
    @IBOutlet weak var subTitleLabel2: UILabel!
    @IBOutlet weak var subTitleLabel3: UILabel!
    @IBOutlet weak var helpMessageLabel: UILabel!
    
    @IBOutlet weak var nameBoxView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var birthdayBoxView: UIView!
    @IBOutlet weak var birthdayTextField: UITextField!
    
    @IBOutlet weak var boySelectButton: UIButton!
    @IBOutlet weak var girlSelectButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    var childInfo: RLMChildInfo?
    var editMode: EditingType?
    var birdayDate: Date?
    weak var parentVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        AnalyticsManager.shared.screenName(screenName: "아이정보등록화면", screenClass: "ChildEditingView")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isBeingPresented || isMovingToParent {
            // Something
            updateUI()
        }
    }
    
    func setupUI() {
        titleLabel.font        = UIFont(fontsStyle: .regular, size: 16)
        subTitleLabel1.font    = UIFont(fontsStyle: .regular, size: 12)
        subTitleLabel2.font    = UIFont(fontsStyle: .regular, size: 12)
        subTitleLabel3.font    = UIFont(fontsStyle: .regular, size: 12)
        helpMessageLabel.font  = UIFont(fontsStyle: .regular, size: 8)
        nameTextField.font     = UIFont(fontsStyle: .regular, size: 12)
        birthdayTextField.font = UIFont(fontsStyle: .regular, size: 12)
        
        boySelectButton.titleLabel?.font   = UIFont(fontsStyle: .regular, size: 12)
        girlSelectButton.titleLabel?.font  = UIFont(fontsStyle: .regular, size: 12)
        doneButton.titleLabel?.font        = UIFont(fontsStyle: .regular, size: 15)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onSelectBirthday(_:)))
        birthdayTextField.addGestureRecognizer(tapGesture)
        
        if self.editMode == .write {
            sexSelectBtn(boySelectButton)
            childInfo = RLMChildInfo()
            birdayDate = Date()
        } else if self.editMode == .modify {
            if let data = childInfo {
                nameTextField.text = data.name
                birdayDate = data.birthday
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy년 MM월 dd일"
                self.birthdayTextField.text = dateFormatter.string(from: data.birthday)
                sexSelectBtn((data.sex == 0 ? boySelectButton : girlSelectButton) as Any)
            }
        }
    }
    
    func updateUI() {
        conentBoxView.setBorderRadius(width: 1, color: AppColorList().lineClearColor, radius: 10)
        nameBoxView.setBorderRadius(width: 1, color: AppColorList().textColorLightGray, radius: 0)
        birthdayBoxView.setBorderRadius(width: 1, color: AppColorList().textColorLightGray, radius: 0)
        closeButton.setIcon(icon: .googleMaterialDesign(.close), iconSize: 40, color: .white, forState: .normal)
        
        boySelectButton.setBorderRadius(width: 1, color: AppColorList().textColorLightGray, radius: 0)
        girlSelectButton.setBorderRadius(width: 1, color: AppColorList().textColorLightGray, radius: 0)
        boySelectButton.backgroundColor = .clear
        girlSelectButton.backgroundColor = .clear
        if boySelectButton.isSelected == true {
            boySelectButton.setBorderRadius(width: 1, color: AppColorList().boyMainColor, radius: 0)
            boySelectButton.backgroundColor = AppColorList().boyMainColor
        } else if girlSelectButton.isSelected == true {
            girlSelectButton.setBorderRadius(width: 1, color: AppColorList().girlMainColor, radius: 0)
            girlSelectButton.backgroundColor = AppColorList().girlMainColor
        }
        
        if self.editMode == .write {
            titleLabel.text = "아이 정보 등록"
            doneButton.setTitle("추가하기", for: .normal)
            doneButton.setTitleColor(AppColorList().weatherTempMinColor, for: .normal)
            doneButton.tintColor = AppColorList().weatherTempMinColor
            doneButton.setImage(UIImage.init(icon: .googleMaterialDesign(.add), size: CGSize(width: 25, height: 25), textColor:AppColorList().weatherTempMinColor, backgroundColor: .clear), for: .normal)
        } else if self.editMode == .modify {
            titleLabel.text = "아이 정보 수정"
            doneButton.tintColor = AppColorList().greenColor
            doneButton.setTitleColor(AppColorList().greenColor, for: .normal)
            doneButton.setTitle("수정하기", for: .normal)
            doneButton.setImage(UIImage.init(icon: .googleMaterialDesign(.edit), size: CGSize(width: 25, height: 25), textColor:AppColorList().greenColor, backgroundColor: .clear), for: .normal)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
       // Trait collection has already changed
        if #available(iOS 12.0, *) {
            let userInterfaceStyle = self.traitCollection.userInterfaceStyle
            if userInterfaceStyle == .dark {
                DLog("===== Dark Mode")
            } else {
                DLog("===== \(userInterfaceStyle.rawValue) Mode")
            }
            updateUI()
        }
    }
    
    @IBAction func closeBtn(_ sender: Any) {
        closeKeyBoard()
        self.dismiss(animated: true)
    }
    
    @IBAction func doneBtn(_ sender: Any) {
        closeKeyBoard()
        guard nameTextField.text != "" && birdayDate != nil else {
            toastView(view: self.view, message: "이름 및 생년월일을 입력해주세요.", duration: 3.0, position: .bottom, title: nil)
            return
        }
        
        let realm: Realm = try! Realm()
        guard let childInfo = self.childInfo else { return }

        if self.editMode == .write {
            childInfo.idx = childInfo.autoIncrementID()
            childInfo.height = 0.0
            childInfo.weight = 0.0
            childInfo.name = nameTextField.text ?? ""
            childInfo.sex = (boySelectButton.isSelected ? 0 : 1)
            childInfo.birthday = birdayDate!
            let childInfoList = realm.objects(RLMChildInfo.self).sorted(byKeyPath: "idx", ascending: true)
            if childInfoList.count == 0 {
                childInfo.mainFlag = true
            } else {
                childInfo.mainFlag = false
            }
            try! realm.write {
               realm.add(childInfo, update: .all)
            }
            AnalyticsManager.shared.eventLoging(logType: .select_content, itemID: "ChildAdd", itemName: "아이등록", contentType: "Add")
        } else if self.editMode == .modify{
            try! realm.write {
                childInfo.name = nameTextField.text ?? ""
                childInfo.sex = (boySelectButton.isSelected ? 0 : 1)
                childInfo.birthday = birdayDate!
            }
            AnalyticsManager.shared.eventLoging(logType: .select_content, itemID: "ChildModify", itemName: "아이수정", contentType: "Modify")
        }
        
        // 예방접종 일정 업데이트
        childVcnScheduleUpdate(child: childInfo)
        
        if let parent = self.parentVC as? ChildSettingViewController {
            parent.reloadData()
            toastView(view: parent.view, message: (self.editMode == .write ? "등록 되었습니다." : "수정 되었습니다." ), position: .bottom, title: nil)
        }
        
        self.dismiss(animated: true)
    }
    
    @IBAction func sexSelectBtn(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        boySelectButton.isSelected = false
        girlSelectButton.isSelected = false
        if button == boySelectButton {
            boySelectButton.isSelected = true
        } else if button == girlSelectButton {
            girlSelectButton.isSelected = true
        }
        updateUI()
    }
}

extension ChildEditingViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = event?.allTouches?.first else {
            return
        }
        
        if (touch.view != nameTextField && touch.view != birthdayTextField) && (nameTextField.isFirstResponder || birthdayTextField.isFirstResponder) {
            // 키보드 활성시 다른 뷰를 터치하면 키보드 가림
            closeKeyBoard()
        }
        
        super.touchesBegan(touches, with: event)
    }
}

extension ChildEditingViewController: UITextFieldDelegate {
    func selectBirthday() {
        let alert = UIAlertController(title: nil, message: "생일을 선택하세요.", preferredStyle: .actionSheet)
        alert.addDatePicker(mode: .date, date: (birdayDate == nil ? Date() : birdayDate!), minimumDate: nil, maximumDate: Date()) { date in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 MM월 dd일"
            self.birthdayTextField.text = dateFormatter.string(from: date)
            self.birdayDate = date
        }
        alert.addAction(title: "확인", style: .cancel , handler:{ (UIAlertAction) in
            self.closeKeyBoard()
        })
        self.present(alert, animated: true, completion:nil)
    }
    
    func closeKeyBoard() {
        self.view.endEditing(true)
        nameBoxView.setBorderRadius(width: 1, color: AppColorList().textColorLightGray, radius: 0)
        birthdayBoxView.setBorderRadius(width: 1, color: AppColorList().textColorLightGray, radius: 0)
    }
    
    @objc func onSelectBirthday(_ sender: UITapGestureRecognizer) {
        closeKeyBoard()
        birthdayBoxView.setBorderRadius(width: 1, color: (boySelectButton.isSelected ? AppColorList().boyMainColor : AppColorList().girlMainColor), radius: 0)
        selectBirthday()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            return true
        }
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nameBoxView.setBorderRadius(width: 1, color: AppColorList().textColorLightGray, radius: 0)
        birthdayBoxView.setBorderRadius(width: 1, color: AppColorList().textColorLightGray, radius: 0)

        if textField == nameTextField {
            nameBoxView.setBorderRadius(width: 1, color: (boySelectButton.isSelected ? AppColorList().boyMainColor : AppColorList().girlMainColor), radius: 0)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if nameTextField == textField {

        } else if birthdayTextField == textField {
            
        }
        closeKeyBoard()
        return true
    }
}
