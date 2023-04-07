//
//  LocationAddViewController.swift
//  TakeCare
//
//  Created by Lim on 31/07/2019.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit
import GoogleMaps
import EasyTipView
import RealmSwift

class LocationAddViewController: UIViewController {
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var searchTextField: CustomTextField!
    @IBOutlet weak var searchIconImageView: UIImageView!
    @IBOutlet weak var settingNameCloseButton: UIButton!
    @IBOutlet weak var settingNameTextField: CustomTextField!
    @IBOutlet weak var settingNameIconImageView: UIImageView!
    @IBOutlet weak var settingNameTextFieldRightMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var settingBoxHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    
    var marker = GMSMarker()
    var settingPosition: CLLocationCoordinate2D?
    
    var addressTextFieldTipView: EasyTipView? = nil
    var settingNameTextFieldTipView: EasyTipView? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.3) {
            if getTipViewOpenFlag(keyName: .locationAddViewTipFlag) == false {
                if self.addressTextFieldTipView == nil {
                    self.addressTextFieldTipView = EasyTipView(text: "주소를 검색하거나, 지도 핀을 움직여\n원하는 위치를 설정해 보세요.", preferences: EasyTipView.globalPreferences, delegate: self)
                    self.addressTextFieldTipView?.show(animated: true, forView:  self.searchTextField, withinSuperview: self.view)
                }
                
                if self.settingNameTextFieldTipView == nil {
                    self.settingNameTextFieldTipView = EasyTipView(text: "지도 핀 위치에 대한 주소 정보예요.\n등록시 위치에 대한 이름으로 설정되고,\n수정이 가능해요.", preferences: EasyTipView.globalPreferences, delegate: self)
                    self.settingNameTextFieldTipView?.show(animated: true, forView:  self.settingNameTextField, withinSuperview: self.view)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        backButton.setImage(globalBackBtImage, for: .normal)
        backButton.tintColor       = AppColorList().naviTitleColor
        backButton.imageEdgeInsets = globalBackBtEdgeInsets
        titleLabel.font = UIFont(fontsStyle: .regular, size: 18.0)
        searchTextField.font = UIFont(fontsStyle: .regular, size: 14.0)
        settingNameTextField.font = UIFont(fontsStyle: .regular, size: 14.0)
        
        saveButton.setIcon(icon: .googleMaterialDesign(.check), iconSize: 25, color: AppColorList().naviTitleColor, forState: .normal)
        settingNameCloseButton.setIcon(icon: .googleMaterialDesign(.keyboardHide), iconSize: 25, color: AppColorList().greenCustomColor, forState: .normal)
        
        searchIconImageView.image = UIImage.init(icon: .googleMaterialDesign(.search), size: searchIconImageView.frame.size, textColor: AppColorList().textColorDarkGray, backgroundColor: .clear)
        settingNameIconImageView.image = UIImage.init(icon: .fontAwesomeSolid(.mapPin), size: settingNameIconImageView.frame.size, textColor: AppColorList().greenCustomColor, backgroundColor: .clear)
        
        searchTextField.setBorderRadius(width: 1, color: AppColorList().lineClearColor, radius: 20)
        settingNameTextField.setBorderRadius(width: 1, color: AppColorList().lineClearColor, radius: 20)

        AppInfoManager.shared.getUserLocation { (success) in
            if success {
                DLog("위치정보 가져오기 성공!!!")
            } else {
                DLog("위치정보 가져오기 실패!!!")
                toastView(view: self.view, message: "위치를 가져오는데 실패하였습니다.\n기본 설정된 설정값을 사용합니다.", duration: 3.0, position: .bottom, title: nil)
            }
            let position = AppInfoManager.shared.currentLocation
            // Creates a marker in the center of the map.
            self.marker.appearAnimation = .pop
            self.marker.isDraggable = true
            self.marker.isFlat = true
            self.marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            self.marker.icon = UIImage.init(icon: .fontAwesomeSolid(.mapPin), size: CGSize(width: 50.0, height: 50.0), textColor: AppColorList().greenCustomColor, backgroundColor: .clear)
            self.marker.map = self.mapView
            self.setMarker(location: position, address: "")
        }
        AnalyticsManager.shared.screenName(screenName: "위치 등록 화면", screenClass: "LocationAddView")
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            DLog("keyboardHeight : \(keyboardHeight)")
            
            if settingNameTextField.isFirstResponder {
                settingBoxHeightConstraint.constant = keyboardHeight + 60.0
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
            searchIconImageView.image = UIImage.init(icon: .fontAwesomeSolid(.search), size: searchIconImageView.frame.size, textColor: AppColorList().textColorDarkGray, backgroundColor: .clear)
            settingNameIconImageView.image = UIImage.init(icon: .fontAwesomeSolid(.mapPin), size: settingNameIconImageView.frame.size, textColor: AppColorList().greenCustomColor, backgroundColor: .clear)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        let realm: Realm = try! Realm()
        let locationSettingInfo = RLMLocationSettingInfo()
        locationSettingInfo.idx = locationSettingInfo.autoIncrementID()
        locationSettingInfo.selectedFlag = false
        locationSettingInfo.wgs84Lat = 0.0
        locationSettingInfo.wgs84Lon = 0.0
        locationSettingInfo.addressName = settingNameTextField.text ?? ""
        if let settingLoaction = settingPosition {
            locationSettingInfo.wgs84Lat = settingLoaction.latitude
            locationSettingInfo.wgs84Lon = settingLoaction.longitude
        }
        locationSettingInfo.regDate = Date()
        
        try! realm.write {
           realm.add(locationSettingInfo, update: .all)
        }
        
        toastView(view: self.navigationController!.view, message: "위치가 등록 되었습니다.", position: .bottom, title: nil)
        AnalyticsManager.shared.eventLoging(logType: .select_content, itemID: "LcationAdd", itemName: "위치등록", contentType: "Add")
        self.backView(backButton)
    }
    
    @IBAction func closeTextViewBtn(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
       
        settingNameCloseButton.isHidden = true
        if button == settingNameCloseButton {
            settingNameTextFieldRightMarginConstraint.constant = 10
            settingBoxHeightConstraint.constant = 60.0
        }
        closeKeyBoard()
    }
    
    @IBAction func backView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension LocationAddViewController: UITextFieldDelegate {
    
    func closeKeyBoard() {
        searchTextField.resignFirstResponder()
        settingNameTextField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if searchTextField == textField {
            let searchView = self.storyboard?.instantiateViewController(withIdentifier: "AddressSearchViewControllerSID") as! AddressSearchViewController
            searchView.ower = self
            self.navigationController?.pushViewController(searchView, animated: true)
            searchTextField.resignFirstResponder()
        } else if settingNameTextField == textField {
            settingNameTextFieldRightMarginConstraint.constant = (settingNameCloseButton.frame.size.width + 20.0)
            settingNameCloseButton.isHidden = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        settingNameCloseButton.isHidden = true
        if searchTextField == textField {
        } else if settingNameTextField == textField {
            settingNameTextFieldRightMarginConstraint.constant = 10
            settingBoxHeightConstraint.constant = 60.0
        }
        
        closeKeyBoard()
        return true
    }
}

extension LocationAddViewController: GMSMapViewDelegate {
    func setMarker(location: CLLocationCoordinate2D, address: String) {
        self.marker.position = location
        self.settingPosition = marker.position
        self.mapView.animate(to: GMSCameraPosition.camera(withLatitude: self.marker.position.latitude, longitude: self.marker.position.longitude, zoom: 18.0))
        self.settingNameTextField.text = address
        if address == "" {
            AppInfoManager.shared.getLocationAddress(location: marker.position, locationCompleteBlock: { (address) in
                self.settingNameTextField.text = address
            })
        }
    }
    
    func moveMarker (marker: GMSMarker) {
        self.mapView.animate(toLocation: marker.position)
        // self.mapView.animate(to: GMSCameraPosition.camera(withLatitude: marker.position.latitude, longitude: marker.position.longitude, zoom: 14.0))
        AppInfoManager.shared.getLocationAddress(location: marker.position, locationCompleteBlock: { (address) in
            self.settingNameTextField.text = address
            self.settingPosition = marker.position
        })
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        if self.marker == marker {
            moveMarker(marker: marker)
        }
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        // self.marker.position = coordinate
        // moveMarker(marker: self.marker)
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.marker.position = coordinate
        moveMarker(marker: self.marker)
    }
}

extension LocationAddViewController: EasyTipViewDelegate {
    func easyTipViewDidTap(_ tipView: EasyTipView) {

    }

    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        DLog("\(tipView) did dismiss!")
        addressTextFieldTipView?.dismiss {
            self.addressTextFieldTipView = nil
        }
        settingNameTextFieldTipView?.dismiss(withCompletion: {
            self.settingNameTextFieldTipView = nil
        })
        // 팝업을 열지 않는다...
        saveTipViewOpenFlag(keyName: .locationAddViewTipFlag, flag: true)
    }
}
