//
//  ScoreViewController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/30.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController {
    
    
    @IBOutlet weak var dialogView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let angle: CGFloat = -100 * .pi / 180
        var rotationTransform = CATransform3DMakeRotation(angle, 0, 1, 0)
        rotationTransform.m34 = -1.0/1000
        
        var translationTransform = CATransform3DMakeTranslation(80, 200, 0)
        translationTransform.m34 = -1.0/2500
        
        let transform = CATransform3DConcat(rotationTransform, translationTransform)
        
        dialogView.layer.transform = transform
        dialogView.alpha = 0
        
        let animator = UIViewPropertyAnimator(duration: 0.8, dampingRatio: 0.7) {
            
            self.dialogView.transform = .identity
            self.dialogView.alpha = 1
        }
        
        animator.startAnimation()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    @IBAction func submitPressed(_ sender: Any) {
        print("發送評分")
    }
    



}
