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
class WSLMateBall: UIView {
    
    public var metaBallArr = [WSMateBallView]()
    public var pathRef: CGPath?
    
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
    private let MAXSTEPS = 400
    private let RESOLUTION: CGFloat = 4.0

//MARK:- cycle life
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.saveGState()
        
        context?.clear(rect)
        
        if let path = WSLMateBall.shared.pathRef {
            context?.setLineWidth(2.0)
            UIColor.white.setStroke()
            UIColor.blue.setFill()
            
            context?.addPath(path)
            context?.drawPath(using: .stroke)
        }
        context?.restoreGState()
    }
    
    public func addMetaball(atPosition: GLKVector2, size: CGFloat, onView: UIView) {
        let ballView = WSMateBallView(atPosition: atPosition, size: size, superView: onView)
        metaBallArr.append(ballView)
        self.drawMetaBall()
        
        (UIApplication.shared.keyWindow as! AppDelegateWindow).setNeedsDisplay()
    }

//MARK:- layout
    public func drawMetaBall() {
        minSize = CGFloat.greatestFiniteMagnitude
        
        for ball in metaBallArr {
            minSize = min(minSize, ball.itemSize)
            ball.edge = trackBorder(ball.position)
            ball.tracked = false
        }
        
        var currentMateball = untrackedMetaball()
        guard let mateball = currentMateball else {return}
        let mutablePath = CGMutablePath()
        if var edge = mateball.edge {
            mutablePath.move(to: CGPoint(x: CGFloat(edge.x), y: CGFloat(edge.y)))
            
            var edgeSteps = 0
            while edgeSteps < MAXSTEPS {
                let positionForce = PositionForce(position: edge, force: RESOLUTION)
                edge = rungeKutta2(positionForce)
                edge = stepToBorder(edge).position
                
                mutablePath.addLine(to: CGPoint(x: CGFloat(edge.x), y: CGFloat(edge.y)))
                let previousEdge = GLKVector2Make(edge.x, edge.y)
                
                for ball in metaBallArr {
                    if GLKVector2Distance(ball.edge!, previousEdge) < Float(RESOLUTION * 0.5) {
                        edge = ball.edge!
                        currentMateball?.tracked = true
                        
                        if ball.tracked {
                            currentMateball = untrackedMetaball()
                            if currentMateball != nil {
                                edge = (currentMateball?.edge)!
                                mutablePath.move(to: CGPoint(x: CGFloat(edge.x), y: CGFloat(edge.y)))
                            }
                        }else{
                            currentMateball = ball
                        }
                    }
                }
                edgeSteps += 1
            }
        }
        
        pathRef = mutablePath.copy()
    }
    
//MARK:- tapped response
    func updateMetaball(_ touches: [UITouch]) {
        
        var trackedTouches = touches
        
        for moveBall in metaBallArr {
            var shortestDistanceToMetaballs = CGFloat.greatestFiniteMagnitude
            var distanceToCurrentMetaball = CGFloat.greatestFiniteMagnitude
            var matchingTouch: UITouch?
            var moveball = moveBall
            
            for currentBall in metaBallArr {
                
                if trackedTouches.count > 0 {
                    for touch in trackedTouches {
                        
                        let location = touch.location(in: self)
                        let distance = GLKVector2Distance(currentBall.position, GLKVector2Make(Float(location.x), Float(location.y)))
                        if distance < Float(distanceToCurrentMetaball) {
                            distanceToCurrentMetaball = CGFloat(distance)
                            matchingTouch = touch
                        }
                    }
                    
                    if distanceToCurrentMetaball < shortestDistanceToMetaballs {
                        shortestDistanceToMetaballs = distanceToCurrentMetaball
                        moveball = currentBall
                    }
                }
            }
            
            let movePoint = matchingTouch?.location(in: self)
            moveball.position = GLKVector2Make(Float(movePoint.x), Float(movePoint.y))
//            trackedTouches.remove(at: <#T##Int#>)
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        WSLMateBall.shared.updateMetaball(CGPoint(x: 100, y: 100))
        
        WSLMateBall.shared.drawMetaBall()
        self.setNeedsDisplay()
    }

    
//MARK:- other
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
    
    private func rungeKutta2(_ positionForce: PositionForce) -> GLKVector2 {
        let normal = calculateNormal(positionForce.position)
        let t1 = GLKVector2Make(Float(CGFloat(normal.y) * RESOLUTION * -0.5), Float(CGFloat(normal.x) * RESOLUTION * 0.5))
        
        let normal2 = calculateNormal(GLKVector2Add(positionForce.position, t1))
        let t2 = GLKVector2Make(Float(CGFloat(normal2.y) * RESOLUTION * -1), Float(CGFloat(normal2.x) * RESOLUTION))
        
        return GLKVector2Add(positionForce.position, t2)
    }
}

