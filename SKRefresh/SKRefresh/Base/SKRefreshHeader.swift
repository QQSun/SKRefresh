//
//  SKRefreshHeader.swift
//  SKRefresh
//
//  Created by nachuan on 2016/11/14.
//  Copyright © 2016年 nachuan. All rights reserved.
//

import UIKit

class SKRefreshHeader: SKRefreshComponent {
    /// 这个key用来存储上一次下拉刷新成功的时间
    private var _lastUpdatedTimeKey: String = SKRefreshHeaderLastUpdatedTimeKey;
    /// 上一次下拉刷新成功的时间
    private var _lastUpdatedTime: Date?
    /// 忽略多少scrollView的contentInset的top
    private var _ignoredScrollViewContentInsetTop: CGFloat = 0.0;
    private var _insetTopDelta: CGFloat = 0.0;

    var lastUpdatedTimeKey: String {
        get {
            return _lastUpdatedTimeKey;
        }
        set {
            _lastUpdatedTimeKey = newValue;
        }
    }
    var lastUpdatedTime: Date? {
        get {
            return UserDefaults.standard.object(forKey: lastUpdatedTimeKey) as? Date;
        }
        set {
            _lastUpdatedTime = newValue;
        }
    }
    var ignoredScrollViewContentInsetTop: CGFloat {
        get {
            return _ignoredScrollViewContentInsetTop;
        }
        set {
            _ignoredScrollViewContentInsetTop = newValue;
        }
    }
    
    //MARK: - 类方法
    /// 创建header
    ///
    /// - parameter refreshingClosure: 刷新时回调闭包
    ///
    /// - returns: 刷新控件
    class func header(with refreshingClosure: SKRefreshComponentRefreshingClosure?) -> SKRefreshHeader {
        fatalError("子类需要重写该方法.并返回子类实例对象.重写时请不要调用父类方法");
    }
    /// 创建header
    ///
    /// - parameter delegate: 刷新代理
    ///
    /// - returns: 刷新控件
    class func header(with delegate: SKRefreshComponentDelegate?) -> SKRefreshHeader{
        fatalError("子类需要重写该方法.并返回子类实例对象.重写时请不要调用父类方法");
    }

    
    //MARK: - 覆盖父类方法
    override func prepare() {
        super.prepare();
        lastUpdatedTimeKey = SKRefreshHeaderLastUpdatedTimeKey;
        self.sk_height = SKRefreshHeaderHeight;
    }
    
    override func placeSubviews() {
        super.placeSubviews();
        /// 设置y值(当自己的高度发生改变了，肯定要重新调整Y值，所以放到placeSubviews方法中设置y值)
        self.sk_y = -self.sk_height - self.ignoredScrollViewContentInsetTop;
    }
    
    override func handleContentOffset(did change: [NSKeyValueChangeKey : Any], on scrollView: UIScrollView) {
        super.handleContentOffset(did: change, on: scrollView);
        if let tempScrollView = self.scrollView {
            if refreshState == .refreshing {
                if self.window == nil {
                    return;
                }
                // sectionHeader停留解决
                var insetT: CGFloat = -tempScrollView.sk_offsetY > scrollViewOriginalInset.top ? -tempScrollView.sk_offsetY : scrollViewOriginalInset.top;
                
                insetT = insetT > self.sk_height + scrollViewOriginalInset.top ? self.sk_height + scrollViewOriginalInset.top : insetT;
                tempScrollView.sk_insetTop = insetT;
                _insetTopDelta = scrollViewOriginalInset.top - insetT;
                return;
            }
            /// 跳转到下一个控制器时，contentInset可能会变
            scrollViewOriginalInset = tempScrollView.contentInset;
            /// 当前的contentOffset
            let offsetY: CGFloat = tempScrollView.sk_offsetY;
            /// 头部控件刚好出现的offsetY
            let happenOffsetY: CGFloat = -scrollViewOriginalInset.top;
            
            ///如果是向上滚动到看不见头部控件, 直接返回
            if offsetY > happenOffsetY {
                return;
            }
            
            /// 普通 和 即将刷新 的临界点
            let normalPullingOffsetY = happenOffsetY - self.sk_height;
            let tempPullingPercent = (happenOffsetY - offsetY) / self.sk_height;
            if tempScrollView.isDragging {
                pullingPercent = tempPullingPercent;
                if refreshState == .idle && offsetY < normalPullingOffsetY {
                    /// 转为即将刷新状态
                    refreshState = .pulling;
                } else if refreshState == .pulling && offsetY >= normalPullingOffsetY {
                    /// 转为普通状态
                    refreshState = .idle;
                }
            } else if refreshState == .pulling {
                /// 即将刷新 && 手松开开始刷新
                beginRefreshing();
            }else if tempPullingPercent < 1 {
                pullingPercent = tempPullingPercent;
            }
        }
    }

    override var refreshState: SKRefreshState {
        get {
            return super.refreshState;
        }
        set {
            if let tempScrollView = scrollView {
                let oldState = refreshState;
                if oldState == newValue {
                    return;
                }
                super.refreshState = newValue;
                
                if newValue == .idle {
                    if oldState != .refreshing {
                        return;
                    }
                    
                    /// 保存刷新时间
                    UserDefaults.standard.set(Date(), forKey: lastUpdatedTimeKey);
                    UserDefaults.standard.synchronize();
                    
                    /// 恢复inset和offset
                    UIView.animate(withDuration: SKRefreshSlowAnimationDuration, animations: {
                        tempScrollView.sk_insetTop += self._insetTopDelta;
                        /// 自动调整透明度
                        if self.isAutomaticallyChangeAlpha {
                            self.alpha = 0.0;
                        }
                        }, completion: { (finished) in
                            self.pullingPercent = 0.0;
                            if self.endRefreshingCompletionClosure != nil {
                                self.endRefreshingCompletionClosure!();
                            }
                    });
                }else if newValue == .refreshing {
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: SKRefreshFastAnimationDuration, animations: {
                            let tempTop = self.scrollViewOriginalInset.top + self.sk_height;
                            /// 增加滚动区域top
                            tempScrollView.sk_insetTop = tempTop;
                            /// 设置滚动位置
                            tempScrollView.setContentOffset(CGPoint(x: 0, y: -tempTop), animated: false);
                            }, completion: { (finished) in
                                self.executeRefreshingCallBack();
                        });
                    };
                }
            }
        }
    }
    
    override func endRefreshing() {
        DispatchQueue.main.async {
            self.refreshState = .idle;
        }
    }
    
    

}
