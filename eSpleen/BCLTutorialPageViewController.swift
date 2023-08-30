//
//  BLCTutorialPageViewController.swift
//  eSpleen
//
//  Created by Samir Augusto Gartner Arias on 28/04/15.
//  Copyright (c) 2015 Samir Gartner. All rights reserved.
//

import UIKit
import Foundation

class BCLTutorialPageViewController: UIPageViewController
{
    
    var pageControl:UIPageControl?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageControl = UIPageControl()
        //let postition = (UIScreen.mainScreen().bounds.size.height * UIScreen.mainScreen().scale) * 0.45
        let position = self.view.frame.size.height * 0.925
        self.pageControl!.frame  = CGRect(x: 0,y: position, width: 320, height: 30)
        self.pageControl?.numberOfPages = 1
        self.view.addSubview(self.pageControl!)
    }
    
    override func viewDidLayoutSubviews() {
        /*for subView in self.view.subviews as! [UIView] {
            if subView is UIScrollView {
                subView.frame = self.view.bounds
            } else if subView is UIPageControl {
                self.view.bringSubviewToFront(subView)
            }
        }*/
        super.viewDidLayoutSubviews()
    }
}
