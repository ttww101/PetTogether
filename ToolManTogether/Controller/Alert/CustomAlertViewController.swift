//
//  CustomAlertViewController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/10/8.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import Lottie

class CustomAlertViewController: UIViewController {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var aniView: UIView!
    
    let animationView = LOTAnimationView(name: "animation-done-new")

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isOpaque = false
        self.view.backgroundColor = .clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animationView.frame = aniView.frame
        animationView.center = aniView.center
        animationView.contentMode = .scaleAspectFill
        bgView.addSubview(animationView)
        animationView.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.dismiss(animated: true)
        }
    }
}
