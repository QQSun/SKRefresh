//
//  SKRefreshAutoFooter.swift
//  SKRefresh
//
//  Created by nachuan on 2016/11/15.
//  Copyright © 2016年 nachuan. All rights reserved.
//

import UIKit

class SKRefreshAutoFooter: SKRefreshFooter {
    /// 是否自动刷新,默认true
    private var _automaticallyRefresh: Bool = true;
    /// 当底部控件出现多少时就自动刷新.默认1.0也就是当底部控件完全出现时,才会自动刷新
    private var _triggerAutomaticallyRefreshPercent: CGFloat = 1.0;
    var isAutomaticallyRefresh: Bool {
        get {
            return _automaticallyRefresh;
        }
        set {
            _automaticallyRefresh = newValue;
        }
    }
    var triggerAutomaticallyRefreshPercent: CGFloat {
        get {
            return _triggerAutomaticallyRefreshPercent;
        }
        set {
            _triggerAutomaticallyRefreshPercent = newValue;
        }
    }
    
    //MARK: - 重写父类的方法
    override func prepare() {
        super.prepare();
        triggerAutomaticallyRefreshPercent = 1.0;
        isAutomaticallyRefresh = true;
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview);
        if newSuperview != nil && scrollView != nil {
            /// 新的控件
            if self.isHidden == false {
                scrollView!.sk_insetBottom += self.sk_height;
            }
            /// 设置位置
            self.sk_y = scrollView!.sk_contentHeight;
        }else if newSuperview == nil && scrollView != nil {
            /// 被移除了
            if self.isHidden == false {
                scrollView!.sk_insetBottom -= self.sk_height;
            }
        }
    }
    /// 监听相关
    override func handleContentSize(did change: [NSKeyValueChangeKey : Any], on scrollView: UIScrollView) {
        super.handleContentSize(did: change, on: scrollView);
        /// 设置位置
        self.sk_y = scrollView.sk_contentHeight;
    }
    
    override func handleContentOffset(did change: [NSKeyValueChangeKey : Any], on scrollView: UIScrollView) {
        super.handleContentOffset(did: change, on: scrollView);
        if refreshState != .idle || isAutomaticallyRefresh == false || self.sk_y == 0 {
            return;
        }
        if scrollView.sk_insetTop + scrollView.sk_contentHeight > scrollView.sk_height {/// 内容超过一个屏幕
            if scrollView.sk_offsetY >= scrollView.sk_contentHeight - scrollView.sk_height + self.sk_height * self.triggerAutomaticallyRefreshPercent + scrollView.sk_insetBottom - self.sk_height {
                /// 防止手松开时连续调用
                var oldString: String = "\(change[NSKeyValueChangeKey.oldKey]!)";
                var newString: String = "\(change[NSKeyValueChangeKey.newKey]!)";
                oldString = oldString.sk_substringWithOffset(start: 9, end: 0);
                newString = newString.sk_substringWithOffset(start: 9, end: 0);
                let new: CGPoint = CGPointFromString(newString);
                let old: CGPoint = CGPointFromString(oldString);
                if new.y <= old.y {
                    return;
                }
                /// 当底部刷新控件完全出现时才刷新
                beginRefreshing();
            }
        }
    }
    
    override func handlePanState(did change: [NSKeyValueChangeKey : Any], on scrollView: UIScrollView) {
        super.handlePanState(did: change, on: scrollView);
        if refreshState != .idle {
            return;
        }
        if scrollView.panGestureRecognizer.state == .ended {/// 手松开
            if (scrollView.sk_insetTop + scrollView.sk_contentHeight) <= scrollView.sk_height {/// 不够一个屏幕
                if scrollView.sk_offsetY >= -scrollView.sk_insetTop {/// 向上拽
                    beginRefreshing();
                }
            }else{/// 超出一个屏幕
                if scrollView.sk_offsetY >= (scrollView.sk_contentHeight + scrollView.sk_insetBottom - scrollView.sk_height) {
                    beginRefreshing();
                }
            }
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
            if newValue == .refreshing {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                    self.executeRefreshingCallBack();
                });
            }else if newValue == .noMoreData || newValue == .idle {
                if oldState == .refreshing {
                    if endRefreshingCompletionClosure != nil {
                        endRefreshingCompletionClosure!();
                    }
                }
            }
        }
    }
    
    override var isHidden: Bool {
        get {
            return super.isHidden;
        }
        set {
            let lastHidden = self.isHidden;
            super.isHidden = newValue;
            if lastHidden == false && newValue == true {
                refreshState = .idle;
                if scrollView != nil {
                    scrollView!.sk_insetBottom -= self.sk_height;
                }
            }else if lastHidden == true && newValue == false {
                if scrollView != nil {
                    scrollView!.sk_insetBottom += self.sk_height;
                    /// 设置位置
                    self.sk_y = scrollView!.sk_contentHeight;
                }
            } 
        }
    }
}





























