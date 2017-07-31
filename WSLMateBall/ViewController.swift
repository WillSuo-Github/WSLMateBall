//
//  ViewController.swift
//  WSLMateBall
//
//  Created by WS on 2017/7/27.
//  Copyright © 2017年 WS. All rights reserved.
//

import UIKit
import GLKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let ballView = WSLMateBall.shared
        ballView.frame = self.view.bounds
        self.view.addSubview(ballView)
        WSLMateBall.shared.addMetaball(atPosition: GLKVector2Make(100, 100), size: 40, onView: UIApplication.shared.keyWindow!)
        
        WSLMateBall.shared.addMetaball(atPosition: GLKVector2Make(200, 100), size: 40, onView: UIApplication.shared.keyWindow!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


}

