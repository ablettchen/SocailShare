//
//  ViewController.swift
//  SocailShare
//
//  Created by ablett on 08/25/2020.
//  Copyright (c) 2020 ablett. All rights reserved.
//

import UIKit
import SnapKit
import SocailShare

class ViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let _tableView = UITableView.init(frame: .zero, style: .plain)
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.tableFooterView = UIView()
        _tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return _tableView
    }()
    
    private lazy var dataSource:[String] = {
        return [
            "Share",
        ]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.addSubview(tableView)
                
        ShareManager.shared.socails.append(Social(type: .wechat, icon: UIImage(named: "social_wechat")!, appKey: "", appSecret: "", redirectURL: ""))
        ShareManager.shared.socails.append(Social(type: .wechatTimeline, icon: UIImage(named: "social_wechattimeline")!, appKey: "", appSecret: "", redirectURL: ""))
        ShareManager.shared.socails.append(Social(type: .QQ, icon: UIImage(named: "social_qq")!, appKey: "", appSecret: "", redirectURL: ""))
        ShareManager.shared.socails.append(Social(type: .QZone, icon: UIImage(named: "social_qzone")!, appKey: "", appSecret: "", redirectURL: ""))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.text = dataSource[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didSelect(index: indexPath.row)
    }
}


extension ViewController {
    
    // MARK: 点击事件
    private func didSelect(index: Int) {
        
        switch index {
        case 0:

            ShareManager.shared.show(resource: "hello") { (error, socail) in
                guard error == nil else {
                    debugPrint("\(error?.localizedDescription ?? "error")")
                    return
                }
                debugPrint("\(socail?.type.description ?? "") shared successfully")
            }
            
            break
        case 1:
            

            
            
            break
        default: break
        }
    }
    
}
