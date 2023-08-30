//
//  IKSContactsCell.swift
//  iKeepScore
//
//  Created by Samir Augusto Gartner Arias on 12/12/14.
//  Copyright (c) 2014 Samir Gartner. All rights reserved.
//

import UIKit
import Foundation

class IKSContactsCell: UITableViewCell
{
    var personView: UIView?
    var forenames: UILabel?
    var surenames:UILabel?
    var emailLabel:UILabel?
    var twitterIDLabel:UILabel?
    var facebookIDLabel:UILabel?
    var gamecenterIDLabel:UILabel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier)
        /*
        rightPlayerScoreLabel = UILabel(frame: CGRect(x:0,y:3,width:50,height:25))
        rightPlayerScoreLabel?.font = UIFont(name: "DINCondensed-bold", size: 25)
        rightPlayerScoreLabel?.text = "100%"
        rightPlayerScoreLabel?.textAlignment = NSTextAlignment.Left
        rightPlayerScoreLabel?.textColor = UIColor.whiteColor()
        rightCornerScoreView?.addSubview(rightPlayerScoreLabel!)
        self.addSubview(rightCornerScoreView!)*/
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    
    
    override func draw(_ rect: CGRect)
    {
        
    }

}
