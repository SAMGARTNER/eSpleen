//
//  IKSTrophyBigCell.swift
//  iKeepScore
//
//  Created by Samir Augusto Gartner Arias on 15/10/15.
//  Copyright © 2015 Samir Gartner. All rights reserved.
//


import UIKit
import Foundation

class IKSTrophyBigCell: UITableViewCell
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
    var lineView:UIView?
    var button1View:UIView?
    var button2View:UIView?
    var button3View:UIView?
    var button4View:UIView?
    var button5View:UIView?
    var button6View:UIView?
    
    var button1ImageView:UIImageView?
    var button2ImageView:UIImageView?
    var button3ImageView:UIImageView?
    var button4ImageView:UIImageView?
    var button5ImageView:UIImageView?
    var button6ImageView:UIImageView?
    
    var positiveNegativeSwitch:UISwitch?
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: UITableViewCell.CellStyle.value1, reuseIdentifier: reuseIdentifier)
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 176.0)
        
        //self.backgroundColor = UIColor.redColor()
        nameView = UIView(frame: CGRect(x:(self.frame.size.width/2) - ((self.frame.size.width * 0.3125)/2),y:(self.frame.size.height/4)-(((self.frame.size.height/2) * 0.9090909091)/2),width:self.frame.size.width * 0.3125,height:(self.frame.size.height/2) * 0.9090909091))
        //nameView?.backgroundColor = UIColor.whiteColor()
        let nameViewWidth = self.nameView?.frame.size.width
        let nameViewHeight = self.nameView?.frame.size.height
        nameLabel = UILabel(frame: CGRect(x:0,y:0,width:nameViewWidth!,height:nameViewHeight!))
        nameLabel?.numberOfLines = 5
        nameLabel?.font = UIFont(name: "DINCondensed-bold", size:(self.frame.size.height/2) * 0.1704545455)
        nameLabel?.text = self.name as String?
        nameLabel?.textAlignment = NSTextAlignment.center
        //nameLabel?.textColor = UIColor.whiteColor()
        //nameLabel?.backgroundColor = UIColor.redColor()
        nameView?.addSubview(nameLabel!)
        
        self.addSubview(nameView!)
        
        leftIconView = UIView(frame: CGRect(x:((self.frame.size.width/6)) - (((self.frame.size.height/2) * 0.9090909091)/2),y:(self.frame.size.height/2) * 0.04545454545,width:(self.frame.size.height/2) * 0.9090909091,height:(self.frame.size.height/2) * 0.9090909091))
        //leftIconView?.backgroundColor = UIColor.redColor()
        let leftIconViewWidth = leftIconView?.frame.size.width
        let lefttIconViewHeight = leftIconView?.frame.size.height
        let squareDimenssion = (round((leftIconView?.frame.size.height)!/3)+5)-(round((leftIconView?.frame.size.height)!/3).truncatingRemainder(dividingBy: 5))
        leftIconCounterLabel = UILabel(frame: CGRect(x:((self.frame.size.width/6)) - ((leftIconViewWidth! * 0.375)/2),y:(self.frame.size.height/2) - ((lefttIconViewHeight! * 0.25)/2),width:leftIconViewWidth! * 0.375,height:lefttIconViewHeight! * 0.25))
        
        leftIconCounterLabel?.font = UIFont(name: "DINCondensed-bold", size: lefttIconViewHeight! * 0.25)
        leftIconCounterLabel?.text = "0"
        leftIconCounterLabel?.textAlignment = NSTextAlignment.center
        leftIconCounterLabel?.textColor = UIColor.white
        leftImageView = UIImageView(frame: CGRect(x: (leftIconViewWidth!/2)-(squareDimenssion/2), y: (lefttIconViewHeight!/2)-(squareDimenssion/2), width: squareDimenssion, height: squareDimenssion))
        self.addSubview(leftIconCounterLabel!)
        //leftImageView?.backgroundColor = UIColor.blueColor()
        leftIconView?.addSubview(leftImageView!)
        
        self.addSubview(leftIconView!)
        
        rightIconView = UIView(frame: CGRect(x:((self.frame.size.width/6)*5) - (((self.frame.size.height/2) * 0.9090909091)/2),y:(self.frame.size.height/2) * 0.04545454545,width:(self.frame.size.height/2) * 0.9090909091,height:(self.frame.size.height/2) * 0.9090909091))
        //rightIconView?.backgroundColor = UIColor.yellowColor()
        let rightIconViewWidth = rightIconView?.frame.size.width
        let rightIconViewHeight = rightIconView?.frame.size.height
        rightIconCounterLabel = UILabel(frame: CGRect(x:((self.frame.size.width/6)*5) - ((rightIconViewWidth!*0.375)/2),y:((self.frame.size.height/2)) - ((rightIconViewHeight! * 0.25)/2) ,width:rightIconViewWidth!*0.375,height:rightIconViewHeight! * 0.25))
        rightIconCounterLabel?.font = UIFont(name: "DINCondensed-bold", size: rightIconViewHeight!*0.25)
        rightIconCounterLabel?.text = "0"
        rightIconCounterLabel?.textAlignment = NSTextAlignment.center
        rightIconCounterLabel?.textColor = UIColor.black
        
        rightImageView = UIImageView(frame: CGRect(x: (leftIconViewWidth!/2)-(squareDimenssion/2), y: (lefttIconViewHeight!/2)-(squareDimenssion/2), width: squareDimenssion, height: squareDimenssion))
        self.addSubview(rightIconCounterLabel!)
        //rightImageView?.backgroundColor = UIColor.yellowColor()
        rightIconView?.addSubview(rightImageView!)
        
        self.addSubview(rightIconView!)
        
        /*button1View = UIView(frame: CGRect(x:((self.frame.size.width/12)*1) - (((self.frame.size.height/3) * 0.9090909091)/2),y:((self.frame.size.height/6)*5) - (((self.frame.size.height/3) * 0.9090909091)/2),width:(self.frame.size.height/3) * 0.9090909091,height:(self.frame.size.height/3) * 0.9090909091))
        self.addSubview(button1View!)
        button1ImageView = UIImageView(frame: CGRect(x:(button1View!.frame.size.width/2) - (button1View!.frame.size.height * 0.5),y:0,width:button1View!.frame.size.height, height:button1View!.frame.size.height))
        button1ImageView?.clipsToBounds = true
        button1ImageView?.layer.cornerRadius = button1View!.frame.size.height / 6
        //button1ImageView?.backgroundColor = UIColor(red: CGFloat(49.0/255.0), green: CGFloat(49.0/255.0), blue: CGFloat(49.0/255.0), alpha: CGFloat(1.0))
        button1ImageView?.image = getTintedImage(UIImage(named: "listsm.png")!, withColor: UIColor.whiteColor())
        self.button1View!.addSubview(button1ImageView!)
        
        button2View = UIView(frame: CGRect(x:((self.frame.size.width/12)*3) - (((self.frame.size.height/3) * 0.9090909091)/2),y:((self.frame.size.height/6)*5) - (((self.frame.size.height/3) * 0.9090909091)/2),width:(self.frame.size.height/3) * 0.9090909091,height:(self.frame.size.height/3) * 0.9090909091))
        self.addSubview(button2View!)
        button2ImageView = UIImageView(frame: CGRect(x:(button2View!.frame.size.width/2) - (button2View!.frame.size.height * 0.5),y:0,width:button2View!.frame.size.height, height:button2View!.frame.size.height))
        button2ImageView?.clipsToBounds = true
        button2ImageView?.layer.cornerRadius = button2View!.frame.size.height / 6
        //button2ImageView?.backgroundColor = UIColor(red: CGFloat(49.0/255.0), green: CGFloat(49.0/255.0), blue: CGFloat(49.0/255.0), alpha: CGFloat(1.0))
        button2ImageView?.image = getTintedImage(UIImage(named: "camera.png")!, withColor: UIColor.whiteColor())
        self.button2View!.addSubview(button2ImageView!)

        
        button3View = UIView(frame: CGRect(x:((self.frame.size.width/12)*5) - (((self.frame.size.height/3) * 0.9090909091)/2),y:((self.frame.size.height/6)*5) - (((self.frame.size.height/3) * 0.9090909091)/2),width:(self.frame.size.height/3) * 0.9090909091,height:(self.frame.size.height/3) * 0.9090909091))
        
        self.addSubview(button3View!)
        button3ImageView = UIImageView(frame: CGRect(x:(button3View!.frame.size.width/2) - (button3View!.frame.size.height * 0.5),y:0,width:button3View!.frame.size.height, height:button3View!.frame.size.height))
        button3ImageView?.clipsToBounds = true
        button3ImageView?.layer.cornerRadius = button3View!.frame.size.height / 6
        //button3ImageView?.backgroundColor = UIColor(red: CGFloat(49.0/255.0), green: CGFloat(49.0/255.0), blue: CGFloat(49.0/255.0), alpha: CGFloat(1.0))
        button3ImageView!.image = getTintedImage(UIImage(named: "editingsm.png")!, withColor: UIColor.whiteColor())
        self.button3View!.addSubview(button3ImageView!)
        

        
        button4View = UIView(frame: CGRect(x:((self.frame.size.width/12)*7) - (((self.frame.size.height/3) * 0.9090909091)/2),y:((self.frame.size.height/6)*5) - (((self.frame.size.height/3) * 0.9090909091)/2),width:(self.frame.size.height/3) * 0.9090909091,height:(self.frame.size.height/3) * 0.9090909091))
        self.addSubview(button4View!)
        button4ImageView = UIImageView(frame: CGRect(x:(button4View!.frame.size.width/2) - (button4View!.frame.size.height * 0.5),y:0,width:button4View!.frame.size.height, height:button4View!.frame.size.height))
        button4ImageView?.clipsToBounds = true
        button4ImageView?.layer.cornerRadius = button4View!.frame.size.height / 6
        //button4ImageView?.backgroundColor = UIColor(red: CGFloat(49.0/255.0), green: CGFloat(49.0/255.0), blue: CGFloat(49.0/255.0), alpha: CGFloat(1.0))
        button4ImageView?.image = getTintedImage(UIImage(named: "trashsm.png")!, withColor: UIColor.whiteColor())
        self.button4View!.addSubview(button4ImageView!)
        
        
        button5View = UIView(frame: CGRect(x:((self.frame.size.width/12)*9) - (((self.frame.size.height/3) * 0.9090909091)/2),y:((self.frame.size.height/6)*5) - (((self.frame.size.height/3) * 0.9090909091)/2),width:(self.frame.size.height/3) * 0.9090909091,height:(self.frame.size.height/3) * 0.9090909091))
        self.addSubview(button5View!)
        button5ImageView = UIImageView(frame: CGRect(x:(button5View!.frame.size.width/2) - (button5View!.frame.size.height * 0.5),y:0,width:button5View!.frame.size.height, height:button5View!.frame.size.height))
        button5ImageView?.clipsToBounds = true
        button5ImageView?.layer.cornerRadius = button5View!.frame.size.height / 6
        //button5ImageView?.backgroundColor = UIColor(red: CGFloat(49.0/255.0), green: CGFloat(49.0/255.0), blue: CGFloat(49.0/255.0), alpha: CGFloat(1.0))
        button5ImageView!.image = getTintedImage(UIImage(named: "gift.png")!, withColor: UIColor.whiteColor())
        self.button5View!.addSubview(button5ImageView!)
        
        button6View = UIView(frame: CGRect(x:((self.frame.size.width/12)*11) - (((self.frame.size.height/3) * 0.9090909091)/2),y:((self.frame.size.height/6)*5) - (((self.frame.size.height/3) * 0.9090909091)/2),width:(self.frame.size.height/3) * 0.9090909091,height:(self.frame.size.height/3) * 0.9090909091))
        self.addSubview(button6View!)
        button6ImageView = UIImageView(frame: CGRect(x:(button6View!.frame.size.width/2) - (button6View!.frame.size.height * 0.5),y:0,width:button6View!.frame.size.height, height:button6View!.frame.size.height))
        button6ImageView?.clipsToBounds = true
        button6ImageView?.layer.cornerRadius = button6View!.frame.size.height / 6
        //button5ImageView?.backgroundColor = UIColor(red: CGFloat(49.0/255.0), green: CGFloat(49.0/255.0), blue: CGFloat(49.0/255.0), alpha: CGFloat(1.0))
        button6ImageView!.image = UIImage(named: "fbc.png")!
        self.button6View!.addSubview(button6ImageView!)
        */
        
        /*button3View = UIView(frame: CGRect(x:((self.frame.size.width/2)) - (((self.frame.size.height/3) * 0.9090909091)/2),y:((self.frame.size.height/6)*5) - (((self.frame.size.height/3) * 0.9090909091)/2),width:(self.frame.size.height/3) * 0.9090909091,height:(self.frame.size.height/3) * 0.9090909091))
        
        self.addSubview(button3View!)
        button3ImageView = UIImageView(frame: CGRect(x:(button3View!.frame.size.width/2) - (button3View!.frame.size.height * 0.5),y:0,width:button3View!.frame.size.height, height:button3View!.frame.size.height))
        button3ImageView?.clipsToBounds = true
        button3ImageView?.layer.cornerRadius = button3View!.frame.size.height / 6
        //button3ImageView?.backgroundColor = UIColor(red: CGFloat(49.0/255.0), green: CGFloat(49.0/255.0), blue: CGFloat(49.0/255.0), alpha: CGFloat(1.0))
        button3ImageView!.image = getTintedImage(UIImage(named: "editingsm.png")!, withColor: UIColor.whiteColor())
        self.button3View!.addSubview(button3ImageView!)*/
        
        button1View = UIView(frame: CGRect(x:((self.frame.size.width/6)*1) - (((self.frame.size.height/3) * 0.9090909091)/2),y:((self.frame.size.height/6)*5) - (((self.frame.size.height/3) * 0.9090909091)/2),width:(self.frame.size.height/3) * 0.9090909091,height:(self.frame.size.height/3) * 0.9090909091))
        self.addSubview(button1View!)
        button1ImageView = UIImageView(frame: CGRect(x:(button1View!.frame.size.width/2) - (button1View!.frame.size.height * 0.5),y:0,width:button1View!.frame.size.height, height:button1View!.frame.size.height))
        button1ImageView?.clipsToBounds = true
        button1ImageView?.layer.cornerRadius = button1View!.frame.size.height / 6
        //button1ImageView?.backgroundColor = UIColor(red: CGFloat(49.0/255.0), green: CGFloat(49.0/255.0), blue: CGFloat(49.0/255.0), alpha: CGFloat(1.0))
        button1ImageView?.image = getTintedImage(UIImage(named: "bh.png")!, withColor: UIColor.white)
        self.button1View!.addSubview(button1ImageView!)
        
        /*button1View = UIView(frame: CGRect(x:((self.frame.size.width/6)*1) - (((self.frame.size.height/3) * 0.9090909091)/2),y:((self.frame.size.height/6)*5) - (((self.frame.size.height/3) * 0.9090909091)/2),width:(self.frame.size.height/3) * 0.9090909091,height:(self.frame.size.height/3) * 0.9090909091))
        self.addSubview(button1View!)
        button1ImageView = UIImageView(frame: CGRect(x:(button1View!.frame.size.width/2) - (button1View!.frame.size.height * 0.5),y:0,width:button1View!.frame.size.height, height:button1View!.frame.size.height))
        button1ImageView?.clipsToBounds = true
        button1ImageView?.layer.cornerRadius = button1View!.frame.size.height / 6
        button1ImageView?.backgroundColor = UIColor.greenColor()
        //button1ImageView?.image = getTintedImage(UIImage(named: "listsm.png")!, withColor: UIColor.whiteColor())
        //self.button1View!.addSubview(button1ImageView!)
        self.positiveNegativeSwitch = UISwitch(frame: CGRect(x:(button1View!.frame.size.width/2) - (button1View!.frame.size.height * 0.5),y:(button1View!.frame.size.height/4),width:button1View!.frame.size.height, height:button1View!.frame.size.height))
        self.positiveNegativeSwitch!.backgroundColor = UIColor(red: 246/255, green: 0, blue: 105/255, alpha: 1.0)
        self.positiveNegativeSwitch!.tintColor = UIColor(red: 246/255, green: 0, blue: 105/255, alpha: 1.0)
        self.positiveNegativeSwitch!.layer.cornerRadius = 16.0
        self.positiveNegativeSwitch!.onTintColor = UIColor(red: 0, green: 188/255, blue: 246/255, alpha: 1.0)
        //self.button1View!.backgroundColor = UIColor.greenColor()
        self.button1View!.addSubview(self.positiveNegativeSwitch!)
        self.positiveNegativeSwitch!.thumbTintColor = UIColor(patternImage: UIImage(named: "b.png")!)
        //print(self.positiveNegativeSwitch!.frame.height)
        self.positiveNegativeSwitch?.userInteractionEnabled = false*/
        
        button2View = UIView(frame: CGRect(x:((self.frame.size.width/6)*2) - (((self.frame.size.height/3) * 0.9090909091)/2),y:((self.frame.size.height/6)*5) - (((self.frame.size.height/3) * 0.9090909091)/2),width:(self.frame.size.height/3) * 0.9090909091,height:(self.frame.size.height/3) * 0.9090909091))
        
        self.addSubview(button2View!)
        button2ImageView = UIImageView(frame: CGRect(x:(button2View!.frame.size.width/2) - (button2View!.frame.size.height * 0.5),y:0,width:button2View!.frame.size.height, height:button2View!.frame.size.height))
        button2ImageView?.clipsToBounds = true
        button2ImageView?.layer.cornerRadius = button2View!.frame.size.height / 6
        //button3ImageView?.backgroundColor = UIColor(red: CGFloat(49.0/255.0), green: CGFloat(49.0/255.0), blue: CGFloat(49.0/255.0), alpha: CGFloat(1.0))
        button2ImageView!.image = getTintedImage(UIImage(named: "plusminus.png")!, withColor: UIColor.white)
        self.button2View!.addSubview(button2ImageView!)
        
        button3View = UIView(frame: CGRect(x:((self.frame.size.width/6)*3) - (((self.frame.size.height/3) * 0.9090909091)/2),y:((self.frame.size.height/6)*5) - (((self.frame.size.height/3) * 0.9090909091)/2),width:(self.frame.size.height/3) * 0.9090909091,height:(self.frame.size.height/3) * 0.9090909091))
        
        self.addSubview(button3View!)
        button3ImageView = UIImageView(frame: CGRect(x:(button3View!.frame.size.width/2) - (button3View!.frame.size.height * 0.5),y:0,width:button3View!.frame.size.height, height:button3View!.frame.size.height))
        button3ImageView?.clipsToBounds = true
        button3ImageView?.layer.cornerRadius = button3View!.frame.size.height / 6
        //button3ImageView?.backgroundColor = UIColor(red: CGFloat(49.0/255.0), green: CGFloat(49.0/255.0), blue: CGFloat(49.0/255.0), alpha: CGFloat(1.0))
        button3ImageView!.image = getTintedImage(UIImage(named: "editingsm.png")!, withColor: UIColor.white)
        self.button3View!.addSubview(button3ImageView!)
        
        button5View = UIView(frame: CGRect(x:((self.frame.size.width/6)*4) - (((self.frame.size.height/3) * 0.9090909091)/2),y:((self.frame.size.height/6)*5) - (((self.frame.size.height/3) * 0.9090909091)/2),width:(self.frame.size.height/3) * 0.9090909091,height:(self.frame.size.height/3) * 0.9090909091))
        self.addSubview(button5View!)
        button5ImageView = UIImageView(frame: CGRect(x:(button5View!.frame.size.width/2) - (button5View!.frame.size.height * 0.5),y:0,width:button5View!.frame.size.height, height:button5View!.frame.size.height))
        button5ImageView?.clipsToBounds = true
        button5ImageView?.layer.cornerRadius = button5View!.frame.size.height / 6
        //button5ImageView?.backgroundColor = UIColor(red: CGFloat(49.0/255.0), green: CGFloat(49.0/255.0), blue: CGFloat(49.0/255.0), alpha: CGFloat(1.0))
        button5ImageView!.image = getTintedImage(UIImage(named: "trashsm.png")!, withColor: UIColor.white)
        self.button5View!.addSubview(button5ImageView!)
        
        
        self.lineView = UIView(frame: CGRect(x:0,y:0,width:self.frame.size.width,height:self.frame.size.height * 0.005))
        self.lineView!.backgroundColor = UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0))
        self.addSubview(self.lineView!)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)!
    }
    
    func getTintedImage(_ image:UIImage, withColor tintColor: UIColor) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        
        
        context.translateBy(x: 0, y: image.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let rect: CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        // draw alpha-mask
        context.setBlendMode(CGBlendMode.normal)
        context.draw(image.cgImage!, in: rect)
        
        // draw tint color, preserving alpha values of original image
        context.setBlendMode(CGBlendMode.sourceIn)
        tintColor.setFill()
        context.fill(rect)
        
        let coloredImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return coloredImage
    }
    
}
