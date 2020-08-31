# SocailShare



```

ShareManager.shared.socails.append(Social(type: .wechat, icon: UIImage(named: wechatNamed)!, appKey: wechatKey, appSecret: wechatSecret, universalLink: ""))
ShareManager.shared.socails.append(Social(type: .wechatTimeline, icon: UIImage(named: wechatTlNamed)!, appKey: wechatKey, appSecret: wechatSecret, universalLink: ""))
ShareManager.shared.socails.append(Social(type: .QQ, icon: UIImage(named: qqNamed)!, appKey: qqKey, appSecret: qqSecret, universalLink: ""))
ShareManager.shared.socails.append(Social(type: .QZone, icon: UIImage(named: qZoneNamed)!, appKey: qqKey, appSecret: qqSecret, universalLink: ""))

let web = ResourceWeb(title: "hello", description: "desc", thumb: UIImage(named: "social_wechat")!, url: "https://github.com/ablettchen")
ShareManager.shared.show(resource: web) { (error, socail) in
    guard error == nil else {
        let text = "\(error?.localizedDescription ?? "error")"
        debugPrint(text)
        UIApplication.shared.keyWindow!.showToast(text)
        return
    }
    debugPrint("\(socail?.type.description ?? "") shared successfully")
}


```
