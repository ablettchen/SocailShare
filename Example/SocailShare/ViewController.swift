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

let universalLink = ""
let qqlink = ""

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
                
        ShareManager.shared.socails.append(Social(type: .wechat, icon: UIImage(named: wechatNamed)!, appKey: wechatKey, appSecret: wechatSecret, universalLink: universalLink))
        ShareManager.shared.socails.append(Social(type: .wechatTimeline, icon: UIImage(named: wechatTlNamed)!, appKey: wechatKey, appSecret: wechatSecret, universalLink: universalLink))
        ShareManager.shared.socails.append(Social(type: .QQ, icon: UIImage(named: qqNamed)!, appKey: qqKey, appSecret: qqSecret, universalLink: qqlink))
        ShareManager.shared.socails.append(Social(type: .QZone, icon: UIImage(named: qZoneNamed)!, appKey: qqKey, appSecret: qqSecret, universalLink: qqlink))
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

            let image = UIImage(named: "avatar")!
            let web = ResourceWeb(title: "SocailShare", description: "社会化分享工具", thumb: image, url: "https://github.com/ablettchen/SocailShare")
            
            ShareManager.shared.show(resource: web) { (error, socail) in
                guard error == nil else {
                    let text = "\(error?.localizedDescription ?? "error")"
                    debugPrint(text)
                    UIApplication.shared.keyWindow!.showToast(text)
                    return
                }
                let text = "\(socail?.type.description ?? "") shared successfully"
                debugPrint(text)
                UIApplication.shared.keyWindow!.showToast(text)
            }
            
            break
        case 1:
            

            
            
            break
        default: break
        }
    }
    
}
