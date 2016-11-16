//
//  SKRefreshBackGifFooter.swift
//  SKRefresh
//
//  Created by nachuan on 2016/11/16.
//  Copyright © 2016年 nachuan. All rights reserved.
//

import UIKit

class SKRefreshBackGifFooter: SKRefreshBackStateFooter {

    /// 显示GIF动画的视图
    private var _gifView: UIImageView!
    /// 所有状态对应的动画图片
    private var _stateImages: [SKRefreshState : [UIImage]]!
    /// 所有状态对应的动画时间
    private var _stateDurations: [SKRefreshState : TimeInterval]!
    var gifView: UIImageView {
        get {
            if _gifView == nil {
                _gifView = UIImageView();
                self.addSubview(_gifView!);
            }
            return _gifView!
        }
    }
    
    var stateImages: [SKRefreshState : [UIImage]] {
        get {
            if _stateImages == nil {
                _stateImages = [SKRefreshState : [UIImage]]();
            }
            return _stateImages;
        }
        set {
            _stateImages = newValue;
        }
    }
    var stateDurations: [SKRefreshState : TimeInterval] {
        get {
            if _stateDurations == nil {
                _stateDurations = [SKRefreshState : TimeInterval]();
            }
            return _stateDurations;
        }
        set {
            _stateDurations = newValue;
        }
    }
    //MARK: - 重写父类方法
    override func prepare() {
        super.prepare();
        labelInsetLeft = 20;
    }

    override var pullingPercent: CGFloat {
        get {
            return super.pullingPercent;
        }
        set {
            super.pullingPercent = newValue;
            if let images = stateImages[.idle] {
                if refreshState != .idle || images.count == 0 {
                    return;
                }
                gifView.stopAnimating();
                var index: Int = Int(CGFloat(images.count) * pullingPercent);
                if index >= images.count {
                    index = images.count - 1;
                }
                gifView.image = images[index];
            }
        }
    }
    
    override func placeSubviews() {
        super.placeSubviews();
        if gifView.constraints.count != 0 {
            return;
        }
        gifView.frame = self.bounds;
        if stateLabel.isHidden {
            gifView.contentMode = .center;
        }else{
            gifView.contentMode = .right;
            gifView.sk_width = self.sk_width * 0.5 - labelInsetLeft - stateLabel.sk_textWidth * 0.5;
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
            if newValue == .refreshing || newValue == .pulling {
                if let images = stateImages[newValue] {
                    if images.count == 0 {
                        return;
                    }
                    gifView.stopAnimating();
                    gifView.isHidden = false;
                    if images.count == 1 {
                        gifView.image = images.last;
                    }else{
                        gifView.animationImages = images;
                        gifView.animationDuration = stateDurations[newValue]!;
                        gifView.startAnimating();
                    }
                }
            }else if newValue == .noMoreData{
                gifView.stopAnimating();
                gifView.isHidden = true;
            }else if newValue == .idle {
                gifView.stopAnimating();
                gifView.isHidden = false;
            }
        }
    }
    
    /// 设置state状态下的动画图片images 动画持续时间duration
    func setImages(_ images: [UIImage]?, duration: TimeInterval?, for state: SKRefreshState) -> Void {
        if images == nil {
            return;
        }
        if duration == nil {
            stateDurations[state] = Double(images!.count) * 0.1;
            
        }else{
            stateDurations[state] = duration!;
        }
        stateImages[state] = images!;
        if let image = images!.first {
            if image.size.height > self.sk_height {
                self.sk_height = image.size.height;
            }
        }
    }


}
