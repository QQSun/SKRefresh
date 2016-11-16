//
//  SKRefreshAutoStateFooter.swift
//  SKRefresh
//
//  Created by nachuan on 2016/11/15.
//  Copyright © 2016年 nachuan. All rights reserved.
//

import UIKit

class SKRefreshAutoStateFooter: SKRefreshAutoFooter {
    
    //MARK: - 刷新状态相关
    /// 文字距离圈圈、箭头的距离
    private var _labelInsetLeft: CGFloat = 0.0;
    /// 显示刷新状态的label
    private var _stateLabel: UILabel!
    /// 刷新各个状态对应的文字
    private var _stateTitlesDic: [SKRefreshState : String]!
    /// 隐藏刷新状态的文字
    private var _refreshingTitleHidden: Bool = false;
    var stateLabel: UILabel {
        get {
            if _stateLabel == nil {
                _stateLabel = UILabel.sk_label();
                self.addSubview(_stateLabel!);
            }
            return _stateLabel!;
        }
    }
    var labelInsetLeft: CGFloat {
        get {
            return _labelInsetLeft;
        }
        set {
            _labelInsetLeft = newValue;
        }
    }
    private var stateTitlesDic: [SKRefreshState : String] {
        get {
            if _stateTitlesDic == nil {
                _stateTitlesDic = [SKRefreshState : String]();
            }
            return _stateTitlesDic!;
        }
        set {
            _stateTitlesDic = newValue;
        }
    }
    
    var isRefreshingTitleHidden: Bool {
        get {
            return _refreshingTitleHidden;
        }
        set {
            _refreshingTitleHidden = newValue;
        }
    }
    
    //MARK: - 重写父类
    override func prepare() {
        super.prepare();
        labelInsetLeft = SKRefreshLabelInsetLeft;
        setTitle(Bundle.sk_localizedString(for: SKRefreshAutoFooterIdleText), for: .idle);
        setTitle(Bundle.sk_localizedString(for: SKRefreshAutoFooterRefreshingText), for: .refreshing);
        setTitle(Bundle.sk_localizedString(for: SKRefreshAutoFooterNoMoreDataText), for: .noMoreData);
        /// 监听label
        stateLabel.isUserInteractionEnabled = true;
        stateLabel.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(stateLabelClick)));
    }
    
    override func placeSubviews() {
        super.placeSubviews();
        if stateLabel.constraints.count == 0 {
            stateLabel.frame = self.bounds;
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
            if isRefreshingTitleHidden && newValue == .refreshing {
                stateLabel.text = nil;
            }else{
                stateLabel.text = stateTitlesDic[newValue]
            }
        }
    }
    
    /// 设置state
    ///
    /// - parameter title: 刷新时的文字
    /// - parameter state: 刷新状态
    public func setTitle(_ title: String?, for state: SKRefreshState) -> Void {
        if title == nil {
            return;
        }
        stateTitlesDic[state] = title!
        stateLabel.text = stateTitlesDic[state];
    }
    
    @objc private func stateLabelClick() -> Void {
        if refreshState == .idle {
            beginRefreshing();
        }
    }
    

}
