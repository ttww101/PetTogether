//
//  HomeViewController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/20.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import FirebaseDatabase
import MapKit
import CoreLocation
import FirebaseAuth
import FirebaseStorage
import SDWebImage
import KeychainSwift

class HomeViewController: UIViewController {
    
    @IBOutlet weak var typeCollectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var pullUpDetailView: TaskDetailInfoView!
    
    var myRef: DatabaseReference!
    var typeDic: [String: String] = [:]
    var typeTxtArray: [String] = []
    var typeColorArray: [String] = []
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    var regionRadious: Double = 1000
    var selectTask: UserTask?
    var selectTaskKey: String?
    let screenSize = UIScreen.main.bounds.size
    let loginVC = LoginViewController()
    var techAnnotationArray: [MKAnnotation] = []
    var bugAnnotationArray: [MKAnnotation] = []
    var carryAnnotationArray: [MKAnnotation] = []
    var houseAnnotationArray: [MKAnnotation] = []
    var foodAnnotationArray: [MKAnnotation] = []
    var otherAnnotationArray: [MKAnnotation] = []
    var trafficAnnotationArray: [MKAnnotation] = []
    var allAnnotationArray: [MKAnnotation] = []
    let keychain = KeychainSwift()
    var isGuest = false
    var allAnnotations: [MKAnnotation] = []
    let decoder = JSONDecoder()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkInternet()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionHeadersPinToVisibleBounds = true
        typeCollectionView.collectionViewLayout = layout
        typeCollectionView.showsHorizontalScrollIndicator = false
        typeCollectionView.delegate = self
        typeCollectionView.dataSource = self
        let cellNib = UINib(nibName: "TypeCollectionViewCell", bundle: nil)
        self.typeCollectionView.register(cellNib, forCellWithReuseIdentifier: "typeCell")
        typeCollectionView.register(cellNib,
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "typeCell")
        myRef = Database.database().reference()
        collectionViewConstraint.constant = 0
        dataBaseTypeAdd()
        dataBaseTaskAdd()
        dataBaseTaskRemove()
        locationButton.layer.cornerRadius = locationButton.frame.width / 2
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationButton.layer.cornerRadius = self.locationButton.frame.width / 2
        locationButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        locationButton.layer.shadowRadius = 3
        locationButton.layer.shadowOpacity = 1
        locationButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        mapView.showsUserLocation = true
        mapView.tintColor = #colorLiteral(red: 0.3450980392, green: 0.768627451, blue: 0.6156862745, alpha: 1)
        configureLocationServices()
        guestMode()
    }
    
    func guestMode() {
        if let value = keychain.get("token") {
            isGuest = false
        } else {
            isGuest = true
        }
    }
    
    func checkInternet() {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
        }else{
            print("Internet Connection not Available!")
            showAlert(title: "網路連線有問題", content: "網路行為異常，請確認您的網路連線狀態或稍後再試。")
        }
    }
    
    func dataBaseTypeAdd() {
        myRef.child("TaskType").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [String: String] else { return }
            let sortValue = value.sorted(by: { (firstDictionary, secondDictionary) -> Bool in
                return firstDictionary.0 > secondDictionary.0
            })
            for (keys, value) in sortValue {
                self.typeTxtArray.append(keys)
                self.typeColorArray.append(value)
            }
            if self.typeTxtArray.count == snapshot.key.count - 1 {
                self.typeCollectionView.reloadData()
                UIView.animate(withDuration: 0.3) {
                    self.collectionViewConstraint.constant = 40
                }
            }
        }
    }
    
    func dataBaseTaskAdd() {
        myRef.child("Task").observe(.childAdded) { (snapshot) in
            guard let value = snapshot.value as? NSDictionary else { return }
            guard let type = value["Type"] as? String else { return }
            guard let taskLat = value["lat"] as? Double else { return }
            guard let taskLon = value["lon"] as? Double else { return }
            self.addMapTaskPoint(taskLat: taskLat, taskLon: taskLon, type: type)
           self.databaseTaskClose(taskKey: snapshot.key)
        }
    }
    
    func dataBaseTaskRemove() {
        myRef.child("Task").observe(.childRemoved) { (snapshot) in
            guard let value = snapshot.value as? NSDictionary else { return }
            guard let taskLat = value["lat"] as? Double else { return }
            guard let taskLon = value["lon"] as? Double else { return }
            self.removeMapTaskPoint(taskLat: taskLat, taskLon: taskLon)
        }
    }
    
    func databaseTaskClose(taskKey: String) {
        myRef.child("Task")
            .child(taskKey).observe(.childRemoved) { (snapshot) in
                
                guard let searchAnnotation = snapshot.value as? String else { return }
                let spliteArray = searchAnnotation.components(separatedBy: "_")
                
                if let taskLat = Double(spliteArray.first!), let taskLon = Double(spliteArray.last!) {
                    self.removeMapTaskPoint(taskLat: taskLat, taskLon: taskLon)
                }
        }
    }
    
    func updataTaskUserPhoto(userID: String) {
        let storageRef = Storage.storage().reference()
        storageRef.child("UserPhoto").child(userID).downloadURL(completion: { (url, error) in
            
            if let error = error {
                print("User photo download Fail: \(error.localizedDescription)")
                self.pullUpDetailView.userPhoto.image = UIImage(named: "profile_sticker_placeholder02")
            }
            
            if let url = url {
                print("url \(url)")
                self.pullUpDetailView.userPhoto.sd_setImage(with: url, completed: nil)
            }
        })
    }
    
    func addMapTaskPoint(taskLat: Double, taskLon: Double, type: String) {
        let taskCoordinate = CLLocationCoordinate2D(latitude: taskLat, longitude: taskLon)
        let annotation = TaskPin(coordinate: taskCoordinate, identifier: "taskPin")
        annotation.title = type
        mapView.addAnnotation(annotation)
        allAnnotations = mapView.annotations
    }
    
    func removeMapTaskPoint(taskLat: Double, taskLon: Double) {
        let taskCoordinate = CLLocationCoordinate2D(latitude: taskLat, longitude: taskLon)
        let allAnnotation = mapView.annotations
        for eachAnnotaion in allAnnotation {
            if eachAnnotaion.coordinate == taskCoordinate {
                self.mapView.removeAnnotation(eachAnnotaion)
                allAnnotations = mapView.annotations
            }
        }
    }
    
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
    func addTap(taskCoordinate: CLLocationCoordinate2D) {
        guestMode()
        let mapTap = UITapGestureRecognizer(target: self, action: #selector(animateViewDown))
        mapView.addGestureRecognizer(mapTap)
        let coordinateRegion = MKCoordinateRegion(
            center: taskCoordinate,
            latitudinalMeters: regionRadious * 0.2,
            longitudinalMeters: regionRadious * 0.2)

        var currentUserID = ""
        if let userID = Auth.auth().currentUser?.uid {
            currentUserID = userID
        }
        
        searchFireBase(child: "Task", byChild: "searchAnnotation",
                       toValue: "\(taskCoordinate.latitude)_\(taskCoordinate.longitude)") { (data) in
            
            for value in data {
                guard let keyValue = value.key as? String else { return }
                let dictionary = value.value
                guard let myLocation = self.locationManager.location else {
                    return
                }
                
                let taskLocation = CLLocation(latitude: taskCoordinate.latitude, longitude: taskCoordinate.longitude)
                let distance = myLocation.distance(from: taskLocation) / 1000
                let roundDistance = round(distance * 100) / 100
                let checkTask = "\(currentUserID)_\(taskCoordinate.latitude)_\(taskCoordinate.longitude)"
                
                guard let taskInfoJSONData = try? JSONSerialization.data(withJSONObject: dictionary) else {
                    return
                }
                
                do {
                    let taskData = try self.decoder.decode(UserTaskInfo.self, from: taskInfoJSONData)
                    self.selectTask = UserTask.init(taskKey: keyValue, checkTask: checkTask, distance: roundDistance, userID: currentUserID, userTaskInfo: taskData)
                    
                } catch {
                    print(error)
                }
                
                guard let data = self.selectTask?.userTaskInfo else { return }
                guard let userData = self.selectTask?.userTaskInfo.userID else { return }
                guard let checkTaskData = self.selectTask?.checkTask else { return }
                self.updataTaskUserPhoto(userID: userData)
                self.pullUpDetailView.taskTitleLabel.text = data.title
                self.pullUpDetailView.taskContentTxtView.text = data.content
                self.pullUpDetailView.priceLabel.text = data.price
                self.pullUpDetailView.userName.text = data.userName
                self.pullUpDetailView.typeLabel.text = data.type
                self.pullUpDetailView.distanceLabel.text = "\(roundDistance)km"
                self.pullUpDetailView.reportBtn.addTarget(self, action: #selector(self.showReportAlert), for: .touchUpInside)

                self.myRef.child("RequestTask")
                    .queryOrdered(byChild: "checkTask").queryEqual(toValue: checkTaskData)
                    .observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        guard snapshot.value as? NSDictionary == nil else {
                            self.pullUpDetailView.sendButton.setTitle("已經申請過", for: .normal)
                            self.pullUpDetailView.sendButton.isEnabled = false
                            self.pullUpDetailView.sendButton.backgroundColor = .white
                            self.pullUpDetailView.sendButton.layer.borderWidth = 1
                            self.pullUpDetailView.sendButton.layer.borderColor = #colorLiteral(red: 0.3490196078, green: 0.2862745098, blue: 0.2470588235, alpha: 1)
                            self.pullUpDetailView.sendButton.setTitleColor(#colorLiteral(red: 0.3490196078, green: 0.2862745098, blue: 0.2470588235, alpha: 1), for: .normal)
                            return
                        }
                    })
                
                        guard self.isGuest == false else {
                            self.pullUpDetailView.sendButton.setTitle("訪客模式無法申請任務", for: .normal)
                            self.pullUpDetailView.sendButton.isEnabled = false
                            self.pullUpDetailView.sendButton.backgroundColor = .white
                            self.pullUpDetailView.sendButton.layer.borderWidth = 1
                            self.pullUpDetailView.sendButton.layer.borderColor = #colorLiteral(red: 0.3490196078, green: 0.2862745098, blue: 0.2470588235, alpha: 1)
                            self.pullUpDetailView.sendButton.setTitleColor(#colorLiteral(red: 0.3490196078, green: 0.2862745098, blue: 0.2470588235, alpha: 1), for: .normal)
                            return
                        }
                
                        if userData == currentUserID {
                            self.pullUpDetailView.sendButton.setTitle("您的任務", for: .normal)
                            self.pullUpDetailView.sendButton.isEnabled = false
                            self.pullUpDetailView.sendButton.backgroundColor = .white
                            self.pullUpDetailView.sendButton.layer.borderWidth = 1
                            self.pullUpDetailView.sendButton.layer.borderColor = #colorLiteral(red: 0.3490196078, green: 0.2862745098, blue: 0.2470588235, alpha: 1)
                            self.pullUpDetailView.sendButton.setTitleColor(#colorLiteral(red: 0.3490196078, green: 0.2862745098, blue: 0.2470588235, alpha: 1), for: .normal)

                        } else {
                            self.pullUpDetailView.sendButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
                            self.pullUpDetailView.sendButton.layer.borderWidth = 0
                            self.pullUpDetailView.sendButton.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.7176470588, blue: 0, alpha: 1)
                            self.pullUpDetailView.sendButton.isEnabled = true
                            self.pullUpDetailView.sendButton.setTitle("申請任務", for: .normal)
                            self.pullUpDetailView.sendButton.addTarget(self,
                                                                       action: #selector(self.requestBtnSend), for: .touchUpInside)
                        }
                    }
                }
        self.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func showAlert() {
        let personAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: "檢舉", style: .destructive) { (void) in
            let reportController = UIAlertController(title: "確定檢舉？", message: "我們會儘快處理", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確定", style: .destructive, handler: nil)
            let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
            reportController.addAction(cancelAction)
            reportController.addAction(okAction)
            self.present(reportController, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        personAlertController.addAction(reportAction)
        personAlertController.addAction(cancelAction)
        self.present(personAlertController, animated: true, completion: nil)
    }
    
    @objc func requestBtnSend() {
        let autoID = myRef.childByAutoId().key
        let userID = Auth.auth().currentUser?.uid
        guard let selectData = selectTask else { return }
        guard let selectDataKey = selectTask?.taskKey else { return }
        
            myRef.child("RequestTask")
                .queryOrdered(byChild: "checkTask").queryEqual(toValue: selectData.checkTask)
                .observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    self.myRef.child("RequestTask").child(autoID!).setValue([
                        "Title": selectData.userTaskInfo.title,
                        "Content": selectData.userTaskInfo.content,
                        "UserName": selectData.userTaskInfo.userName,
                        "UserID": userID!,
                        "Type": selectData.userTaskInfo.type,
                        "Price": selectData.userTaskInfo.price,
                        "Lat": selectData.userTaskInfo.taskLat,
                        "Lon": selectData.userTaskInfo.taskLon,
                        "checkTask": selectData.checkTask,
                        "distance": selectData.distance,
                        "Time": Double(Date().millisecondsSince1970),
                        "ownerID": selectData.userTaskInfo.userID,
                        "OwnerAgree": "waiting",
                        "address": selectData.userTaskInfo.address])
                    
                  self.myRef.child("userAllTask").child(userID!).child(selectDataKey).updateChildValues([
                        "taskKey": selectData.taskKey,
                        "taskTitle": selectData.userTaskInfo.title,
                        "taskOwnerName": selectData.userTaskInfo.userName,
                        "taskOwnerId": selectData.userTaskInfo.userID])
                    
                    self.sendRequestToOwner(taskKey: selectDataKey, distance: selectData.distance, requestTaskID: autoID!)
                    
                    NotificationCenter.default.post(name: .sendRequest, object: nil)
                    
                    let tabController = self.view.window!.rootViewController as? UITabBarController
                    let storyboard = UIStoryboard(name: "cusomeAlert", bundle: nil)
                    let alertVC = storyboard.instantiateViewController(withIdentifier: "cusomeAlert")
                    self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
                    tabController?.show(alertVC, sender: nil)
                    
                    self.animateViewDown()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                        tabController?.selectedIndex = 1
                    }
                
                }) { (error) in
                    print(error.localizedDescription)
        }
    }
    
    func sendRequestToOwner(taskKey: String,
                            distance: Double?,
                            requestTaskID: String) {
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        guard let distance = distance else { return }
        let autoID = myRef.childByAutoId().key
        myRef.child("Task").child(taskKey).child("RequestUser").child(autoID!).updateChildValues([
            "userID": userID,
            "distance": distance,
            "agree": false,
            "RequestTaskID": requestTaskID,
            "taskKey": taskKey])
        
        myRef.child("RequestTask").child(requestTaskID).updateChildValues([
            "requestUserKey": autoID,
            "taskKey": taskKey
            ])
    }
    
    func searchFireBase(
        child: String,
        byChild: String,
        toValue: String,
        success: @escaping (NSDictionary) -> Void) {
    
        myRef.child(child)
            .queryOrdered(byChild: byChild).queryEqual(toValue: toValue)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                guard let data = snapshot.value as? NSDictionary else { return }
                success(data)
            }) { (error) in
                print(error.localizedDescription)
        }
    }
    
    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpDetailView.addGestureRecognizer(swipe)
    }

    func animateViewUp() {
        pullUpViewHeightConstraint.constant = 250
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func animateViewDown() {
        pullUpViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showAlert(title: String = "已申請過此任務", content: String) {
        let alert = UIAlertController(title: title, message: content, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func showReportAlert() {
        let personAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let reportAction = UIAlertAction(title: "檢舉", style: .destructive) { (void) in
            let reportController = UIAlertController(title: "確定檢舉？", message: "我們會儘快處理", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確定", style: .destructive, handler: nil)
            let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
            reportController.addAction(cancelAction)
            reportController.addAction(okAction)
            self.present(reportController, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        personAlertController.addAction(reportAction)
        personAlertController.addAction(cancelAction)
        self.present(personAlertController, animated: true, completion: nil)
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return typeTxtArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "typeCell", for: indexPath) as? TypeCollectionViewCell {

            if typeTxtArray.count != 0 {
                cell.typeLabel.text = typeTxtArray[indexPath.row]
                cell.typeView.backgroundColor = typeColorArray[indexPath.row].color()
            }
            return cell
        }
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 103, height: 40)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind:
        String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let headerCellView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier:
            "typeCell", for: indexPath) as? TypeCollectionViewCell {
            headerCellView.typeLabel.text = "所有任務"
            headerCellView.typeView.backgroundColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerCellTapped))
            headerCellView.addGestureRecognizer(tapGesture)
            return headerCellView
        }
        return UICollectionReusableView()
    }

    
    @objc func headerCellTapped() {
        mapView.removeAnnotations(allAnnotationArray)
        mapView.addAnnotations(allAnnotationArray)
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        mapView.removeAnnotations(allAnnotationArray)
        switch indexPath.row {
        // 科技維修
        case 0:
            mapView.addAnnotations(techAnnotationArray)
            
        // 清除害蟲
        case 1:
            mapView.addAnnotations(bugAnnotationArray)

        // 搬運重物
        case 2:
            mapView.addAnnotations(carryAnnotationArray)
        // 居家維修
        case 3:
            mapView.addAnnotations(houseAnnotationArray)

        // 外送食物
        case 4:
            mapView.addAnnotations(foodAnnotationArray)

        // 其他任務
        case 5:
            mapView.addAnnotations(otherAnnotationArray)

        // 交通接送
        case 6:
            mapView.addAnnotations(trafficAnnotationArray)
        default:
            return
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 103 , height: 40)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

extension HomeViewController: MKMapViewDelegate {
    // To Change the maker view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "taskPin")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "taskPin")
        }
        if annotation is MKUserLocation {
            return nil
        }
        allAnnotationArray.append(annotation)
        switch annotation.title {
        case "搬運重物":
            annotationView?.image = #imageLiteral(resourceName: "yellowPoint")
            carryAnnotationArray.append(annotation)
        case "科技維修":
            annotationView?.image = #imageLiteral(resourceName: "bluePoint")
            techAnnotationArray.append(annotation)
        case "清除害蟲":
            bugAnnotationArray.append(annotation)
            annotationView?.image = #imageLiteral(resourceName: "redPoint")
        case "外送食物":
            foodAnnotationArray.append(annotation)
            annotationView?.image = #imageLiteral(resourceName: "purplePoint")
        case "其他任務":
            otherAnnotationArray.append(annotation)
            annotationView?.image = #imageLiteral(resourceName: "brownPoint")
        case "居家維修":
            houseAnnotationArray.append(annotation)
            annotationView?.image = #imageLiteral(resourceName: "orangePoint")
        case "交通接送":
            trafficAnnotationArray.append(annotation)
            annotationView?.image = #imageLiteral(resourceName: "greenPoint")
        default:
            annotationView?.image = #imageLiteral(resourceName: "yellowPoint")
        }
        annotationView?.canShowCallout = true
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let coordinate = view.annotation?.coordinate else {
            return
        }
        guard coordinate != locationManager.location?.coordinate else {
            return
        }
        addTap(taskCoordinate: coordinate)
        animateViewUp()
        addSwipe()
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        print(mapView.region.span)
        if mapView.region.span.latitudeDelta > 0.06 {
            self.mapView.removeAnnotations(allAnnotations)
            self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            self.navigationItem.title = "請將地圖放大一點🙏"
        } else {
            self.mapView.addAnnotations(allAnnotations)
            self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.9568627451, green: 0.9490196078, blue: 0.9568627451, alpha: 1)
           self.navigationItem.title = "搜尋任務"
        }
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else {
            return
        }
        let coordinateRegion = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: regionRadious * 0.3,
            longitudinalMeters: regionRadious * 0.3)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManager.startUpdatingLocation()
        centerMapOnUserLocation()
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
}

extension String {
    func color() -> UIColor? {
        switch(self){
        case "green":
            return #colorLiteral(red: 0.4274509804, green: 0.8078431373, blue: 0.7568627451, alpha: 1)
        case "brown":
            return #colorLiteral(red: 0.7450980392, green: 0.6588235294, blue: 0.6274509804, alpha: 1)
        case "purple":
            return #colorLiteral(red: 0.7843137255, green: 0.6078431373, blue: 0.8, alpha: 1)
        case "orange":
            return #colorLiteral(red: 0.968627451, green: 0.537254902, blue: 0.2156862745, alpha: 1)
        case "yellow":
            return #colorLiteral(red: 0.9568627451, green: 0.7215686275, blue: 0, alpha: 1)
        case "red":
            return #colorLiteral(red: 0.9411764706, green: 0.4078431373, blue: 0.3019607843, alpha: 1)
        case "blue":
            return #colorLiteral(red: 0.5294117647, green: 0.6352941176, blue: 0.8509803922, alpha: 1)
        default:
            return nil
        }
    }
}

extension CLLocationCoordinate2D: Hashable {
    public var hashValue: Int {
        get {
            let latHash = latitude.hashValue&*123
            let longHash = longitude.hashValue
            return latHash &+ longHash
        }
    }
}

public func ==(mylhs: CLLocationCoordinate2D, myrhs: CLLocationCoordinate2D) -> Bool {
    return mylhs.latitude == myrhs.latitude && mylhs.longitude == myrhs.longitude
}

extension Notification.Name {
    static let sendRequest = Notification.Name("sendRequest")
}
