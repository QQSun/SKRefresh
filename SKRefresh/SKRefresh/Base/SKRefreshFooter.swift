//
//  SKRefreshFooter.swift
//  SKRefresh
//
//  Created by nachuan on 2016/11/15.
//  Copyright © 2016年 nachuan. All rights reserved.
//

import UIKit

class SKRefreshFooter: SKRefreshComponent {
    /// 忽略多少scrollView的contentInset的bottom
    private var _ignoredScrollViewContentInsetBottom: CGFloat = 0.0;
    /// 自动根据有无数据来显示和隐藏（有数据就显示，没有数据隐藏。默认是NO）
    private var _automaticallyHidden: Bool = false;
    
    var ignoredScrollViewContentInsetBottom: CGFloat {
        get {
            return _ignoredScrollViewContentInsetBottom;
        }
        set {
            _ignoredScrollViewContentInsetBottom = newValue;
        }
    }
    
    var isAutomaticallyHidden: Bool {
        get {
            return _automaticallyHidden;
        }
        set {
            _automaticallyHidden = newValue;
        }
    }
    
    //MARK: - 类方法
    /// 创建header
    ///
    /// - parameter refreshingClosure: 刷新时回调闭包
    ///
    /// - returns: 刷新控件
    class func footer(with refreshingClosure: SKRefreshComponentRefreshingClosure?) -> SKRefreshFooter {
        fatalError("子类需要重写该方法.并返回子类对象实例.重写时请不要调用父类方法");
    }
    /// 创建header
    ///
    /// - parameter delegate: 刷新代理
    ///
    /// - returns: 刷新控件
    class func footer(with delegate: SKRefreshComponentDelegate?) -> SKRefreshFooter{
        fatalError("子类需要重写该方法.并返回子类对象实例.重写时请不要调用父类方法");
    }
    
    //MARK: - 重写父类
    override func prepare() {
        super.prepare();
        /// 设置自己的高度
        self.sk_height = SKRefreshFooterHeight;
        /// 默认不会自动隐藏
        isAutomaticallyHidden = false;
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview);
        if newSuperview != nil && scrollView != nil {
            if scrollView is UITableView || scrollView is UICollectionView {
                scrollView!.sk_reloadDataClosure = {
                    (totalDataCount: Int) in
                        if self.isAutomaticallyHidden == true {
                            self.isHidden = totalDataCount == 0;
                        }
                };
            }
        }
    }
    
    /// 提示没有更多的数据
    func endRefreshingWithNoMoreData() -> Void {
        refreshState = .noMoreData;
    }
    
    /// 重置没有更多的数据（消除没有更多数据的状态）
    func resetNoMoreData() -> Void {
        refreshState = .idle;
    }
    

}
