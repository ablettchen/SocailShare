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
let qqKey = ""

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
        _tableView.backgroundColor = .clear
        _tableView.backgroundView = UIImageView(image: UIImage(named: "background_portrait"))
        return _tableView
    }()
    
    private lazy var dataSource:[String] = {
        return [
            "分享事件",
            "分享弹窗",
            "进入横屏"
        ]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()        
        view.addSubview(tableView)
        
        // 场景预设
        ShareManager.shared.scenes.append(Scene(type: .wechat, icon: UIImage(named: wechatNamed)!))
        ShareManager.shared.scenes.append(Scene(type: .wechatTimeline, icon: UIImage(named: wechatTlNamed)!))
        ShareManager.shared.scenes.append(Scene(type: .QQ, icon: UIImage(named: qqNamed)!))
        ShareManager.shared.scenes.append(Scene(type: .QZone, icon: UIImage(named: qZoneNamed)!))
        ShareManager.shared.register(qqKey: qqKey, qqLink: qqlink, wechatKey: wechatKey, wechatLink: universalLink)
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
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
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
            
            ShareManager.shared.share(resource: "hello", to: .wechat) { (error) in
                guard error == nil else {
                    UIApplication.shared.keyWindow!.showToast("\(error?.localizedDescription ?? "分享失败")")
                    return
                }
                UIApplication.shared.keyWindow!.showToast("分享成功")
            }

        case 1:
            
            let image = UIImage(named: "avatar")!
            let url = "https://github.com/ablettchen/SocailShare"
            let web = ResourceWeb(url: url, title: "SocailShare", description: "社会化分享", thumb: image)
            
            ShareManager.shared.show(resource: web) { (error, scence) in
                guard error == nil else {
                    UIApplication.shared.keyWindow!.showToast("\(error?.localizedDescription ?? "分享失败")")
                    return
                }
                UIApplication.shared.keyWindow!.showToast("分享成功")
            }
            
        case 2:

            let vc = LandscapeController()
            navigationController?.pushViewController(vc, animated: true)
            
        default: break
        }
    }
    
}
