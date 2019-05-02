//
//  AddTaskTypeCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/21.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AddTaskTypeCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var myRef: DatabaseReference!
    var typeTxtArray: [String] = []
    var typeColorArray: [String] = []
    var typeTitleCompletion: ((_ data: String) -> Void)?
    var typeBtnPressed = false
    var checkType: String!
    var checkBool = false
    var checkIndex: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let cellNib = UINib(nibName: "AddTaskTypeCollectionViewCell", bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: "addTaskTypeCollectionCell")
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.collectionViewLayout = flowLayout
        
        myRef = Database.database().reference()
        getDataBaseType()
        
        let claneDataNotification = Notification.Name("addTask")
        NotificationCenter.default.addObserver(self, selector: #selector(self.cleanData), name: claneDataNotification, object: nil)
    }
    
    func getDataBaseType() {
        myRef.child("TaskType").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [String: String] else { return }
            let sortValue = value.sorted(by: { (firstDictionary, secondDictionary) -> Bool in
                return firstDictionary.0 > secondDictionary.0
            })
            for (keys, value) in sortValue {
                self.typeTxtArray.append(keys)
                self.typeColorArray.append(value)
            }
            self.collectionView.reloadData()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return typeTxtArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addTaskTypeCollectionCell", for: indexPath) as? AddTaskTypeCollectionViewCell {
        
            cell.typeButton.isEnabled = false
            if typeTxtArray.count != 0 {

                cell.typeButton.setTitle(typeTxtArray[indexPath.row], for: .normal)
                cell.typeButton.backgroundColor = #colorLiteral(red: 0.768627451, green: 0.768627451, blue: 0.768627451, alpha: 1)
                cell.typeButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            }
            
            cell.typeButton.addTarget(self, action: #selector(typeButtonPressed(button:)), for: .touchUpInside)
            
            if cell.typeButton.titleLabel!.text! == checkType {
                print(cell.typeButton.titleLabel!.text!)
                cell.typeButton.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.7176470588, blue: 0, alpha: 1)
                cell.typeButton.layer.borderWidth = 0
                cell.typeButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)

            } else {
                print(cell.typeButton.titleLabel!.text!)

                cell.typeButton.backgroundColor = #colorLiteral(red: 0.768627451, green: 0.768627451, blue: 0.768627451, alpha: 1)
                cell.typeButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            }
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print(indexPath.row)
        print(checkIndex)
        if let selectedCell: AddTaskTypeCollectionViewCell = cell as? AddTaskTypeCollectionViewCell {
            
            if indexPath.row == checkIndex {
                selectedCell.typeButton.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.7176470588, blue: 0, alpha: 1)
                selectedCell.typeButton.layer.borderWidth = 0
                selectedCell.typeButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            } else {
                selectedCell.typeButton.backgroundColor = #colorLiteral(red: 0.768627451, green: 0.768627451, blue: 0.768627451, alpha: 1)
                selectedCell.typeButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectType = typeTxtArray[indexPath.row]
        checkType = selectType
        checkIndex = indexPath.row
        print(selectType)
        typeTitleCompletion?(selectType)
        if let selectedCell: AddTaskTypeCollectionViewCell = (collectionView.cellForItem(at: indexPath)! as? AddTaskTypeCollectionViewCell) {

            selectedCell.typeButton.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.7176470588, blue: 0, alpha: 1)
            selectedCell.typeButton.layer.borderWidth = 0
            selectedCell.typeButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let selectedCell: AddTaskTypeCollectionViewCell = (collectionView.cellForItem(at: indexPath) as? AddTaskTypeCollectionViewCell) {
            
            selectedCell.typeButton.backgroundColor = #colorLiteral(red: 0.768627451, green: 0.768627451, blue: 0.768627451, alpha: 1)
            selectedCell.typeButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        }
    }

    @objc func cleanData() {
        collectionView.reloadData()
    }
    
    @objc func typeButtonPressed(button: UIButton) {
        if let typeButtonTxt = button.titleLabel?.text  {
            typeTitleCompletion?(typeButtonTxt)
           
            print(button.tag)
            print(typeButtonTxt)
        } else {
            typeTitleCompletion?("Type Button 無資料")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 137, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
