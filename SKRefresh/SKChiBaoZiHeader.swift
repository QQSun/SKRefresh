//
//  SKChiBaoZiHeader.swift
//  SKRefresh
//
//  Created by nachuan on 2016/11/15.
//  Copyright © 2016年 nachuan. All rights reserved.
//

import UIKit

class SKChiBaoZiHeader: SKRefreshGifHeader {

    override func prepare() {
        super.prepare();
        
        var idleImages: [UIImage] = [UIImage]();
        for index in 1...60 {
            if let image: UIImage = UIImage(named: "dropdown_anim__000" + "\(index)") {
//                print("dropdown_anim__000" + "\(index)");
                idleImages.append(image);
            }
        }
        setImages(idleImages, duration: nil, for: .idle);
        
        
        var refreshingImages: [UIImage] = [UIImage]();
        for index in 1...3 {
//            print("dropdown_loading_0" + "\(index)");
            if let image: UIImage = UIImage(named: "dropdown_loading_0" + "\(index)") {
                
                refreshingImages.append(image);
            }
        }
        setImages(refreshingImages, duration: nil, for: .refreshing);
        setImages(refreshingImages, duration: nil, for: .pulling);
    }
    
    override class func header(with refreshingClosure:  SKRefreshComponentRefreshingClosure?) -> SKChiBaoZiHeader {
        let header = SKChiBaoZiHeader();
        header.refreshingClosure = refreshingClosure;
        return header;
    }
    

}
