# SocailShare
`Swift` 社会化分享工具

1. 支持分享资源：文本、图片、网页链接
2. 支持分享平台：微信、微信朋友圈、QQ、QQ空间

## Example

#### 1、配置平台信息

```swift
ShareManager.shared.socails.append(Social(type: .wechat, icon: UIImage(named: wechatNamed)!, appKey: wechatKey, appSecret: wechatSecret, universalLink: ""))
ShareManager.shared.socails.append(Social(type: .wechatTimeline, icon: UIImage(named: wechatTlNamed)!, appKey: wechatKey, appSecret: wechatSecret, universalLink: ""))
ShareManager.shared.socails.append(Social(type: .QQ, icon: UIImage(named: qqNamed)!, appKey: qqKey, appSecret: qqSecret, universalLink: ""))
ShareManager.shared.socails.append(Social(type: .QZone, icon: UIImage(named: qZoneNamed)!, appKey: qqKey, appSecret: qqSecret, universalLink: ""))
```

#### 2、调用分享事件

```swift
ShareManager.shared.share(resource: "hello", type: .wechat) { (error) in
    guard error == nil else {
        let text = "\(error?.localizedDescription ?? "error")"
        debugPrint(text)
        UIApplication.shared.keyWindow!.showToast(text)
        return
    }
    debugPrint("shared successfully")
}
```

#### 3、调用分享弹窗

```swift
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


