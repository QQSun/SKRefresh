//
//  SKRefreshBackNormalFooter.swift
//  SKRefresh
//
//  Created by nachuan on 2016/11/16.
//  Copyright © 2016年 nachuan. All rights reserved.
//

import UIKit

class SKRefreshBackNormalFooter: SKRefreshBackStateFooter {

    /// 刷新指示器箭头
    private var _arrowView: UIImageView?
    /// 刷新指示器样式
    private var _activityIndicatorViewStyle: UIActivityIndicatorViewStyle = .gray;
    /// 刷新指示器
    private var _indicator: UIActivityIndicatorView?
    public var arrowView: UIImageView {
        get {
            if _arrowView == nil {
                _arrowView = UIImageView.init(image: Bundle.sk_arrowImage());
                self.addSubview(_arrowView!);
            }
            return _arrowView!;
        }
        set {
            _arrowView = newValue;
        }
    }
    public var activityIndicatorViewStyle: UIActivityIndicatorViewStyle {
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
    //MARK: - 类方法
    /// 创建header
    ///
    /// - parameter refreshingClosure: 刷新时回调闭包
    ///
    /// - returns: 刷新控件
    public override class func footer(with refreshingClosure: SKRefreshComponentRefreshingClosure?) -> SKRefreshBackNormalFooter {
        let footer = SKRefreshBackNormalFooter();
        footer.refreshingClosure = refreshingClosure;
        return footer;
        
    }
    /// 创建header
    ///
    /// - parameter delegate: 刷新代理
    ///
    /// - returns: 刷新控件
    public override class func footer(with delegate: SKRefreshComponentDelegate?) -> SKRefreshBackNormalFooter {
        let footer = SKRefreshBackNormalFooter();
        footer.delegate = delegate;
        return footer;
        
    }
    
    override func prepare() {
        super.prepare();
        activityIndicatorViewStyle = .gray;
    }
    
    override func placeSubviews() {
        super.placeSubviews();
        var arrowCenterX = self.sk_width * 0.5;
        
        if stateLabel.isHidden == false {
            arrowCenterX -= labelInsetLeft + stateLabel.sk_textWidth * 0.5;
        }
        let arrowCenterY: CGFloat = self.sk_height * 0.5;
        let arrowCenter: CGPoint = CGPoint.init(x: arrowCenterX, y: arrowCenterY);
        
        /// 箭头
        if arrowView.constraints.count == 0 {
            if arrowView.image != nil {
                arrowView.sk_size = arrowView.image!.size;
                arrowView.center = arrowCenter;
            }
        }
        
        /// 圆圈
        if indicator.constraints.count == 0 {
            indicator.center = arrowCenter;
        }
        
        arrowView.tintColor = stateLabel.textColor;
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
            if newValue == .idle {
                if oldState == .refreshing {
                    arrowView.transform = CGAffineTransform.init(rotationAngle: (0.000001 - CGFloat(M_PI)));
                    UIView.animate(withDuration: SKRefreshSlowAnimationDuration, animations: {
                        self.indicator.alpha = 0.0;
                        }, completion: { (finished: Bool) in
                            self.indicator.alpha = 1.0;
                            self.indicator.stopAnimating();
                            self.arrowView.isHidden = false;
                    });
                }else{
                    indicator.stopAnimating();
                    arrowView.isHidden = false;
                    UIView.animate(withDuration: SKRefreshFastAnimationDuration, animations: {
                        self.arrowView.transform = CGAffineTransform.init(rotationAngle: (0.000001 - CGFloat(M_PI)));
                    });
                }
            }else if newValue == .pulling {
                indicator.stopAnimating();
                arrowView.isHidden = false;
                UIView.animate(withDuration: SKRefreshFastAnimationDuration, animations: {
                    self.arrowView.transform = CGAffineTransform.identity;
                });
            }else if newValue == .refreshing {
                /// 防止refreshing -> idle的动画完毕动作没有被执行
                indicator.alpha = 1.0;
                indicator.startAnimating();
                arrowView.isHidden = true;
            }else if newValue == .noMoreData {
                arrowView.isHidden = true;
                indicator.alpha = 1.0;
                indicator.stopAnimating();
            }
        }
    }
}




























