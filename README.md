# SocailShare
`Swift` 社会化分享工具

1. 支持分享资源：文本、图片、网页链接
2. 支持分享平台：微信、微信朋友圈、QQ、QQ空间

## Example

#### 1、场景预设

```swift
ShareManager.shared.scenes.append(Scene(type: .wechat, icon: UIImage(named: wechatNamed)!))
ShareManager.shared.scenes.append(Scene(type: .wechatTimeline, icon: UIImage(named: wechatTlNamed)!))
ShareManager.shared.scenes.append(Scene(type: .QQ, icon: UIImage(named: qqNamed)!))
ShareManager.shared.scenes.append(Scene(type: .QZone, icon: UIImage(named: qZoneNamed)!))
ShareManager.shared.register(qqKey: qqKey, qqLink: qqlink, wechatKey: wechatKey, wechatLink: universalLink)
```

#### 2、分享事件

```swift
ShareManager.shared.share(resource: "hello", type: .wechat) { (error) in
    guard error == nil else {
        UIApplication.shared.keyWindow!.showToast("\(error?.localizedDescription ?? "分享失败")")
        return
    }
    UIApplication.shared.keyWindow!.showToast("分享成功")
}
```

#### 3、分享弹窗

```swift
let image = UIImage(named: "avatar")!
let web = ResourceWeb(title: "SocailShare", description: "社会化分享工具", thumb: image, url: "https://github.com/ablettchen/SocailShare")
ShareManager.shared.show(resource: web) { (error, socail) in
    guard error == nil else {
        UIApplication.shared.keyWindow!.showToast("\(error?.localizedDescription ?? "分享失败")")
        return
    }
    UIApplication.shared.keyWindow!.showToast("分享成功")
}
```


