//
//  AppDelegateWindow.swift
//  WSLMateBall
//
//  Created by WS on 2017/7/28.
//  Copyright © 2017年 WS. All rights reserved.
//

import UIKit

class AppDelegateWindow: UIWindow {

//    override func draw(_ rect: CGRect) {
//        
//        
//    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        WSLMateBall.shared.updateMetaball(touches)
        
        WSLMateBall.shared.drawMetaBall()
        self.setNeedsDisplay()
    }
}
