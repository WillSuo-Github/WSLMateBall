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
        view.backgroundColor = .white
        
        let ballView = WSLMateBall.shared
        ballView.frame = CGRect(x: 100, y: 100, width: 50, height: 50)
        self.view.addSubview(ballView)
        
        
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 150, y: 200, width: 44, height: 44)
        btn.setTitle("start", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        btn.addTarget(self, action: #selector(startButtonDidTapped), for: .touchUpInside)
        self.view.addSubview(btn)
        
        let endBtn = UIButton(type: .custom)
        endBtn.frame = CGRect(x: 260, y: 200, width: 44, height: 44)
        endBtn.setTitle("end", for: .normal)
        endBtn.setTitleColor(.blue, for: .normal)
        endBtn.addTarget(self, action: #selector(endButtonDidTapped), for: .touchUpInside)
        self.view.addSubview(endBtn)
    }
    
    
//MARK:- tapped response
    @objc private func startButtonDidTapped() {
        
        WSLMateBall.shared.addBubble()
    }
    
    @objc private func endButtonDidTapped() {
        
        WSLMateBall.shared.reduceBubble()
    }
    


}

