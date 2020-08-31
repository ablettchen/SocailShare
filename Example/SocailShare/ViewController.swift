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
import ATToast


let wechatKey = ""
let wechatSecret = ""
let qqKey = ""
let qqSecret = ""

let wechatNamed = "social_wechat"
let wechatTlNamed = "social_wechattimeline"
let qqNamed = "social_qq"
let qZoneNamed = "social_qzone"

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
                
        ShareManager.shared.socails.append(Social(type: .wechat, icon: UIImage(named: wechatNamed)!, appKey: wechatKey, appSecret: wechatSecret, universalLink: ""))
        ShareManager.shared.socails.append(Social(type: .wechatTimeline, icon: UIImage(named: wechatTlNamed)!, appKey: wechatKey, appSecret: wechatSecret, universalLink: ""))
        ShareManager.shared.socails.append(Social(type: .QQ, icon: UIImage(named: qqNamed)!, appKey: qqKey, appSecret: qqSecret, universalLink: ""))
        ShareManager.shared.socails.append(Social(type: .QZone, icon: UIImage(named: qZoneNamed)!, appKey: qqKey, appSecret: qqSecret, universalLink: ""))
        ShareManager.shared.register()
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

            let web = ResourceWeb(title: "hello", description: "desc", thumb: UIImage(named: "social_wechat")!, url: "https://www.baidu.com")
            ShareManager.shared.show(resource: web) { (error, socail) in
                guard error == nil else {
                    let text = "\(error?.localizedDescription ?? "error")"
                    debugPrint(text)
                    UIApplication.shared.keyWindow!.showToast(text)
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
