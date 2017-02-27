//
//  SKExtension.swift
//  SKCycleScrollView
//
//  Created by nachuan on 2016/10/29.
//  Copyright © 2016年 nachuan. All rights reserved.
//
import UIKit
import Foundation

let SKRefreshLabelFont: UIFont = UIFont.systemFont(ofSize: 14);
let SKRefreshLabelTextColor: UIColor = RGBA(r: 90, g: 90, b: 90, a: 1);

let SKRefreshLabelInsetLeft: CGFloat = 25;
let SKRefreshHeaderHeight: CGFloat = 54.0;
let SKRefreshFooterHeight: CGFloat = 44.0;
let SKRefreshFastAnimationDuration: TimeInterval = 0.25;
let SKRefreshSlowAnimationDuration: TimeInterval = 0.4;

let SKRefreshKeyPathContentOffset: String = "contentOffset";
let SKRefreshKeyPathContentInset: String = "contentInset";
let SKRefreshKeyPathContentSize: String = "contentSize";
let SKRefreshKeyPathPanState: String = "refreshState";


let SKRefreshHeaderLastUpdatedTimeKey: String = "SKRefreshHeaderLastUpdatedTimeKey";

let SKRefreshHeaderIdleText: String = "SKRefreshHeaderIdleText";
let SKRefreshHeaderPullingText: String = "SKRefreshHeaderPullingText";
let SKRefreshHeaderRefreshingText: String = "SKRefreshHeaderRefreshingText";

let SKRefreshAutoFooterIdleText: String = "SKRefreshAutoFooterIdleText";
let SKRefreshAutoFooterRefreshingText: String = "SKRefreshAutoFooterRefreshingText";
let SKRefreshAutoFooterNoMoreDataText: String = "SKRefreshAutoFooterNoMoreDataText";

let SKRefreshBackFooterIdleText: String = "SKRefreshBackFooterIdleText";
let SKRefreshBackFooterPullingText: String = "SKRefreshBackFooterPullingText";
let SKRefreshBackFooterRefreshingText: String = "SKRefreshBackFooterRefreshingText";
let SKRefreshBackFooterNoMoreDataText: String = "SKRefreshBackFooterNoMoreDataText";

let SKRefreshHeaderLastTimeText: String = "SKRefreshHeaderLastTimeText";
let SKRefreshHeaderDateTodayText: String = "SKRefreshHeaderDateTodayText";
let SKRefreshHeaderNoneLastDateText: String = "SKRefreshHeaderNoneLastDateText";



func RGBA(r:Float, g: Float, b:Float, a:Float) -> UIColor {
    return UIColor.init(colorLiteralRed: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a);
}

// MARK: - 扩展NSObject
extension NSObject {
    class func exchangeInstance(method1: Selector, method2: Selector) -> Void {
        method_exchangeImplementations(class_getInstanceMethod(UIScrollView.self, method1), class_getInstanceMethod(NSObject.self, method2));
    }
    class func exchangeClass(method1: Selector, method2: Selector) -> Void {
        method_exchangeImplementations(class_getClassMethod(UIScrollView.self, method1), class_getClassMethod(NSObject.self, method2));
    }
}


// MARK: - 扩展String
extension String {
    
    /// 返回子串
    ///
    /// - parameter offset: 距父串startIndex的偏移字符个数
    /// - parameter end:    距父串endIndex的偏移字符个数.一般为负数.即小于父串的范围
    ///
    /// - returns: 返回截取后的子串
    func sk_substringWithOffset(start offset: Int, end: Int) -> String {
        var tempString = self.substring(from: self.index(self.startIndex, offsetBy: offset));
        tempString = tempString.substring(to: tempString.index(tempString.endIndex, offsetBy: end));
        return tempString;
    }
}

// MARK: - 扩展UIView
extension UIView {
    var sk_width: CGFloat {
        get {
            return self.frame.size.width;
        }
        set {
            var tempFrame = self.frame;
            tempFrame.size.width = newValue;
            self.frame = tempFrame;
        }
    }
    
    var sk_height: CGFloat {
        get {
            return self.frame.size.height;
        }
        set {
            var tempFrame = self.frame;
            tempFrame.size.height = newValue;
            self.frame = tempFrame;
        }
    }
    
    var sk_x: CGFloat {
        get {
            return self.frame.origin.x;
        }
        set {
            var tempFrame = self.frame;
            tempFrame.origin.x = newValue;
            self.frame = tempFrame;
        }
    }
    
    var sk_y: CGFloat {
        get {
            return self.frame.origin.y;
        }
        set {
            var tempFrame = self.frame;
            tempFrame.origin.y = newValue;
            self.frame = tempFrame;
        }
    }
    
    var sk_centerX: CGFloat {
        get {
            return self.center.x;
        }
        set {
            var tempCenter = self.center;
            tempCenter.x = newValue;
            self.center = tempCenter;
        }
    }
    
    var sk_centerY: CGFloat {
        get {
            return self.center.y;
        }
        set {
            var tempCenter = self.center;
            tempCenter.y = newValue;
            self.center = tempCenter;
        }
    }
    
    var sk_size: CGSize {
        get {
            return self.frame.size;
        }
        set {
            var tempFrame = self.frame;
            tempFrame.size = newValue;
            self.frame = tempFrame;
        }
    }
    
    
    
    
    
    
    /// getter
    ///
    /// - parameter base:        属性所属的对象.一般为self
    /// - parameter key:         属性的键地址
    /// - parameter initialiser: 初始值设置
    ///
    /// - returns: 属性值
    func sk_getAssociatedObject<ValueType: Any>(base: AnyObject, key: UnsafePointer<UInt8>, initialiser:() -> ValueType) -> ValueType {
        if let associated = objc_getAssociatedObject(base, key) as? ValueType {
            return associated;
        }
        let associated = initialiser();
        objc_setAssociatedObject(base, key, associated, .OBJC_ASSOCIATION_RETAIN);
        return associated;
        
    }
//    func sk_getAssociatedObject<ValueType: Any>(base: AnyObject, key: UnsafePointer<UInt8>, policy: objc_AssociationPolicy, initialiser:() -> ValueType) -> ValueType {
//        if let associated = objc_getAssociatedObject(base, key) as? ValueType {
//            return associated;
//        }
//        let associated = initialiser();
//        objc_setAssociatedObject(base, key, associated, policy);
//        return associated;
//        
//    }
    
    
    /// setter
    ///
    /// - parameter base:  属性所属对象
    /// - parameter key:   属性的键地址
    /// - parameter value: 属性值
    func sk_setAssociatedObject<ValueType: Any>(base: AnyObject, key: UnsafePointer<UInt8>, value: ValueType) {
        objc_setAssociatedObject(base, key, value, .OBJC_ASSOCIATION_RETAIN);
    }

//    func sk_setAssociatedObject<ValueType: Any>(base: AnyObject, key: UnsafePointer<UInt8>, value: ValueType, policy: objc_AssociationPolicy) {
//        objc_setAssociatedObject(base, key, value, policy);
//    }
    
    
}


// MARK: - UIScrollView属性设置相关
extension UIScrollView {
    
    var sk_insetTop: CGFloat {
        get {
            return self.contentInset.top;
        }
        set {
            var tempInset:UIEdgeInsets = self.contentInset;
            tempInset.top = newValue;
            self.contentInset = tempInset;
        }
    }
    var sk_insetLeft: CGFloat {
        get {
            return self.contentInset.left;
        }
        set {
            var tempInset:UIEdgeInsets = self.contentInset;
            tempInset.left = newValue;
            self.contentInset = tempInset;
        }
    }
    var sk_insetBottom: CGFloat {
        get {
            return self.contentInset.bottom;
        }
        set {
            var tempInset:UIEdgeInsets = self.contentInset;
            tempInset.bottom = newValue;
            self.contentInset = tempInset;
        }
    }
    var sk_insetRight: CGFloat {
        get {
            return self.contentInset.right;
        }
        set {
            var tempInset:UIEdgeInsets = self.contentInset;
            tempInset.right = newValue;
            self.contentInset = tempInset;
        }
    }
    
    
    var sk_contentWidth: CGFloat {
        get {
            return self.contentSize.width;
        }
        set {
            var tempSize: CGSize = self.contentSize;
            tempSize.width = newValue;
            self.contentSize = tempSize;
        }
    }
    var sk_contentHeight: CGFloat {
        get {
            return self.contentSize.height;
        }
        set {
            var tempSize: CGSize = self.contentSize;
            tempSize.height = newValue;
            self.contentSize = tempSize;
        }
    }
    
    var sk_offsetY: CGFloat {
        get {
            return self.contentOffset.y;
        }
        set {
            var tempOffset: CGPoint = self.contentOffset;
            tempOffset.y = newValue;
            self.contentOffset = tempOffset;
            
        }
    }
    
    var sk_offsetX: CGFloat {
        get {
            return self.contentOffset.x;
        }
        set {
            var tempOffset: CGPoint = self.contentOffset;
            tempOffset.x = newValue;
            self.contentOffset = tempOffset;
            
        }
    }
    
}



// MARK: - 刷新相关
var SKRefreshHeaderKey: UInt8 = 1;
var SKRefreshFooterKey: UInt8 = 2;
var SKRefreshReloadDataClosureKey: UInt8 = 3;
extension UIScrollView {
    
    /// header
    var sk_header: SKRefreshHeader? {
        get {
            return sk_getAssociatedObject(base: self, key: &SKRefreshHeaderKey, initialiser: {
                return nil;
            });
        }
        set {
            if sk_header != newValue {
                if sk_header != nil {
                    sk_header!.removeFromSuperview();
                    sk_header!.removeObservers();/// 在父视图上移除时需要移除监听.否则会引起crash
                }
                sk_setAssociatedObject(base: self, key: &SKRefreshHeaderKey, value: newValue);
                if sk_header != nil {
                    self.addSubview(sk_header!);
                }
            }
            
        }
    }
    
    var sk_footer: SKRefreshFooter? {
        get {
            return sk_getAssociatedObject(base: self, key: &SKRefreshFooterKey, initialiser: {
                return nil;
            });
        }
        set {
            if sk_footer != newValue {
                if sk_footer != nil {
                    sk_footer!.removeFromSuperview();
                    sk_header!.removeObservers();
                }
                sk_setAssociatedObject(base: self, key: &SKRefreshFooterKey, value: newValue);
                if sk_footer != nil {
                    self.addSubview(sk_footer!);
                }
            }
        }
    }
    //MARK: - 数据相关
    var sk_totalDataCount: Int {
        get {
            var totalCount = 0;
            if let tableView = self as? UITableView {
                for index in 0..<tableView.numberOfSections {
                    totalCount += tableView.numberOfRows(inSection: index);
                }
            }else if let collection = self as? UICollectionView {
                for index in 0..<collection.numberOfSections {
                    totalCount += collection.numberOfItems(inSection: index);
                }
            }
            return totalCount;
            
        }
    }
    typealias SKReloadDataClosure = (_ num: Int) -> Void;
    var sk_reloadDataClosure: SKReloadDataClosure? {
        get {
            return sk_getAssociatedObject(base: self, key: &SKRefreshReloadDataClosureKey, initialiser: {
                return nil;
            });
        }
        set {
            sk_setAssociatedObject(base: self, key: &SKRefreshReloadDataClosureKey, value: newValue);
        }
    }
    
    func executeReloadDataClosure() -> Void {
        if sk_reloadDataClosure == nil {
            return;
        }else{
            sk_reloadDataClosure!(sk_totalDataCount);
        }
    }
    
    
    
    
}

// MARK: - 扩展UITableView
extension UITableView {
    
    override open class func initialize() {
        super.initialize();
        exchangeInstance(method1: #selector(reloadData), method2: #selector(sk_reloadData));
    }
    
    func sk_reloadData() -> Void {
        sk_reloadData();
        executeReloadDataClosure();
    }
    
}

// MARK: - 扩展UICollectionView
extension UICollectionView {
    
    override open class func initialize() {
        super.initialize();
        exchangeInstance(method1: #selector(reloadData), method2: #selector(sk_reloadData));
    }
    
    func sk_reloadData() -> Void {
        sk_reloadData();
        executeReloadDataClosure();
    }
    
}




// MARK: - 扩展Bundle
extension Bundle {
    class func sk_refreshBundle() -> Bundle? {
        var refreshBundle: Bundle? = nil;
        let path: String? = Bundle.init(for: SKRefreshComponent.self).path(forResource: "SKRefresh", ofType: "bundle");
        if path != nil {
            refreshBundle = Bundle.init(path: path!);
        }
        return refreshBundle;
    }
    
    class func sk_arrowImage() -> UIImage? {
        let path = sk_refreshBundle()?.path(forResource: "arrow@2x", ofType: "png");
        if path != nil {
            let arrowImage = UIImage(contentsOfFile: path!)?.withRenderingMode(.alwaysTemplate);
            return arrowImage;
        }
        return nil;
    }
    
    class func sk_localizedString(for key: String) -> String? {
        return sk_localizedString(for: key, value: nil);
    }
    
    class func sk_localizedString(for key: String, value: String?) -> String? {
        var bundle: Bundle?  //此处应该为静态变量
        if bundle == nil {
            if var language = NSLocale.preferredLanguages.first {
                if language.hasPrefix("en") {
                    language = "en";
                }else if language.hasPrefix("zh") {
                    if language.range(of: "Hans") != nil {
                        language = "zh-Hans";
                    }else{
                        language = "zh-Hant";
                    }
                }else{
                    language = "en";
                }
                if let path = Bundle.sk_refreshBundle()?.path(forResource: language, ofType: "lproj") {
                    bundle = Bundle(path: path);
                }
            }
        }
        let tempValue = bundle!.localizedString(forKey: key, value: value, table: nil);
        return Bundle.main.localizedString(forKey: key, value: tempValue, table: nil);
    }
}


// MARK: - 扩展UILabel
extension UILabel {
    class func sk_label() -> UILabel {
        let label: UILabel = UILabel.init();
        label.font = SKRefreshLabelFont;
        label.textColor = SKRefreshLabelTextColor;
        label.autoresizingMask = UIViewAutoresizing.flexibleWidth;
        label.textAlignment = NSTextAlignment.center;
        label.backgroundColor = UIColor.clear;
        return label;
    }
    
    var sk_textWidth: CGFloat {
        var stringWidth: CGFloat = 0;
        let size = CGSize.init(width: CGFloat(self.sk_width - 5), height: CGFloat(MAXFLOAT));
        if self.text != nil && self.text!.characters.count > 0{
            stringWidth = (self.text! as NSString).boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName : self.font], context: nil).size.width;
        }
        return stringWidth;
    }
}


























