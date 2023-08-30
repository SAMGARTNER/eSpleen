//
//  IKSTrophyCell.swift
//  iKeepScore
//
//  Created by Samir Augusto Gartner Arias on 15/12/14.
//  Copyright (c) 2014 Samir Gartner. All rights reserved.
//

import UIKit
import Foundation

class IKSTrophyCell: UITableViewCell
{
    var nameView: UIView?
    var nameLabel: UILabel?
    var leftIconView: UIView?
    var leftImageView:UIImageView?
    var leftIconCounterLabel: UILabel?
    var rightIconView: UIView?
    var rightImageView:UIImageView?
    var rightIconCounterLabel: UILabel?
    var name:NSString?
    var iconView:UIView?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: UITableViewCell.CellStyle.value1, reuseIdentifier: reuseIdentifier)
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 88.0)
        
        //self.backgroundColor = UIColor.redColor()
        nameView = UIView(frame: CGRect(x:(self.frame.size.width/2) - ((self.frame.size.width * 0.3125)/2),y:(self.frame.size.height/2)-((self.frame.size.height * 0.9090909091)/2),width:self.frame.size.width * 0.3125,height:self.frame.size.height * 0.9090909091))
        //nameView?.backgroundColor = UIColor.whiteColor()
        let nameViewWidth = self.nameView?.frame.size.width
        let nameViewHeight = self.nameView?.frame.size.height
        nameLabel = UILabel(frame: CGRect(x:0,y:0,width:nameViewWidth!,height:nameViewHeight!))
        nameLabel?.numberOfLines = 5
        nameLabel?.font = UIFont(name: "DINCondensed-bold", size:self.frame.size.height * 0.1704545455)
        nameLabel?.text = self.name as String?
        nameLabel?.textAlignment = NSTextAlignment.center
        nameLabel?.textColor = UIColor.white
        //nameLabel?.backgroundColor = UIColor.redColor()
        nameView?.addSubview(nameLabel!)
        
        self.addSubview(nameView!)
        
        leftIconView = UIView(frame: CGRect(x:((self.frame.size.width/6)) - ((self.frame.size.height * 0.9090909091)/2),y:self.frame.size.height * 0.04545454545,width:self.frame.size.height * 0.9090909091,height:self.frame.size.height * 0.9090909091))
        //leftIconView?.backgroundColor = UIColor.redColor()
        let leftIconViewWidth = leftIconView?.frame.size.width
        let lefttIconViewHeight = leftIconView?.frame.size.height
        let squareDimenssion = (round((leftIconView?.frame.size.height)!/3)+5)-(round((leftIconView?.frame.size.height)!/3).truncatingRemainder(dividingBy: 5))
        //leftIconCounterLabel = UILabel(frame: CGRect(x:(leftIconViewWidth!/2)-(leftIconViewWidth! * 0.1875),y:lefttIconViewHeight!*0.05,width:leftIconViewWidth! * 0.375,height:lefttIconViewHeight! * 0.25))
        //leftIconCounterLabel?.font = UIFont(name: "DINCondensed-bold", size: lefttIconViewHeight! * 0.25)
        //leftIconCounterLabel?.text = "0"
        //leftIconCounterLabel?.textAlignment = NSTextAlignment.Center
        //leftIconCounterLabel?.textColor = UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0))
        leftImageView = UIImageView(frame: CGRect(x: (leftIconViewWidth!/2)-(squareDimenssion/2), y: (lefttIconViewHeight!/2)-(squareDimenssion/2), width: squareDimenssion, height: squareDimenssion))
        //leftImageView?.backgroundColor = UIColor.yellowColor()
        //leftIconView?.addSubview(leftIconCounterLabel!)
        leftIconView?.addSubview(leftImageView!)
        
        self.addSubview(leftIconView!)
        
        rightIconView = UIView(frame: CGRect(x:((self.frame.size.width/6)*5) - ((self.frame.size.height * 0.9090909091)/2),y:self.frame.size.height * 0.04545454545,width:self.frame.size.height * 0.9090909091,height:self.frame.size.height * 0.9090909091))
        //rightIconView?.backgroundColor = UIColor.yellowColor()
        //let rightIconViewWidth = rightIconView?.frame.size.width
        //let rightIconViewHeight = rightIconView?.frame.size.height
        //rightIconCounterLabel = UILabel(frame: CGRect(x:(rightIconViewWidth!/2)-(leftIconViewWidth! * 0.1875),y:rightIconViewHeight!*0.05,width:rightIconViewWidth!*0.375,height:rightIconViewHeight! * 0.25))
        //rightIconCounterLabel?.font = UIFont(name: "DINCondensed-bold", size: rightIconViewHeight!*0.25)
        //rightIconCounterLabel?.text = "0"
        //rightIconCounterLabel?.textAlignment = NSTextAlignment.Center
        //rightIconCounterLabel?.textColor = UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0))
        rightImageView = UIImageView(frame: CGRect(x: (leftIconViewWidth!/2)-(squareDimenssion/2), y: (lefttIconViewHeight!/2)-(squareDimenssion/2), width: squareDimenssion, height: squareDimenssion))
        //rightIconView?.addSubview(rightIconCounterLabel!)
        rightIconView?.addSubview(rightImageView!)
        self.addSubview(rightIconView!)
    }
    
    /*override init(frame: CGRect)
    {
        super.init(frame:CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: 88.0))
        //self.backgroundColor = UIColor.redColor()
        nameView = UIView(frame: CGRect(x:(self.frame.size.width/2) - ((self.frame.size.width * 0.3125)/2),y:(self.frame.size.height/2)-((self.frame.size.height * 0.9090909091)/2),width:self.frame.size.width * 0.3125,height:self.frame.size.height * 0.9090909091))
        //nameView?.backgroundColor = UIColor.whiteColor()
        let nameViewWidth = self.nameView?.frame.size.width
        let nameViewHeight = self.nameView?.frame.size.height
        nameLabel = UILabel(frame: CGRect(x:0,y:0,width:nameViewWidth!,height:nameViewHeight!))
        nameLabel?.numberOfLines = 5
        nameLabel?.font = UIFont(name: "DINCondensed-bold", size:self.frame.size.height * 0.1704545455)
        nameLabel?.text = self.name as? String
        nameLabel?.textAlignment = NSTextAlignment.Center
        nameLabel?.textColor = UIColor.whiteColor()
        //nameLabel?.backgroundColor = UIColor.redColor()
        nameView?.addSubview(nameLabel!)
        
        self.addSubview(nameView!)
        
        leftIconView = UIView(frame: CGRect(x:((self.frame.size.width/6)) - ((self.frame.size.height * 0.9090909091)/2),y:self.frame.size.height * 0.04545454545,width:self.frame.size.height * 0.9090909091,height:self.frame.size.height * 0.9090909091))
        //leftIconView?.backgroundColor = UIColor.redColor()
        let leftIconViewWidth = leftIconView?.frame.size.width
        let lefttIconViewHeight = leftIconView?.frame.size.height
        leftIconCounterLabel = UILabel(frame: CGRect(x:(leftIconViewWidth!/2)-(leftIconViewWidth! * 0.1875),y:lefttIconViewHeight!*0.05,width:leftIconViewWidth! * 0.375,height:lefttIconViewHeight! * 0.25))
        leftIconCounterLabel?.font = UIFont(name: "DINCondensed-bold", size: lefttIconViewHeight! * 0.25)
        leftIconCounterLabel?.text = "0"
        leftIconCounterLabel?.textAlignment = NSTextAlignment.Center
        leftIconCounterLabel?.textColor = UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0))
        leftImageView = UIImageView(frame: CGRectMake((leftIconViewWidth!/2)-10, (lefttIconViewHeight!/2)-10, 20, 20))
        leftIconView?.addSubview(leftIconCounterLabel!)
        leftIconView?.addSubview(leftImageView!)
        
        self.addSubview(leftIconView!)
        
        rightIconView = UIView(frame: CGRect(x:((self.frame.size.width/6)*5) - ((self.frame.size.height * 0.9090909091)/2),y:self.frame.size.height * 0.04545454545,width:self.frame.size.height * 0.9090909091,height:self.frame.size.height * 0.9090909091))
        //rightIconView?.backgroundColor = UIColor.yellowColor()
        let rightIconViewWidth = rightIconView?.frame.size.width
        let rightIconViewHeight = rightIconView?.frame.size.height
        rightIconCounterLabel = UILabel(frame: CGRect(x:(rightIconViewWidth!/2)-(leftIconViewWidth! * 0.1875),y:rightIconViewHeight!*0.05,width:rightIconViewWidth!*0.375,height:rightIconViewHeight! * 0.25))
        rightIconCounterLabel?.font = UIFont(name: "DINCondensed-bold", size: rightIconViewHeight!*0.25)
        rightIconCounterLabel?.text = "0"
        rightIconCounterLabel?.textAlignment = NSTextAlignment.Center
        rightIconCounterLabel?.textColor = UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0))
        rightImageView = UIImageView(frame: CGRectMake((leftIconViewWidth!/2)-10, (lefttIconViewHeight!/2)-10, 20, 20))
        rightIconView?.addSubview(rightIconCounterLabel!)
        rightIconView?.addSubview(rightImageView!)
        
        self.addSubview(rightIconView!)

    }*/
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)!
    }
    
    
    
}
