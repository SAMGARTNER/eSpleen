//
//  IKSMenuCell.swift
//  iKeepScore
//
//  Created by Samir Augusto Gartner Arias on 27/12/14.
//  Copyright (c) 2014 Samir Gartner. All rights reserved.
//
//



import UIKit
import Foundation

class IKSMenuCell: UITableViewCell
{
    var iconImageView: UIImageView?
    var centerIconImageView: UIImageView?
    var mainTextLabel:UILabel?
    var longTextLabel:UILabel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        
        super.init(style: UITableViewCell.CellStyle.value1, reuseIdentifier: reuseIdentifier)
        iconImageView = UIImageView(frame: CGRect(x:self.frame.size.width * 0.045,y:self.frame.size.height * 0.04545454545,width:self.frame.size.height * 0.9090909091, height:self.frame.size.height * 0.9090909091))
        iconImageView?.clipsToBounds = true
        self.addSubview(iconImageView!)
        centerIconImageView = UIImageView(frame: CGRect(x:(self.frame.size.width * 0.41) - (self.frame.size.height * 0.5),y:0,width:self.frame.size.height, height:self.frame.size.height))
        centerIconImageView?.clipsToBounds = true
        centerIconImageView?.layer.cornerRadius = self.frame.size.height / 2
        self.addSubview(centerIconImageView!)
        mainTextLabel = UILabel(frame: CGRect(x:(self.frame.size.height * 0.9090909091) + ((self.frame.size.width * 0.046875)*2),y:self.frame.size.height * 0.04545454545,width:self.frame.size.width * 0.4,height:self.frame.size.height - ((self.frame.size.height * 0.04545454545)*2)))
        mainTextLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        mainTextLabel?.textAlignment = NSTextAlignment.left
        mainTextLabel?.textColor = UIColor.white
        mainTextLabel?.textAlignment = NSTextAlignment.left
        mainTextLabel?.numberOfLines = 0
        mainTextLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.addSubview(mainTextLabel!)
        
        longTextLabel = UILabel(frame: CGRect(x: (self.frame.width/2) - ((self.frame.width*0.93)/2), y: self.frame.height-(self.frame.height*0.75), width: self.frame.width*0.75, height: self.frame.height*0.75))
        longTextLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        longTextLabel?.textColor = UIColor.white
        longTextLabel?.textAlignment = NSTextAlignment.center
        longTextLabel?.numberOfLines = 0
        longTextLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.addSubview(longTextLabel!)
        //self.backgroundColor = UIColor.darkGrayColor()
        self.backgroundColor = UIColor(red: CGFloat(65.0/255.0), green: CGFloat(65.0/255.0), blue: CGFloat(65.0/255.0), alpha: CGFloat(1.0))
        //self.backgroundColor = UIColor(red: CGFloat(81.0/255.0), green: CGFloat(2.0/255.0), blue: CGFloat(108.0/255.0), alpha: CGFloat(1.0))
        //self.backgroundColor = UIColor(red: CGFloat(141.0/255.0), green: CGFloat(10.0/255.0), blue: CGFloat(62.0/255.0), alpha: CGFloat(1.0))
        //self.backgroundColor = UIColor(red: CGFloat(38.0/255.0), green: CGFloat(2.0/255.0), blue: CGFloat(11.0/255.0), alpha: CGFloat(1.0))
    }

    
    /*override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        iconImageView = UIImageView(frame: CGRect(x:frame.size.width * 0.00625,y:frame.size.height * 0.04545454545,width:frame.size.height * 0.9090909091, height:frame.size.height * 0.9090909091))
        iconImageView?.clipsToBounds = true
        iconImageView?.layer.cornerRadius = ((frame.size.height * 0.9090909091)/2)
        iconImageView?.backgroundColor = UIColor(red: CGFloat(231.0/255.0), green: CGFloat(237.0/255.0), blue: CGFloat(234.0/255.0), alpha: CGFloat(1.0))
        self.addSubview(iconImageView!)
        centerIconImageView = UIImageView(frame: CGRect(x:(frame.size.width * 0.41) - (frame.size.height * 0.5),y:0,width:frame.size.height, height:frame.size.height))
        centerIconImageView?.clipsToBounds = true
        centerIconImageView?.layer.cornerRadius = frame.size.height / 2
        self.addSubview(centerIconImageView!)
        mainTextLabel = UILabel(frame: CGRect(x:(frame.size.height * 0.9090909091) + ((frame.size.width * 0.00625)*2),y:frame.size.height * 0.04545454545,width:frame.size.width - (frame.size.height * 0.9090909091) - ((frame.size.width * 0.00625)*2),height:frame.size.height - ((frame.size.height * 0.04545454545)*2)))
        mainTextLabel?.font = UIFont.boldSystemFontOfSize(12)
        mainTextLabel?.textAlignment = NSTextAlignment.Left
        mainTextLabel?.textColor = UIColor.whiteColor()
        mainTextLabel?.textAlignment = NSTextAlignment.Left
        mainTextLabel?.numberOfLines = 0
        mainTextLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.addSubview(mainTextLabel!)
        self.backgroundColor = UIColor.darkGrayColor()

    }*/
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)!
    }
}
