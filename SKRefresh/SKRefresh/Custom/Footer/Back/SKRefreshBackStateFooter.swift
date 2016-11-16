//
//  SKRefreshBackStateFooter.swift
//  SKRefresh
//
//  Created by nachuan on 2016/11/16.
//  Copyright © 2016年 nachuan. All rights reserved.
//

import UIKit

class SKRefreshBackStateFooter: SKRefreshBackFooter {

    //MARK: - 刷新状态相关
    /// 文字距离圈圈、箭头的距离
    private var _labelInsetLeft: CGFloat = 0.0;
    /// 显示刷新状态的label
    private var _stateLabel: UILabel!
    /// 刷新各个状态对应的文字
    private var _stateTitlesDic: [SKRefreshState : String]!
//    /// 隐藏刷新状态的文字
//    private var _refreshingTitleHidden: Bool = false;
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
    
    //MARK: - 重写父类
    override func prepare() {
        super.prepare();
        labelInsetLeft = SKRefreshLabelInsetLeft;
        setTitle(Bundle.sk_localizedString(for: SKRefreshBackFooterIdleText), for: .idle);
        setTitle(Bundle.sk_localizedString(for: SKRefreshBackFooterPullingText), for: .pulling);
        setTitle(Bundle.sk_localizedString(for: SKRefreshBackFooterRefreshingText), for: .refreshing);
        setTitle(Bundle.sk_localizedString(for: SKRefreshBackFooterNoMoreDataText), for: .noMoreData);
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
            stateLabel.text = stateTitlesDic[newValue]
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
    
    public func title(for state: SKRefreshState) -> String {
        return stateTitlesDic[state]!;
    }
}
