//
//  SKRefreshStateHeader.swift
//  SKRefresh
//
//  Created by nachuan on 2016/11/14.
//  Copyright © 2016年 nachuan. All rights reserved.
//

import UIKit

typealias lastUpdatedTimeTextClosure = (_ lastUpdatedTime: Date) -> String

class SKRefreshStateHeader: SKRefreshHeader {

    //MARK: - 刷新时间相关
    /// 利用这个block来决定显示的更新时间文字
    private var _lastUpdatedTimeText: lastUpdatedTimeTextClosure?;
    /// 显示上一次刷新时间的label
    private var _lastUpdatedTimeLabel: UILabel!
    
    //MARK: - 刷新状态相关
    /// 文字距离圈圈、箭头的距离
    private var _labelInsetLeft: CGFloat = 0.0;
    /// 显示刷新状态的label
    private var _stateLabel: UILabel!
    /// 刷新各个状态对应的文字
    private var _stateTitlesDic: [SKRefreshState : String]!
    
    //MARK: - 刷新时间相关
    var lastUpdatedTimeText: lastUpdatedTimeTextClosure? {
        get {
            return _lastUpdatedTimeText;
        }
        set {
            _lastUpdatedTimeText = newValue;
        }
    }
    
    //MARK: - 刷新状态相关
    var labelInsetLeft: CGFloat {
        get {
            return _labelInsetLeft;
        }
        set {
            _labelInsetLeft = newValue;
        }
    }
    var lastUpdatedTimeLabel: UILabel {
        get {
            if _lastUpdatedTimeLabel == nil {
                _lastUpdatedTimeLabel = UILabel.sk_label();
                self.addSubview(_lastUpdatedTimeLabel!);
            }
            return _lastUpdatedTimeLabel!;
        }
    }
    
    var stateLabel: UILabel {
        get {
            if _stateLabel == nil {
                _stateLabel = UILabel.sk_label();
                self.addSubview(_stateLabel!);
            }
            return _stateLabel!;
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
    
    //MARK: - 重写父类方法
    override var lastUpdatedTimeKey: String {
        get {
            return super.lastUpdatedTimeKey;
        }
        set {
            super.lastUpdatedTimeKey = newValue;
            if lastUpdatedTimeLabel.isHidden {
                return;
            }
            let lastUpdatedTime = UserDefaults.standard.object(forKey: lastUpdatedTimeKey);
            if let tempLastUpdatedTime = lastUpdatedTime {
                if lastUpdatedTimeText != nil {
                    lastUpdatedTimeLabel.text = lastUpdatedTimeText!(tempLastUpdatedTime as! Date);
                    return;
                }
                
                let calendar = Calendar.current;
                let lastDateComponent = calendar.dateComponents([Calendar.Component.year, Calendar.Component.month, Calendar.Component.day, Calendar.Component.hour, Calendar.Component.minute], from: tempLastUpdatedTime as! Date);
                let currentDateComponent = calendar.dateComponents([Calendar.Component.year, Calendar.Component.month, Calendar.Component.day, Calendar.Component.hour, Calendar.Component.minute], from: Date.init());
                
                /// 格式化日期
                let formatter: DateFormatter = DateFormatter();
                var isToday: Bool = false;
                
                if lastDateComponent.day == currentDateComponent.day {
                    formatter.dateFormat = " HH:mm";
                    isToday = true;
                }else if lastDateComponent.year == currentDateComponent.year {
                    formatter.dateFormat = "MM-dd HH:mm";
                    isToday = false;
                }else{
                    formatter.dateFormat = "yyyy-MM-dd HH:mm";
                    isToday = false;
                }
                
                let time: String = formatter.string(from: tempLastUpdatedTime as! Date);
                
                /// 显示日期
                lastUpdatedTimeLabel.text = "\(Bundle.sk_localizedString(for: SKRefreshHeaderLastTimeText)!)" + "\(isToday ? Bundle.sk_localizedString(for: SKRefreshHeaderDateTodayText)! : "")" + "\(time)";
                
            }else{
                lastUpdatedTimeLabel.text = "\(Bundle.sk_localizedString(for: SKRefreshHeaderLastTimeText)!)" + "\(Bundle.sk_localizedString(for: SKRefreshHeaderNoneLastDateText)!)";
            }

        }
    }
    
    override func prepare() {
        super.prepare();
        labelInsetLeft = SKRefreshLabelInsetLeft;
        setTitle(Bundle.sk_localizedString(for: SKRefreshHeaderIdleText), for: .idle);
        setTitle(Bundle.sk_localizedString(for: SKRefreshHeaderRefreshingText), for: .refreshing);
        setTitle(Bundle.sk_localizedString(for: SKRefreshHeaderPullingText), for: .pulling);

    }
    
    override func placeSubviews() {
        super.placeSubviews();
        if stateLabel.isHidden {
            return;
        }
        
        let noConstrainsOnStateLabel: Bool = stateLabel.constraints.count == 0;
        if lastUpdatedTimeLabel.isHidden {
            if noConstrainsOnStateLabel {
                stateLabel.frame = self.bounds;
            }
        }else{
            let stateLabelH: CGFloat = self.sk_height * 0.5;
            if noConstrainsOnStateLabel {
                stateLabel.sk_x = 0;
                stateLabel.sk_y = 0;
                stateLabel.sk_width = self.sk_width;
                stateLabel.sk_height = stateLabelH;
            }
            
            if lastUpdatedTimeLabel.constraints.count == 0 {
                lastUpdatedTimeLabel.sk_x = 0;
                lastUpdatedTimeLabel.sk_y = stateLabelH;
                lastUpdatedTimeLabel.sk_width = self.sk_width;
                lastUpdatedTimeLabel.sk_height = self.sk_height - self.lastUpdatedTimeLabel.sk_y;
            }
        }
    }
    override var refreshState: SKRefreshState {
        get {
            return super.refreshState;
        }
        set {
            let oldState = refreshState;
            if oldState == newValue {
                return;
            }
            super.refreshState = newValue;
            
            stateLabel.text = stateTitlesDic[newValue];
            let tempKey = lastUpdatedTimeKey;
            lastUpdatedTimeKey = tempKey;
        }
    }
}














































