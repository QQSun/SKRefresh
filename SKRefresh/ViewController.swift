//
//  ViewController.swift
//  SKRefresh
//
//  Created by nachuan on 2016/11/14.
//  Copyright © 2016年 nachuan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tableView = UITableView();
        tableView.frame = self.view.bounds;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = UIColor.green;
        tableView.sk_header = SKRefreshNormalHeader.header(with: {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(3), execute: {
                tableView.sk_header!.endRefreshing();
            });
        });
        
//        tableView.sk_header = SKChiBaoZiHeader.header(with: {
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(3), execute: {
//                tableView.sk_header!.endRefreshing();
//            });
//            
//        });
        tableView.sk_header!.backgroundColor = .red;
//        tableView.sk_header = nil;
        
//        tableView.sk_footer = SKRefreshAutoNormalFooter.footer(with: { 
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(3), execute: {
//                tableView.sk_footer!.endRefreshing();
//            });
//        });
        tableView.sk_footer = SKRefreshAutoChiBaoZiFooter.footer(with: {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(3), execute: {
                tableView.sk_footer!.endRefreshing();
            });
        });
//        tableView.sk_footer = SKRefreshBackNormalFooter.footer(with: {
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(3), execute: {
//                tableView.sk_footer!.endRefreshing();
//            });
//        });
//        tableView.sk_footer = SKRefreshBackChiBaoZiFooter.footer(with: {
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(3), execute: {
//                tableView.sk_footer!.endRefreshing();
//            });
//        });
        tableView.sk_footer!.backgroundColor = .orange;
        self.view.addSubview(tableView);
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell");
        if  cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell");
        }
        cell!.textLabel?.text = "cell";
        return cell!;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

