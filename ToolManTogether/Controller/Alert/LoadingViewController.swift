//
//  LoadingViewController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/10/14.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import Lottie


class LoadingViewController: UIViewController {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var aniView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isOpaque = false
        self.view.backgroundColor = .clear
        let animationView = LOTAnimationView(name: "material_wave_loading")
        animationView.frame = aniView.frame
        animationView.center = aniView.center
        animationView.contentMode = .scaleAspectFill
        bgView.addSubview(animationView)
        animationView.play()
    }
}
