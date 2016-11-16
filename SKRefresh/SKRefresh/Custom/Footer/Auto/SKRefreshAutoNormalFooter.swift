//
//  SKRefreshAutoNormalFooter.swift
//  SKRefresh
//
//  Created by nachuan on 2016/11/15.
//  Copyright © 2016年 nachuan. All rights reserved.
//

import UIKit

class SKRefreshAutoNormalFooter: SKRefreshAutoStateFooter {
    private var _activityIndicatorViewStyle: UIActivityIndicatorViewStyle = .gray;
    private var _indicator: UIActivityIndicatorView!
    var activityIndicatorViewStyle: UIActivityIndicatorViewStyle {
        get {
            return _activityIndicatorViewStyle;
        }
        set {
            _activityIndicatorViewStyle = newValue;
            _indicator = nil;
            setNeedsLayout();
        }
    }
    private var indicator: UIActivityIndicatorView {
        get {
            if _indicator == nil {
                _indicator = UIActivityIndicatorView(activityIndicatorStyle: activityIndicatorViewStyle);
                _indicator!.hidesWhenStopped = true;
                self.addSubview(_indicator!);
            }
            return _indicator!;
        }
        set {
            _indicator = newValue;
        }
    }
    
    //MARK: - 重写父类
    
    override class func footer(with refreshingClosure:  SKRefreshComponentRefreshingClosure?) -> SKRefreshAutoNormalFooter {
        let footer = SKRefreshAutoNormalFooter();
        footer.refreshingClosure = refreshingClosure;
        return footer;
    }
    
    override class func footer(with delegate: SKRefreshComponentDelegate?) -> SKRefreshAutoNormalFooter {
        let footer = SKRefreshAutoNormalFooter();
        footer.delegate = delegate;
        return footer;
    }
    
    
    override func prepare() {
        super.prepare();
        activityIndicatorViewStyle = .gray;
    }
    
    override func placeSubviews() {
        super.placeSubviews();
        if indicator.constraints.count == 0 {
            var indicatorCenterX = self.sk_width * 0.5;
            if isRefreshingTitleHidden == false {
                indicatorCenterX -= stateLabel.sk_textWidth * 0.5 + labelInsetLeft;
            }
            let indicatorCenterY: CGFloat = self.sk_height * 0.5;
            indicator.center = CGPoint(x: indicatorCenterX, y: indicatorCenterY);
            
        }
    }
    
    override var refreshState: SKRefreshState {
        get {
            return super.refreshState;
        }
        set {
            let oldState = super.refreshState;
            if oldState == newValue {
                return;
            }
            super.refreshState = newValue;
            if newValue == .noMoreData || newValue == .idle {
                indicator.stopAnimating();
            }else if newValue == .refreshing {
                indicator.startAnimating();
            }
        }
        
    }
    
    
}
