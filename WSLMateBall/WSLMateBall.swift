//
//  WSLMateBall.swift
//  WSLMateBall
//
//  Created by WS on 2017/7/27.
//  Copyright © 2017年 WS. All rights reserved.
//

import UIKit

private let sharedInstance = WSLMateBall()
class WSLMateBall: UIView {

    
    public class var shared: WSLMateBall {
        return sharedInstance
    }
    
//MARK:- private property
    private var mainBall: CAShapeLayer = CAShapeLayer()

//MARK:- cycle life
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .green
        configSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK:- layout
    override func layoutSubviews() {
        super.layoutSubviews()
        mainBall.path = getMainNoramlPath()
    }
    
    private func configSubviews() {
        mainBall.path = getMainNoramlPath()
        mainBall.fillColor = UIColor.red.cgColor
        self.layer.addSublayer(mainBall)
    }
    
    private func getMainNoramlPath() -> CGPath {
        return UIBezierPath(arcCenter: CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2), radius: self.bounds.size.width / 2, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true).cgPath
    }
    
    private func getMainLargePath() -> CGPath {
        return UIBezierPath(arcCenter: CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2), radius: self.bounds.size.width / 2 + 10, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true).cgPath
    }
    
//    private func getMainBulgePath() -> CGPath {
//        let path = UIBezierPath()
//        
//        path.addArc(withCenter: CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2), radius: self.bounds.size.width / 2, startAngle: 0, endAngle: CGFloat.pi, clockwise: true)
//        
//        path.addQuadCurve(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height / 2), controlPoint: CGPoint(x: self.bounds.size.width / 2, y:  -30))
//        path.close()
//        return path.cgPath
//    }

//MARK:- start bubble
    public func bubble() {
    
        animationLarger()
    }
    

    private func animationLarger() {
        
        let duration: TimeInterval = 0.1
        mainBallDoAnimation(duration: duration, fromPath: getMainNoramlPath(), toPath: getMainLargePath())
        
        delay(duration) { 
            self.animationSmall()
        }
    }
    
    private func animationSmall() {
        let duration: TimeInterval = 0.2
        mainBallDoAnimation(duration: duration, fromPath: nil, toPath: getMainNoramlPath())
        
        delay(duration) { 
            self.animationBulge()
        }
    }
    
    private func animationBulge() {
        mainBall.anchorPoint = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2);
        let duration: TimeInterval = 0.2
        let animation = CABasicAnimation(keyPath: "path")
//        animation.toValue = getMainBulgePath()
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        mainBall.add(animation, forKey: "small")
//        mainBallDoAnimation(duration: duration, fromPath: nil, toPath: getMainBulgePath())
    }
    
    
    private func mainBallDoAnimation(duration: TimeInterval, fromPath: CGPath?, toPath: CGPath) {
        let animation = CASpringAnimation(keyPath: "path")
        if let from = fromPath {
            animation.fromValue = from
        }
        animation.toValue = toPath
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        mainBall.add(animation, forKey: "animation")
    }
    
//MARK:- other 
    private func delay(_ time: TimeInterval, execute:@escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + time) { 
            execute()
        }
    }
}

