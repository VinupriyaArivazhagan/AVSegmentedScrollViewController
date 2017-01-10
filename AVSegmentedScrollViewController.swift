//
//  AVSegmentedScrollViewController.swift
//  AVScrollView
//
//  Created by Vinupriya Arivazhagan on 1/9/17.
//  Copyright © 2017 Vinupriya. All rights reserved.
//

import UIKit

public enum AVScrollViewSegmentStyle: Int {
    case viewController
    case navigationController
}

class AVSegmentedScrollViewController: UIViewController {
  
    /// View to hold buttons container and scroll view
    fileprivate let segmentScrollView = UIView()
    
    /// view to hold all the buttons
    fileprivate let buttonsContainerView = UIView()
    
    /// scrollview
    fileprivate let scrollView = UIScrollView()
    
    /// bottom segment slide view
    fileprivate let slideView = UIView()
    
    /// array to hold all the buttons
    fileprivate var buttons = [UIButton]()
    
    /// array to hold all the views in scrollview
    fileprivate var views = [UIView]()
    
    /// Int of number of segment
    fileprivate var numberOfSegment: Int!
    
    /// Button handler closure
    fileprivate var buttonHandlerDict = [String: (UIButton) -> ()]()
    
    public convenience init(numberOfSegments count: Int, preferredStyle: AVScrollViewSegmentStyle) {
        self.init()
        
        // setup frames from preferred style
        switch preferredStyle {
            
        case .viewController:
            setUpViewController()
            
        case .navigationController:
            setUpNavigationController()
            
        }
        
        // set up number of segment
        numberOfSegment = count
        
        // setting view Background Color
        view.backgroundColor = UIColor.white
        
        // setting scrollview and segment view base view
        segmentScrollView.backgroundColor = UIColor.white
        view.addSubview(segmentScrollView)
        
        // setting buttons container view
        segmentScrollView.addSubview(buttonsContainerView)
        
        // setting Scrollview
        scrollView.delegate = self
        segmentScrollView.addSubview(scrollView)
        
        // setting segment bottom slide view
        slideView.frame.size.width = view.frame.size.width / CGFloat(count)
        segmentScrollView.addSubview(slideView)
        
        // setting buttons in the segment
        for i in 0...numberOfSegment-1 {
            let button = UIButton(frame: CGRect(x: 0, y: preferredStyle == .viewController ? CGFloat(20) : CGFloat(0), width: view.frame.size.width / CGFloat(count), height: 47))
            buttonsContainerView.addSubview(button)
            
            if !buttons.isEmpty {
                button.frame.origin.x = buttons[i-1].frame.origin.x + buttons[i-1].frame.size.width
            }
            
            button.addTarget(self, action: #selector(self.buttonActions(button:)), for: .touchUpInside)
            buttons.append(button)
        }
        
        // setting views in the segment
        for i in 0...numberOfSegment-1 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.size.height))
            scrollView.addSubview(view)
            
            if !views.isEmpty {
                view.frame.origin.x = views[i-1].frame.origin.x + views[i-1].frame.size.width
            }
            
            views.append(view)
        }
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(count), height: scrollView.frame.size.height)
        
        scrollView.isPagingEnabled = true
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
    }
    
    /// setting up frames of 'segmentScrollView' subviews if the preferred Style is viewController
    private func setUpViewController() {
        segmentScrollView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        buttonsContainerView.frame = CGRect(x: 0, y: 0, width: segmentScrollView.frame.size.width, height: 70)
        slideView.frame = CGRect(x: 0, y: 67, width: 0, height: 3)
        scrollView.frame = CGRect(x: 0, y: 70, width: segmentScrollView.frame.size.width, height: segmentScrollView.frame.size.height-70)
    }
    
    /// setting up frames of 'segmentScrollView' subviews if the preferred Style is navigationController
    private func setUpNavigationController() {
        segmentScrollView.frame = CGRect(x: 0, y: 64, width: view.frame.size.width, height: view.frame.size.height-64)
        buttonsContainerView.frame = CGRect(x: 0, y: 0, width: segmentScrollView.frame.size.width, height: 50)
        slideView.frame = CGRect(x: 0, y: 47, width: 0, height: 3)
        scrollView.frame = CGRect(x: 0, y: 50, width: segmentScrollView.frame.size.width, height: segmentScrollView.frame.size.height-50)
    }
    
    @objc fileprivate func buttonActions(button: UIButton) {
        
        if let index = buttons.index(of: button) {
            
            UIView.animate(withDuration: 0.3, animations: {
                self.scrollView.contentOffset = CGPoint(x: CGFloat(index.hashValue) * self.view.frame.width, y: 0)
                self.view.layoutIfNeeded()
            }, completion: {_ in
                
            })
            
            if let handler = buttonHandlerDict["\(index.hashValue)"] {
                handler(button)
            }
        }
    }
}

//MARK: - get Button and button action

extension AVSegmentedScrollViewController {
    
    /// handler to get 'button' in segment
    public func getButton(at index: Int, handler: (UIButton?) -> ()) {
        if buttons.count > index {
            handler(buttons[index])
        }
        else {
            handler(nil)
        }
    }
    
    /// handler for action of segment 'button'
    public func buttonAction(at index: Int, handler: @escaping (UIButton) -> ()) {
        if buttons.count > index {
            buttonHandlerDict["\(index)"] = handler
        }
    }
}

//MARK: - get view 

extension AVSegmentedScrollViewController {
    
    /// handler to get 'view' in Segment Scroll View
    public func getView(at index: Int, handler: (UIView?) -> ()) {
        if views.count > index {
            handler(views[index])
        }
        else {
            handler(nil)
        }
    }
    
    /// handler to get segment bottom slide view
    public func getBottomSlideView(handler: (UIView) -> ()) {
        handler(slideView)
    }
    
    /// handler to get the scrollView
    public func getScrollView(handler: (UIScrollView) -> ()) {
        handler(scrollView)
    }
    
    /// handlet to get button segment container view
    public func getButtonsContainerView(handler: (UIView) -> ()) {
        handler(buttonsContainerView)
    }
    
}

//MARK: - UIScrollView KVO

extension AVSegmentedScrollViewController {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        slideView.frame.origin.x = scrollView.contentOffset.x/CGFloat(numberOfSegment)
    }
}

//MARK: - UIscrollViewDelegate

extension AVSegmentedScrollViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for button in buttons {
            if button.frame.origin.x == scrollView.contentOffset.x/3 {
                buttonActions(button: button)
            }
        }
    }
}
