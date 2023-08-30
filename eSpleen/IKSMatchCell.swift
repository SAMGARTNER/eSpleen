//
//  IKSMatchCell.swift
//  iKeepScore
//
//  Created by Samir Augusto Gartner Arias on 5/12/14.
//  Copyright (c) 2014 Samir Gartner. All rights reserved.
//


import UIKit
import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class IKSMatchCell: UICollectionViewCell
{
    var leftCornerView: UIView?
    var rightCornerView: UIView?
    var leftCornerPlayerView: UIImageView?
    var leftCornerScoreRing: UIBezierPath?
    var leftCornerPlayerForenamesLabel:UILabel?
    var rightCornerPlayerForenamesLabel:UILabel?
    var rightCornerScoreRing: UIBezierPath?
    var rightCornerPlayerView: UIImageView?
    var rightCornerScoreView: UIView?
    var leftCornerScoreView: UIView?
    var leftPlayerScoreLabel: UILabel?
    var rightPlayerScoreLabel:UILabel?
    var context:CGContext?
    var leftRingShapeLayer:CAShapeLayer?
    var leftRingShapeLayer2:CAShapeLayer?
    var rightRingShapeLayer:CAShapeLayer?
    var rightRingShapeLayer2:CAShapeLayer?
    var leftCornerScore:Int?
    var rightCornerScore:Int?
    
    var matchNumberLabel: UILabel?
    var matchNumberLabelView: UIView?
    var matchNumberBackView: UIView?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0))
        leftCornerView = UIImageView(frame: CGRect(x:((self.frame.size.width/4))-((self.frame.size.height * 0.41)/2) - 10,y:(self.frame.size.height/2) - ((self.frame.size.height * 0.41)/2),width:self.frame.size.height * 0.41,height:self.frame.size.height * 0.41))
        //leftCornerView?.backgroundColor = UIColor.blueColor()
        self.addSubview(leftCornerView!)
        
        rightCornerView = UIImageView(frame: CGRect(x:((self.frame.size.width/4)*3)-((self.frame.size.height * 0.41)/2)+10,y:(self.frame.size.height/2) - ((self.frame.size.height * 0.41)/2),width:self.frame.size.height * 0.41,height:self.frame.size.height * 0.41))
         //rightCornerView?.backgroundColor = UIColor.blueColor()
        self.addSubview(rightCornerView!)
        
        leftCornerPlayerView = UIImageView(frame: CGRect(x:(self.leftCornerView!.frame.size.width/2)-((self.frame.size.height * 0.3087248322)/2),y:(self.leftCornerView!.frame.size.height/2) - ((self.frame.size.height * 0.3087248322)/2),width:self.frame.size.height * 0.3087248322,height:self.frame.size.height * 0.3087248322))
        leftCornerPlayerView?.clipsToBounds = true
        leftCornerPlayerView?.layer.cornerRadius = ((self.frame.size.height * 0.3087248322)/2)
        leftCornerPlayerView?.backgroundColor = UIColor(red: CGFloat(231.0/255.0), green: CGFloat(237.0/255.0), blue: CGFloat(234.0/255.0), alpha: CGFloat(1.0))
        leftCornerPlayerView?.backgroundColor = UIColor.white
        self.leftCornerView!.addSubview(leftCornerPlayerView!)
        
        
        
        rightCornerPlayerView = UIImageView(frame: CGRect(x:(self.rightCornerView!.frame.size.width/2) - ((self.frame.size.height * 0.3087248322)/2),y:(self.rightCornerView!.frame.size.height/2) - ((self.frame.size.height * 0.3087248322)/2),width:self.frame.size.height * 0.3087248322, height:self.frame.size.height * 0.3087248322))
        rightCornerPlayerView?.clipsToBounds = true
        rightCornerPlayerView?.layer.cornerRadius = ((self.frame.size.height * 0.3087248322)/2)
        rightCornerPlayerView?.backgroundColor = UIColor(red: CGFloat(231.0/255.0), green: CGFloat(237.0/255.0), blue: CGFloat(234.0/255.0), alpha: CGFloat(1.0))
        self.rightCornerView!.addSubview(rightCornerPlayerView!)
        
        leftCornerScoreView = UIView(frame: CGRect(x:self.frame.size.width * 0.34375,y:(self.frame.size.height/2) - (self.frame.size.height * 0.1006711409),width:self.frame.size.width * 0.15625,height:self.frame.size.height * 0.2013422819))
        leftCornerScoreView?.clipsToBounds = true
        leftCornerScoreView?.layer.cornerRadius = self.frame.size.height * 0.06711409396
        leftCornerScoreView?.backgroundColor = UIColor.clear
        leftPlayerScoreLabel = UILabel(frame: CGRect(x:0,y:self.frame.size.height * 0.01677852349,width:self.frame.size.width * 0.15625,height:self.frame.size.height * 0.2013422819))
        leftPlayerScoreLabel?.font = UIFont(name: "DINCondensed-bold", size:self.frame.size.height * 0.1677852349)
        //leftCornerScoreView?.backgroundColor = UIColor.orangeColor()
        
        leftPlayerScoreLabel?.textAlignment = NSTextAlignment.center
        leftPlayerScoreLabel?.textColor = UIColor.white
        leftCornerScoreView?.addSubview(leftPlayerScoreLabel!)
        
        self.addSubview(leftCornerScoreView!)
        
        rightCornerScoreView = UIView(frame: CGRect(x:self.frame.size.width * 0.5,y:(self.frame.size.height/2)-(self.frame.size.height * 0.1006711409),width:self.frame.size.width * 0.15625,height:self.frame.size.height * 0.2013422819))
        rightCornerScoreView?.clipsToBounds = true
        rightCornerScoreView?.layer.cornerRadius = self.frame.size.height * 0.06711409396
        rightCornerScoreView?.backgroundColor = UIColor.clear
        rightPlayerScoreLabel = UILabel(frame: CGRect(x:0,y:self.frame.size.height * 0.01677852349,width:self.frame.size.width * 0.15625,height:self.frame.size.height * 0.2013422819))
        rightPlayerScoreLabel?.font = UIFont(name: "DINCondensed-bold", size:self.frame.size.height * 0.1677852349)
        rightPlayerScoreLabel?.textAlignment = NSTextAlignment.center
        rightPlayerScoreLabel?.numberOfLines = 0
        rightPlayerScoreLabel?.textColor = UIColor.white
        //rightCornerScoreView?.backgroundColor = UIColor.orangeColor()
        rightCornerScoreView?.addSubview(rightPlayerScoreLabel!)
        
        //matchNumberBackView = UIView(frame: CGRect(x:((self.frame.size.width/2)-13),y:15,width:34,height:34))
        //matchNumberBackView?.clipsToBounds = true
        //matchNumberBackView?.layer.cornerRadius = 17
        //matchNumberBackView?.backgroundColor = UIColor(red: CGFloat(246.0/255.0), green: CGFloat(0.0/255.0), blue: CGFloat(105.0/255.0), alpha: CGFloat(1.0))
        matchNumberLabelView = UIView(frame: CGRect(x:((self.frame.size.width/2) - ((self.frame.size.height * 0.1476510067)/2)),y:self.frame.size.height * 0.1006711409,width:self.frame.size.height * 0.1476510067,height:self.frame.size.height * 0.1476510067))
        matchNumberLabelView?.clipsToBounds = true
        matchNumberLabelView?.layer.cornerRadius = self.frame.size.height * 0.07382550336
        //matchNumberLabelView?.backgroundColor = UIColor(red: CGFloat(231.0/255.0), green: CGFloat(237.0/255.0), blue: CGFloat(234.0/255.0), alpha: CGFloat(1.0))
        matchNumberLabelView?.backgroundColor = UIColor.darkGray
        matchNumberLabel = UILabel(frame: CGRect(x:0,y:self.frame.size.height * 0.01342281879,width:self.frame.size.height * 0.1476510067,height:self.frame.size.height * 0.1476510067))
        matchNumberLabel?.font = UIFont(name: "DINCondensed-bold", size: self.frame.size.height * 0.1006711409)
        matchNumberLabel?.textAlignment = NSTextAlignment.center
        matchNumberLabel?.textColor = UIColor.lightGray
        matchNumberLabelView?.addSubview(matchNumberLabel!)
        //matchNumberBackView?.addSubview(matchNumberLabelView!)
        self.addSubview(matchNumberLabelView!)
        
        leftCornerPlayerForenamesLabel = UILabel(frame: CGRect(x:(self.frame.size.width/2) - (self.frame.size.width * 0.46875) - 10,y:((self.frame.size.height/6)*5) - self.frame.size.height * 0.08389261745,width:(self.frame.size.width/2) - self.frame.size.width * 0.0625,height:self.frame.size.height * 0.1677852349))
        leftCornerPlayerForenamesLabel?.font = UIFont(name: "DINCondensed-bold", size: self.frame.size.height * 0.1006711409)
        //leftCornerPlayerForenamesLabel?.backgroundColor = UIColor.lightGrayColor()
        leftCornerPlayerForenamesLabel?.textAlignment = NSTextAlignment.center
        leftCornerPlayerForenamesLabel?.textColor = UIColor.white
        self.addSubview(leftCornerPlayerForenamesLabel!)
        
        rightCornerPlayerForenamesLabel = UILabel(frame: CGRect(x:(self.frame.size.width/2) + (self.frame.size.width * 0.03125) + 10,y:((self.frame.size.height/6)*5) - self.frame.size.height * 0.08389261745,width:(self.frame.size.width/2) - self.frame.size.width * 0.0625,height:self.frame.size.height * 0.1677852349))
        rightCornerPlayerForenamesLabel?.font = UIFont(name: "DINCondensed-bold", size: self.frame.size.height * 0.1006711409)
        //rightCornerPlayerForenamesLabel?.backgroundColor = UIColor.lightGrayColor()
        rightCornerPlayerForenamesLabel?.textAlignment = NSTextAlignment.center
        rightCornerPlayerForenamesLabel?.textColor = UIColor.white
        self.addSubview(rightCornerPlayerForenamesLabel!)
        self.addSubview(rightCornerScoreView!)
        
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
       
        let rightStartAngle = CGFloat(Double.pi/2)
        var rightEndAngle:CGFloat?
        if (self.rightCornerScore != nil)
        {
            rightEndAngle = self.getAngleForScore(self.rightCornerScore!)
            
        }
        else
        {
            rightEndAngle = self.getAngleForScore(100)
        }
        
        if self.rightRingShapeLayer == nil
        {
        self.rightRingShapeLayer = CAShapeLayer()
        }
        
        self.rightRingShapeLayer?.path = UIBezierPath(arcCenter: CGPoint(x:(self.rightCornerView!.frame.size.width/2)  , y: (self.rightCornerView!.frame.size.height/2) ), radius: self.frame.size.height * 0.1812080537, startAngle: rightStartAngle, endAngle: rightEndAngle!, clockwise: true).cgPath
        self.rightRingShapeLayer?.backgroundColor = UIColor.clear.cgColor
        self.rightRingShapeLayer?.fillColor = UIColor.clear.cgColor
        self.rightRingShapeLayer?.strokeColor = UIColor(red: CGFloat(246.0/255.0), green: CGFloat(0.0/255.0), blue: CGFloat(105.0/255.0), alpha: CGFloat(1.0)).cgColor
        self.rightRingShapeLayer?.lineWidth = self.frame.size.height * 0.05369127517
        
        self.rightCornerView!.layer.addSublayer(self.rightRingShapeLayer!)
        
        //let rightStartAngle2 = CGFloat(M_PI_2)
        var rightEndAngle2:CGFloat?
        if (self.rightCornerScore != nil)
        {
            if self.rightCornerScore > 100
            {
            rightEndAngle2 = self.getAngleForScore(self.rightCornerScore! - 100)
            }
            else
            {
            rightEndAngle2 = self.getAngleForScore(0)
            }
            
        }
        else
        {
            rightEndAngle2 = self.getAngleForScore(100)
        }
        
        if self.rightRingShapeLayer2 == nil
        {
            self.rightRingShapeLayer2 = CAShapeLayer()
        }
        self.rightRingShapeLayer2?.path = UIBezierPath(arcCenter: CGPoint(x:(self.rightCornerView!.frame.size.width/2), y: (self.rightCornerView!.frame.size.height/2)), radius: self.frame.size.height * 0.1812080537, startAngle: rightStartAngle, endAngle: rightEndAngle2!, clockwise: true).cgPath
        self.rightRingShapeLayer2?.backgroundColor = UIColor.clear.cgColor
        self.rightRingShapeLayer2?.fillColor = UIColor.clear.cgColor
        self.rightRingShapeLayer2?.strokeColor = UIColor(red: CGFloat(255.0/255.0), green: CGFloat(229.0/255.0), blue: CGFloat(69.0/255.0), alpha: CGFloat(1.0)).cgColor
        self.rightRingShapeLayer2?.lineWidth = self.frame.size.height * 0.06

        //self.rightRingShapeLayer?.path
        self.rightCornerView!.layer.addSublayer(self.rightRingShapeLayer2!)
        
        let leftStartAngle = CGFloat(Double.pi/2)
        var leftEndAngle:CGFloat?
        if self.leftCornerScore != nil
        {
            leftEndAngle = self.getAngleForScore(self.leftCornerScore!)
            
        }
        else
        {
            leftEndAngle = self.getAngleForScore(100)
        }
        

        if self.leftRingShapeLayer == nil
        {
            self.leftRingShapeLayer = CAShapeLayer()
        }
        
        self.leftRingShapeLayer?.path = UIBezierPath(arcCenter: CGPoint(x:(self.leftCornerView!.frame.size.width/2) , y: (self.leftCornerView!.frame.size.height/2)), radius: self.frame.size.height * 0.1812080537, startAngle: leftStartAngle, endAngle: leftEndAngle!, clockwise: true).cgPath
        self.leftRingShapeLayer?.backgroundColor = UIColor.clear.cgColor
        self.leftRingShapeLayer?.fillColor = UIColor.clear.cgColor
        self.leftRingShapeLayer?.strokeColor = UIColor(red: CGFloat(246.0/255.0), green: CGFloat(0.0/255.0), blue: CGFloat(105.0/255.0), alpha: CGFloat(1.0)).cgColor
        self.leftRingShapeLayer?.lineWidth = self.frame.size.height * 0.05369127517

        
        self.leftCornerView!.layer.addSublayer(self.leftRingShapeLayer!)
        
        let leftStartAngle2 = CGFloat(Double.pi/2)
        var leftEndAngle2:CGFloat?
        if self.leftCornerScore != nil
        {
            if self.leftCornerScore > 100
            {
                leftEndAngle2 = self.getAngleForScore(self.leftCornerScore! - 100)
            }
            else
            {
                leftEndAngle2 = self.getAngleForScore(0)
            }
            
        }
        else
        {
            leftEndAngle2 = self.getAngleForScore(100)
        }
        
        if self.leftRingShapeLayer2 == nil
        {
            self.leftRingShapeLayer2 = CAShapeLayer()
        }
        
        self.leftRingShapeLayer2?.path = UIBezierPath(arcCenter: CGPoint(x:((self.leftCornerView!.frame.size.width/2)), y: (self.leftCornerView!.frame.size.height/2)), radius: self.frame.size.height * 0.1812080537, startAngle: leftStartAngle2, endAngle: leftEndAngle2!, clockwise: true).cgPath
        self.leftRingShapeLayer2?.backgroundColor = UIColor.clear.cgColor
        self.leftRingShapeLayer2?.fillColor = UIColor.clear.cgColor
        self.leftRingShapeLayer2?.strokeColor = UIColor(red: CGFloat(255.0/255.0), green: CGFloat(229.0/255.0), blue: CGFloat(69.0/255.0), alpha: CGFloat(1.0)).cgColor
        self.leftRingShapeLayer2?.lineWidth = self.frame.size.height * 0.06

        //self.rightRingShapeLayer?.path
        self.leftCornerView!.layer.addSublayer(self.leftRingShapeLayer2!)

        if self.leftCornerScore != nil
        {
        leftPlayerScoreLabel?.text = String(self.leftCornerScore!)
        }
        if self.rightCornerScore != nil
        {
        rightPlayerScoreLabel?.text = String(self.rightCornerScore!)
        }
        
        
        let pathTopRight: CGMutablePath = CGMutablePath()
        pathTopRight.move(to:CGPoint(x:(self.frame.size.width/2) + (self.frame.size.width * 0.09375),y: self.frame.size.height * 0.1744966443))
        pathTopRight.addLine(to:CGPoint(x:(self.frame.size.width/2) + (self.frame.size.width * 0.0703125),y: (self.frame.size.height * 0.1744966443) - (self.frame.size.width * 0.015625)))
        pathTopRight.addLine(to:CGPoint(x:(self.frame.size.width/2) + (self.frame.size.width * 0.0703125),y: (self.frame.size.height * 0.1744966443) + (self.frame.size.width * 0.015625)))
        pathTopRight.addLine(to:CGPoint(x: (self.frame.size.width/2) + (self.frame.size.width * 0.09375),y: self.frame.size.height * 0.1744966443))
        
        let shapeLayerTopRight:CAShapeLayer = CAShapeLayer()
        shapeLayerTopRight.path = pathTopRight
        shapeLayerTopRight.fillColor =   UIColor.darkGray.cgColor
        shapeLayerTopRight.strokeColor = UIColor.darkGray.cgColor
        shapeLayerTopRight.bounds = CGRect(x: 300, y: (self.frame.size.height/2), width: 20.0, height: 20)
        shapeLayerTopRight.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        shapeLayerTopRight.position = CGPoint(x: 300, y: (self.frame.size.height/2))
        self.layer.addSublayer(shapeLayerTopRight)
        
        let pathTopLeft: CGMutablePath = CGMutablePath()
        pathTopLeft.move(to:CGPoint(x:(self.frame.size.width/2) - (self.frame.size.width * 0.09375),y: self.frame.size.height * 0.1744966443))
        pathTopLeft.addLine(to:CGPoint(x:(self.frame.size.width/2) - (self.frame.size.width * 0.0703125),y: (self.frame.size.height * 0.1744966443) - (self.frame.size.width * 0.015625)))
        pathTopLeft.addLine(to:CGPoint( x:(self.frame.size.width/2) - (self.frame.size.width * 0.0703125), y:(self.frame.size.height * 0.1744966443) + (self.frame.size.width * 0.015625)))
        pathTopLeft.addLine(to:CGPoint(x:(self.frame.size.width/2) - (self.frame.size.width * 0.09375),y:(self.frame.size.height * 0.1744966443)))
        
        let shapeLayerTopLeft:CAShapeLayer = CAShapeLayer()
        shapeLayerTopLeft.path = pathTopLeft
        shapeLayerTopLeft.fillColor =   UIColor.darkGray.cgColor
        shapeLayerTopLeft.strokeColor = UIColor.darkGray.cgColor
        shapeLayerTopLeft.bounds = CGRect(x: 20, y: (self.frame.size.height/2), width: 20.0, height: 20)
        shapeLayerTopLeft.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        shapeLayerTopLeft.position = CGPoint(x: 20, y: (self.frame.size.height/2))
        self.layer.addSublayer(shapeLayerTopLeft)
        
        
    }
    
    func setLeftScore(_ leftScore:Int, andRightScoreAnimated rightScore:Int)
    {
        //print(leftScore,"---",rightScore)
        self.setLeftCornerScore(leftScore)
        self.setRightCornerScore(rightScore)

    }
    
    func setRightCornerScore(_ score:Int)
    {
        
        
        /*let rightRingAnimation = CABasicAnimation(keyPath: "strokeEnd")
        self.rightRingShapeLayer?.strokeEnd = CGFloat(((CGFloat(score)*100)/10000))
        //self.ringShapeLayer?.strokeStart = 1.0
        rightRingAnimation.fromValue = CGFloat(((CGFloat(self.leftCornerScore!)*100)/10000))
        rightRingAnimation.toValue = ((CGFloat(score)*100)/10000)
        rightRingAnimation.duration = CFTimeInterval( 1 - ((CGFloat(score)*100)/10000))
        rightRingAnimation.delegate = self
        rightRingAnimation.removedOnCompletion = false
        rightRingAnimation.additive = false
        rightRingAnimation.fillMode = kCAFillModeBackwards
        rightRingAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        self.rightRingShapeLayer?.addAnimation(rightRingAnimation, forKey: "strokeEnd")*/
        
        self.rightCornerScore = score
        self.setNeedsDisplay()
        
    }
    
    func setLeftCornerScore(_ score:Int)
    {
        
        
        /*let leftRingAnimation = CABasicAnimation(keyPath: "strokeEnd")
        self.leftRingShapeLayer?.strokeEnd = CGFloat(((CGFloat(score)*100)/10000))
        //self.ringShapeLayer?.strokeStart = 1.0
        leftRingAnimation.fromValue = CGFloat(((CGFloat(self.leftCornerScore!)*100)/10000))
        leftRingAnimation.toValue = ((CGFloat(score)*100)/10000)
        leftRingAnimation.duration = CFTimeInterval( 1 - ((CGFloat(score)*100)/10000))
        leftRingAnimation.delegate = self
        leftRingAnimation.removedOnCompletion = false
        leftRingAnimation.additive = false
        leftRingAnimation.fillMode = kCAFillModeBackwards
        leftRingAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        self.leftRingShapeLayer?.addAnimation(leftRingAnimation, forKey: "strokeEnd")*/
        
        self.leftCornerScore = score
        self.setNeedsDisplay()
        
    }
    
    fileprivate func gradientMask() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        
        gradientLayer.locations = [0.0, 1.0]
        
        let colorTop: AnyObject = UIColor(red: 255.0/255.0, green: 213.0/255.0, blue: 63.0/255.0, alpha: 1.0).cgColor
        let colorBottom: AnyObject = UIColor(red: 255.0/255.0, green: 198.0/255.0, blue: 5.0/255.0, alpha: 1.0).cgColor
        let arrayOfColors: [AnyObject] = [colorTop, colorBottom]
        gradientLayer.colors = arrayOfColors
        
        return gradientLayer
    }
    
    func getAngleForScore(_ score:Int) -> CGFloat
    {

        let radians:CGFloat = CGFloat(Double.pi/180) * CGFloat(CGFloat(CGFloat(score*100)/10000)*360) + CGFloat(Double.pi/2)
        //println("radians \(radians)")
        return CGFloat(radians)
    }

}
