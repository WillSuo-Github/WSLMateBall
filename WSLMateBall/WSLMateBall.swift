//
//  WSLMateBall.swift
//  WSLMateBall
//
//  Created by WS on 2017/7/27.
//  Copyright © 2017年 WS. All rights reserved.
//

import UIKit
import GLKit
import CoreGraphics

private let sharedInstance = WSLMateBall()
class WSLMateBall: NSObject {
    
    public var metaBallArr = [WSMateBallView]()
    
    struct PositionForce {
        var position: GLKVector2
        var force: CGFloat
    }

    public class var shared: WSLMateBall {
        return sharedInstance
    }
    
    private var minSize: CGFloat = CGFloat.greatestFiniteMagnitude
    private let THRESHOLD: CGFloat = 0.0004
    private let GOOIENESS: CGFloat = 2.7
    
    override init() {
        super.init()
        
    }
    
    public func addMetaball(atPosition: GLKVector2, size: CGFloat, onView: UIView) {
        let ballView = WSMateBallView(atPosition: atPosition, size: size, superView: onView)
        metaBallArr.append(ballView)
        self.drawMetaBall()
    }
    
    private func drawMetaBall() {
        minSize = CGFloat.greatestFiniteMagnitude
        
        for ball in metaBallArr {
            minSize = min(minSize, ball.itemSize)
            ball.edge = trackBorder(ball.position)
            ball.tracked = false
        }
        
        let currentMateball = untrackedMetaball()
        guard let mateball = currentMateball else {return}
        let mutablePath = CGMutablePath()
        if let edge = mateball.edge {
            mutablePath.move(to: CGPoint(x: edge.x, y: edge.y))
        }

    }
    
    private func trackBorder(_ position: GLKVector2) -> GLKVector2 {
        var positionForce: PositionForce = PositionForce(position:GLKVector2Make(position.x, position.y + 1), force:CGFloat.greatestFiniteMagnitude)
        
        var reps = 0
        var previousForce:CGFloat = 0.0
        while fabsf(Float(positionForce.force - previousForce)) > Float.ulpOfOne && positionForce.force > THRESHOLD {
            previousForce = positionForce.force
            positionForce = stepToBorder(positionForce.position)
            reps += 1
        }
        return positionForce.position
    }
    
    private func stepToBorder(_ position: GLKVector2) -> PositionForce {
        let force = calculateForce(position)
        let normal: GLKVector2 = calculateNormal(position)
        let stepSize = powf((Float(minSize / THRESHOLD)), Float(1.0 / GOOIENESS)) - powf(Float(minSize / force), Float(1.0 / GOOIENESS)) + Float.ulpOfOne
        let positionForce = PositionForce(position: GLKVector2Add(position, GLKVector2MultiplyScalar(normal, stepSize)), force: force)
        return positionForce
    }
    
    private func calculateForce(_ position: GLKVector2) -> CGFloat {
        var force: CGFloat = 0
        for ball in metaBallArr {
            let div: CGFloat = CGFloat(powf(GLKVector2Distance(ball.position, position), Float(GOOIENESS)))
            if div != 0.0 {
                force += ball.itemSize / div
            }else{
                force += 100000
            }
        }
        return force
    }
    
    private func calculateNormal(_ position: GLKVector2) -> GLKVector2 {
        var normal = GLKVector2Make(0, 0)
        for ball in metaBallArr {
            let radius = GLKVector2Subtract(ball.position, position)
            let length = GLKVector2Length(radius)
            if length != 0 {
                let multiply: Float = Float((-1.0) * GOOIENESS * ball.itemSize) / powf(length, Float(2.0 + GOOIENESS))
                normal = GLKVector2Add(normal, GLKVector2MultiplyScalar(radius, multiply))
            }
        }
        return GLKVector2Normalize(normal)
    }
    
    private func untrackedMetaball() -> WSMateBallView? {
        var index = NSNotFound
        for (idx, ball) in metaBallArr.enumerated() {
            if !ball.tracked {
                index = idx
                break
            }
        }
        
        if index != NSNotFound {
            return metaBallArr[index]
        }else{
            return nil
        }
    }
}

