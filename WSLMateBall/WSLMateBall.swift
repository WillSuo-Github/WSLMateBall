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
    private var smallBalls: [UIView] = [UIView]()
    
    var displayLink: CADisplayLink?
    
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
    
    private func addSmallBall() -> UIView {
        let view = UIView()
        let layerWH: CGFloat = 10.0
        view.frame = CGRect(x: self.bounds.size.width / 2 - layerWH / 2, y: self.bounds.size.height / 2 - layerWH / 2, width: layerWH, height: layerWH)
        view.backgroundColor = UIColor.purple
        view.layer.cornerRadius = layerWH / 2
        view.layer.masksToBounds = true
//        self.layer.insertSublayer(layer, at: 9)
        self.addSubview(view)
        smallBalls.append(view)
        return view
    }
    
    private func getMainNoramlPath() -> CGPath {
        return UIBezierPath(arcCenter: CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2), radius: self.bounds.size.width / 2, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true).cgPath
    }
    
    private func getMainLargePath() -> CGPath {
        return UIBezierPath(arcCenter: CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2), radius: self.bounds.size.width / 2 + 10, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true).cgPath
    }
    
//MARK:- action response
    @objc private func displayAction(_ disp: CADisplayLink) {
        if let layer = smallBalls.last {
            print(layer.frame)
        }
    }
    

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
            self.animationSmallBall()
        }
    }
    
    private func animationSmallBall() {
        let smallBall = addSmallBall()
//        startDisplay()

        let duration = 1.0
        UIView.animate(withDuration: duration) {
            smallBall.transform = CGAffineTransform(translationX: 0, y: -self.bounds.size.height / 2 - 8)
        }
        
        delay(duration) { 
            self.animationRotation(smallBall)
        }
    }
    
    
    private func animationRotation(_ view: UIView) {
        UIView.animate(withDuration: 1) { 
            view.layer.anchorPoint = CGPoint(x: 0, y: 0)
            view.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi))
        }
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
    
    private func startDisplay() {
        let disp = displayLink ?? CADisplayLink(target: self, selector: #selector(displayAction(_:)))
        disp.add(to: RunLoop.current, forMode: .defaultRunLoopMode)
        displayLink = disp
    }
    
    private func endDisplay() {
        displayLink?.invalidate()
    }
    

}

