//
//  SKRefreshBackFooter.swift
//  SKRefresh
//
//  Created by nachuan on 2016/11/16.
//  Copyright © 2016年 nachuan. All rights reserved.
//

import UIKit

class SKRefreshBackFooter: SKRefreshFooter {
    private var _lastRefreshCount: Int = 0;
    private var _lastBottomDelta: CGFloat = 0.0;
    
    var lastRefreshCount: Int {
        get {
            return _lastRefreshCount;
        }
        set {
            _lastRefreshCount = newValue;
        }
    }
    
    var lastBottomDelta: CGFloat {
        get {
            return _lastBottomDelta;
        }
        set {
            _lastBottomDelta = newValue;
        }
    }
    

    //MARK: - 重写父类方法
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview);
        if scrollView != nil {
            updateY(scrollView!);
        }
        
    }
    
    override func handleContentOffset(did change: [NSKeyValueChangeKey : Any], on scrollView: UIScrollView) {
        super.handleContentOffset(did: change, on: scrollView);
        /// 刷新直接返回
        if refreshState == .refreshing {
            return;
        }
        scrollViewOriginalInset = scrollView.contentInset;
        /// 当前的contentOffset
        let currentOffsetY: CGFloat = scrollView.sk_offsetY;
        /// 尾部控件刚好出现的offsetY
        let happenOffsetY: CGFloat = self.happenOffsetY();
        /// 如果是向下滚动到看不见尾部控件,直接返回
        if currentOffsetY <= happenOffsetY {
            return;
        }
        let pullingPercent: CGFloat = (currentOffsetY - happenOffsetY) / self.sk_height;
        /// 如果已全部加载,进设置pullingPercent,然后返回
        if refreshState == .noMoreData {
            self.pullingPercent = pullingPercent;
            return;
        }
        if scrollView.isDragging {
            self.pullingPercent = pullingPercent;
            /// 普通 和 即将刷新的临界点
            let normalTwoPullingOffsetY = happenOffsetY + self.sk_height;
            if refreshState == .idle && currentOffsetY > normalTwoPullingOffsetY {
                /// 转为即将刷新状态
                refreshState = .pulling;
            }else if refreshState == .pulling && currentOffsetY <= normalTwoPullingOffsetY {
                /// 转为普通状态
                refreshState = .idle;
            }
        }else if refreshState == .pulling {
            /// 即将刷新 && 手松开
            /// 开始刷新
            beginRefreshing();
        }else if pullingPercent < 1 {
            self.pullingPercent = pullingPercent;
        }
    }
    
    override func handleContentSize(did change: [NSKeyValueChangeKey : Any], on scrollView: UIScrollView) {
        super.handleContentSize(did: change, on: scrollView);
        
        updateY(scrollView);
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
            if scrollView != nil {
                /// 根据状态来设置属性
                if newValue == .noMoreData || newValue == .idle {
                    if oldState == .refreshing {
                        UIView.animate(withDuration: SKRefreshSlowAnimationDuration, animations: {
                                self.scrollView!.sk_insetBottom -= self.lastBottomDelta;
                                /// 设置透明度
                                if self.isAutomaticallyChangeAlpha {
                                    self.alpha = 0.0;
                                }
                            }, completion: { (finished: Bool) in
                                self.pullingPercent = 0.0;
                                if self.endRefreshingCompletionClosure != nil {
                                    self.endRefreshingCompletionClosure!();
                                }
                        });
                    }
                    let deltaH = heightForContentBreakView();
                    /// 刷新刚刚完毕
                    if oldState == .refreshing && deltaH > 0 && scrollView!.sk_totalDataCount != lastRefreshCount {
                        scrollView!.sk_offsetY = scrollView!.sk_offsetY;
                    }
                }else if newValue == .refreshing {
                    /// 记录刷新前的数量
                    lastRefreshCount = scrollView!.sk_totalDataCount;
                    UIView.animate(withDuration: SKRefreshFastAnimationDuration, animations: { 
                        var bottom: CGFloat = self.sk_height + self.scrollViewOriginalInset.bottom;
                        let deltaH: CGFloat = self.heightForContentBreakView();
                        if deltaH < 0 {
                            bottom -= deltaH;
                        }
                        self.lastBottomDelta = bottom - self.scrollView!.sk_insetBottom;
                        self.scrollView!.sk_insetBottom = bottom;
                        self.scrollView!.sk_offsetY = self.happenOffsetY() + self.sk_height;
                        }, completion: { (finished: Bool) in
                            self.executeRefreshingCallBack();
                    });
                }
            }
        }
    }
    
    override func endRefreshing() {
        super.endRefreshing();
        DispatchQueue.main.async {
            self.refreshState = .idle;
        };
    }
    
    override func endRefreshingWithNoMoreData() {
        super.endRefreshingWithNoMoreData();
        DispatchQueue.main.async {
            self.refreshState = .noMoreData;
        };
    }
    
    func updateY(_ scrollView: UIScrollView) -> Void {
        
        /// 内容高度
        let contentHeight = scrollView.sk_contentHeight + ignoredScrollViewContentInsetBottom;
        /// 表格的高度
        let scrollViewHeight = scrollView.sk_height - scrollViewOriginalInset.top - scrollViewOriginalInset.bottom + ignoredScrollViewContentInsetBottom;
        /// 设置位置和尺寸
        self.sk_y = max(contentHeight, scrollViewHeight);
    }
    
    /// 获得scrollView的内容 超出 view 的高度
    private func heightForContentBreakView() -> CGFloat {
        if scrollView != nil {
            let height: CGFloat = scrollView!.frame.size.height - scrollViewOriginalInset.bottom - scrollViewOriginalInset.top;
            return scrollView!.contentSize.height - height;
        }
        return 0;
    }
    
    /// 刚好看到上拉刷新控件时的contentOffset.y
    private func happenOffsetY() -> CGFloat {
        let deltaH: CGFloat = heightForContentBreakView();
        if deltaH > 0 {
            return deltaH - scrollViewOriginalInset.top;
        }else{
            return -scrollViewOriginalInset.top;
        }
        
    }
    
    
}
