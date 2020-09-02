//
//  LandscapeController.swift
//  SocailShare_Example
//
//  Created by ablett on 2020/9/2.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import SocailShare
import ATToast

class LandscapeController: UIViewController {

    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .none
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .landscapeRight
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "横屏分享弹窗"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        
        let bgview = UIImageView(image: UIImage(named: "background_landscape"))
        bgview.isUserInteractionEnabled = true
        view.addSubview(bgview)
        bgview.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        at_setInterfaceOrientation(.landscapeRight)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        at_setInterfaceOrientation(.portrait)
    }
    
    private lazy var button: UIButton = {
        let view = UIButton.init(type: .custom)
        view.setTitle("share", for: .normal)
        view.setTitleColor(.blue, for: .normal)
        view.at_size = CGSize.init(width: 60, height: 40)
        view.titleLabel?.font = .systemFont(ofSize: 17)
        view.contentHorizontalAlignment = .right
        view.addTarget(self, action: #selector(share(_:)), for: .touchUpInside)
        return view
    }()

}

private extension LandscapeController {
    
    @objc func share(_ sender: UIButton) {
        
        let image = UIImage(named: "avatar")!
        let web = ResourceWeb(title: "SocailShare", description: "社会化分享工具", thumb: image, url: "https://github.com/ablettchen/SocailShare")
        
        ShareManager.shared.show(resource: web, isLandscape: true) { (error, scence) in
            guard error == nil else {
                UIApplication.shared.keyWindow!.showToast("\(error?.localizedDescription ?? "分享失败")")
                return
            }
            UIApplication.shared.keyWindow!.showToast("分享成功")
        }
        
    }
    
}
