//
//  WSMateBallView.swift
//  WSLMateBall
//
//  Created by WS on 2017/7/27.
//  Copyright © 2017年 WS. All rights reserved.
//

import UIKit
import GLKit

class WSMateBallView: UIView {
    
    public var position: GLKVector2!
    public var itemSize: CGFloat!
    public var edge: GLKVector2?
    public var tracked: Bool = false
    public var direction: GLKVector2?
    
    private var onView: UIView!

    
//MARK:- cycle life
    init(atPosition: GLKVector2, size: CGFloat, superView: UIView) {
        super.init(frame: .zero)
        position = atPosition
        itemSize = size
        onView = superView
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
