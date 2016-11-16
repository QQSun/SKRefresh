//
//  SKRefreshComponent.swift
//  SKRefresh
//
//  Created by nachuan on 2016/11/14.
//  Copyright © 2016年 nachuan. All rights reserved.
//

import UIKit
/// 刷新控件的状态
///
/// - idle:        闲置
/// - pulling:     松开即可刷新
/// - refreshing:  刷新中
/// - willRefresh: 即将刷新
/// - noMoreData:  没有更多数据
enum SKRefreshState {
    case idle
    case pulling
    case refreshing
    case willRefresh
    case noMoreData
}


/// 进入刷新状态回调
typealias SKRefreshComponentRefreshingClosure = () -> Void;

/// 开始刷新后的回调
typealias SKRefreshComponentBeginRefreshingCompletionClosure = () -> Void;

/// 结束刷新后的回调
typealias SKRefreshComponentEndRefreshingCompletionClosure = () -> Void;

/// 刷新协议
protocol SKRefreshComponentDelegate: class {
    func refreshingAction() -> Void;
}

class SKRefreshComponent: UIView {



    /// 记录起始scrollView刚开始时的inset
    private var _scrollViewOriginalInset: UIEdgeInsets = .zero;
    /// 记录父控件
    private var _scrollView: UIScrollView?
    private var _pan: UIGestureRecognizer?
    /// 拉拽的百分比
    private var _pullingPercent: CGFloat = 0;
    /// 根据拖拽比例自动切换透明度
    private var _automaticallyChangeAlpha: Bool = false;
    //MARK: - 刷新状态控制
    /// 正在刷新回调
    private var _refreshingClosure: SKRefreshComponentRefreshingClosure?
    /// 开始刷新后的回调(进入刷新状态后的回调)
    private var _beginRefreshingCompletionClosure: SKRefreshComponentBeginRefreshingCompletionClosure?
    /// 结束刷新的回调
    private var _endRefreshingCompletionClosure: SKRefreshComponentEndRefreshingCompletionClosure?
    private var _refreshState: SKRefreshState = .idle;
    
    
    
    
    
    
    var scrollViewOriginalInset: UIEdgeInsets {
        get {
            return _scrollViewOriginalInset;
        }
        set {
            _scrollViewOriginalInset = newValue;
        }
    }
    private(set) var scrollView: UIScrollView? {
        get {
            return _scrollView;
        }
        set {
            _scrollView = newValue;
        }
    }
    private var pan: UIGestureRecognizer? {
        get {
            return _pan;
        }
        set {
            _pan = newValue;
        }
    }
    public var pullingPercent: CGFloat {
        get {
            return _pullingPercent;
        }
        set {
            _pullingPercent = newValue;
            if isRefreshing() {
                return;
            }
            if isAutomaticallyChangeAlpha {
                self.alpha = pullingPercent;
            }
        }
    }
    public var isAutomaticallyChangeAlpha: Bool {
        get {
            return _automaticallyChangeAlpha;
        }
        set {
            _automaticallyChangeAlpha = newValue;
        }
    }
    public var refreshingClosure: SKRefreshComponentRefreshingClosure? {
        get {
            return _refreshingClosure;
        }
        set {
            _refreshingClosure = newValue;
            if isRefreshing() {
                return;
            }
            if isAutomaticallyChangeAlpha {
                self.alpha = pullingPercent;
            }else{
                self.alpha = 1;
            }
            
        }
    }
    public var beginRefreshingCompletionClosure: SKRefreshComponentBeginRefreshingCompletionClosure? {
        get {
            return _beginRefreshingCompletionClosure;
        }
        set {
            _beginRefreshingCompletionClosure = newValue;
        }
    }
    public var endRefreshingCompletionClosure: SKRefreshComponentEndRefreshingCompletionClosure? {
        get {
            return _endRefreshingCompletionClosure;
        }
        set {
            _endRefreshingCompletionClosure = newValue;
        }
    }
    public var refreshState: SKRefreshState {
        get {
            return _refreshState;
        }
        set {
            _refreshState = newValue;
            /// 加入主队列的目的是等setState:方法调用完毕、设置完文字后再去布局子控件
            DispatchQueue.main.async {
                self.setNeedsLayout();
            }
        }
    }
    public weak var delegate: SKRefreshComponentDelegate?
    

    
    
    //MARK: - 初始化相关
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        prepare();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        prepare();
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview);
        if let superview = newSuperview {
            if !(superview is UIScrollView) {
                return;
            }
            /// 旧的父控件移除监听
            removeObservers();
            self.sk_width = superview.sk_width;
            self.sk_x = 0;
            /// 记录UIScrollView
            scrollView = superview as? UIScrollView;
            /// 设置永远支持弹簧效果
            scrollView!.alwaysBounceVertical = true;
            /// 记录UIScrollView最开始的contentInset
            scrollViewOriginalInset = scrollView!.contentInset;
            /// 添加监听
            addObservers();
        }
        
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect);
        if refreshState == .willRefresh {
            refreshState = .refreshing;
        }
    }
    
    override func layoutSubviews() {
        placeSubviews();
        super.layoutSubviews();
    }
    
    func prepare() -> Void {
        self.autoresizingMask = .flexibleWidth;
        self.backgroundColor = .clear;
    }
    /// 摆放子控件
    func placeSubviews() -> Void {
    }
    
    //MARK: - 刷新相关方法
    /// 触发刷新
    func executeRefreshingCallBack() -> Void {
        // MARK: - 该方法交给子类实现
        DispatchQueue.main.async {
            if self.refreshingClosure != nil {
                self.refreshingClosure!();
            }
            
            if self.delegate != nil {
                //MARK: - 这里运用运行时调用 貌似swift无法实现消息转发.后期更改为代理回调
                self.delegate!.refreshingAction();
            }
            
            if self.beginRefreshingCompletionClosure != nil {
                self.beginRefreshingCompletionClosure!();
            }
            
        };
    }
    
    ///开始刷新
    public func beginRefreshing() -> Void {
        UIView.animate(withDuration: SKRefreshFastAnimationDuration) {
            self.alpha = 1.0;
        };
        
        pullingPercent = 1.0;
        /// 只要正在刷新.就完全显示
        if self.window != nil {
            refreshState = .refreshing;
        }else{
            /// 预防正在刷新中时，调用本方法使得header inset回置失败
            if refreshState != .refreshing {
                refreshState = .willRefresh;
                /// 刷新(预防从另一个控制器回到这个控制器的情况，回来要重新刷新一下)
                setNeedsDisplay();
            }
        }
    }
    
    /// 开始刷新
    ///
    /// - parameter completionClosure: 开始刷新回调闭包
    public func beginRefreshing(with completionClosure: @escaping SKRefreshComponentBeginRefreshingCompletionClosure) -> Void {
        beginRefreshingCompletionClosure = completionClosure;
        beginRefreshing();
    }
    
    /// 结束刷新
    public func endRefreshing() -> Void {
        refreshState = .idle;
    }
    
    /// 结束刷新回调
    ///
    /// - parameter completionClosure: 结束刷新回调闭包
    public func endRefreshing(with completionClosure: @escaping SKRefreshComponentEndRefreshingCompletionClosure) -> Void {
        endRefreshingCompletionClosure = completionClosure;
        endRefreshing();
    }
    
    /// 获取刷新状态
    public func isRefreshing() -> Bool {
        return refreshState == .refreshing || refreshState == .willRefresh;
    }
    
    //MARK: - 监听相关
    /// 添加观察者
    private func addObservers() -> Void {
        let options: NSKeyValueObservingOptions = [.new, .old];
        if scrollView != nil {
            scrollView!.addObserver(self, forKeyPath: SKRefreshKeyPathContentOffset, options: options, context: nil);
            scrollView!.addObserver(self, forKeyPath: SKRefreshKeyPathContentSize, options: options, context: nil);
            pan = scrollView!.panGestureRecognizer;
            pan!.addObserver(self, forKeyPath: SKRefreshKeyPathPanState, options: options, context: nil);
        }
    }
    
    /// 移除观察者
    func removeObservers() -> Void {
        if scrollView != nil {
            scrollView!.removeObserver(self, forKeyPath: SKRefreshKeyPathContentOffset);
            scrollView!.removeObserver(self, forKeyPath: SKRefreshKeyPathContentSize);
        }
        if pan != nil {
            pan!.removeObserver(self, forKeyPath: SKRefreshKeyPathPanState);
            pan = nil;
        }
    }
    
    //MARK: - 监听回调
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if change != nil && scrollView != nil {
            if !self.isUserInteractionEnabled {
                return;
            }
            
            //看不见也需要处理
            if keyPath == SKRefreshKeyPathContentSize {
                handleContentSize(did: change!, on: scrollView!);
            }
            
            //看不见就不需要处理了
            if self.isHidden {
                return;
            }
            
            if keyPath == SKRefreshKeyPathContentOffset {
                handleContentOffset(did: change!, on: scrollView!);
            }else if keyPath == SKRefreshKeyPathContentInset {
                handleContentInset(did: change!, on: scrollView!);
            }else if keyPath == SKRefreshKeyPathPanState {
                handlePanState(did: change!, on: scrollView!);
            }
        }
    }
    
    //MARK: - 用于处理滑动回调的方法
    /// 当scrollView的contentOffset发生改变的时候调用
    public func handleContentOffset(did change: [NSKeyValueChangeKey : Any], on scrollView: UIScrollView) -> Void {
        //        print("\(change)" + "offset");
    }
    /// 当scrollView的contentInset发生改变的时候调用
    public func handleContentInset(did change: [NSKeyValueChangeKey : Any], on scrollView: UIScrollView) -> Void {
//        print("\(change)" + "inset");
    }
    /// 当scrollView的contentSize发生改变的时候调用
    
    public func handleContentSize(did change: [NSKeyValueChangeKey : Any], on scrollView: UIScrollView) -> Void {
//        print("\(change)" + "size");
    }
    /// 当scrollView的拖拽状态发生改变的时候调用
    
    public func handlePanState(did change: [NSKeyValueChangeKey : Any], on scrollView: UIScrollView ) -> Void {
//        print("\(change)" + "state");
    }


}
