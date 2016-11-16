//
//  SKRefreshAutoChiBaoZiFooter.swift
//  SKRefresh
//
//  Created by nachuan on 2016/11/16.
//  Copyright © 2016年 nachuan. All rights reserved.
//

import UIKit

class SKRefreshAutoChiBaoZiFooter: SKRefreshAutoGifFooter {
    
    override class func footer(with refreshingClosure: SKRefreshComponentRefreshingClosure?) -> SKRefreshAutoChiBaoZiFooter {
        let footer = SKRefreshAutoChiBaoZiFooter();
        footer.refreshingClosure = refreshingClosure;
        return footer;
    }
    override func prepare() {
        super.prepare();
        var refreshingImages: [UIImage] = [UIImage]();
        for index in 1...3 {
//            print("dropdown_loading_0" + "\(index)");
            if let image: UIImage = UIImage(named: "dropdown_loading_0" + "\(index)") {
                
                refreshingImages.append(image);
            }
        }
        setImages(refreshingImages, duration: nil, for: .refreshing);
    }
    
    

}
