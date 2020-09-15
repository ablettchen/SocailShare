//
//  Socials.swift
//  SocailShare
//
//  Created by ablett on 2020/9/1.
//

import Foundation
import SDWebImage
import ATLoadView

public enum WechatScene: Int, CustomStringConvertible {
    
    case sesson = 0
    case timeline = 1
    
    public var description: String {
        switch self {
        case .sesson: return "微信"
        case .timeline: return "微信朋友圈"
        }
    }
}

public class Wechat: NSObject {
    
    /// 单例
    public static let shared = Wechat()
    
    /// 公钥
    private var appKey: String = ""
    
    /// 通用链接
    private var universalLink: String = ""
    
    /// 完成回调
    private var finished: ((_ error: Error?) -> Void)?
    
    /// 分享文本
    /// - Parameters:
    ///   - text: 文本
    ///   - scene: 场景
    ///   - finished: 完成回调
    public func shareText(_ text: String, to scene: WechatScene, finished: ((_ error: Error?) -> Void)?) {
        
        if let error = prepare() {
            finished?(error)
            return
        }
        
        let req = SendMessageToWXReq()
        req.bText = true
        req.text = text
        req.scene = Int32(scene.rawValue)
        WXApi.send(req) { [weak self] (success) in
            guard success else {
                finished?(NSError(domain: "Wechat", code: 10001, userInfo: [NSLocalizedDescriptionKey : "分享失败"]))
                return
            }
            self?.finished = finished
        }
    }
    
    /// 分享图片
    /// - Parameters:
    ///   - data: 图片
    ///   - scene: 场景
    ///   - finished: 完成回调
    public func shareImage(data: Data, to scene: WechatScene, finished: ((_ error: Error?) -> Void)?) {
        
        if let error = prepare() {
            finished?(error)
            return
        }
        
        if let error = validate(image: data) {
            finished?(error)
            return
        }
        
        let imageObj = WXImageObject()
        imageObj.imageData = data
        
        let message = WXMediaMessage()
        message.mediaObject = imageObj
        
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = Int32(scene.rawValue)
        
        WXApi.send(req) { [weak self] (success) in
            guard success else {
                finished?(NSError(domain: "Wechat", code: 10001, userInfo: [NSLocalizedDescriptionKey : "分享失败"]))
                return
            }
            self?.finished = finished
        }        
    }
    
    /// 分享图片
    /// - Parameters:
    ///   - url: 图片
    ///   - scene: 场景
    ///   - finished: 完成回调
    public func shareImage(url: URL, to scene: WechatScene, finished: ((_ error: Error?) -> Void)?) {
        let loading = ATLoadView(text: "处理中...")
        loading.show()
        SDWebImageDownloader.shared.downloadImage(with: url) { [weak self] (image, data, error, fi) in
            loading.hide()
            guard error == nil, let imageData = data else {
                let error = NSError(domain: "Wechat", code: 10000, userInfo: [NSLocalizedDescriptionKey : error?.localizedDescription ?? "图片获取失败"])
                finished?(error)
                return
            }
            self?.shareImage(data: imageData, to: scene, finished: finished)
        }
    }
    
    /// 分享链接
    /// - Parameters:
    ///   - url: 链接
    ///   - title: 标题
    ///   - description: 描述
    ///   - thumbData: 缩略图
    ///   - scene: 场景
    ///   - finished: 完成回调
    public func shareWeb(url: String, title: String, description: String, thumbData: Data, to scene: WechatScene, finished: ((_ error: Error?) -> Void)?) {
        shareWeb(url: url, title: title, description: description, thumb: thumbData, to: scene, finished: finished)
    }
    
    /// 分享链接
    /// - Parameters:
    ///   - url: 链接
    ///   - title: 标题
    ///   - description: 描述
    ///   - thumbURL: 缩略图
    ///   - scene: 场景
    ///   - finished: 完成回调
    public func shareWeb(url: String, title: String, description: String, thumbURL: URL, to scene: WechatScene, finished: ((_ error: Error?) -> Void)?) {
        shareWeb(url: url, title: title, description: description, thumb: thumbURL, to: scene, finished: finished)
    }
}

extension Wechat {
    
    public func register(appKey: String, universalLink: String) {
        self.appKey = appKey
        self.universalLink = universalLink
        if WXApi.registerApp(appKey, universalLink: universalLink) { debugPrint("\(WechatScene.sesson)注册成功") }
        else { debugPrint("\(WechatScene.sesson)注册失败") }
    }
    
    public func handle(continue userActivity: NSUserActivity) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let _ = userActivity.webpageURL {
                if WXApi.handleOpenUniversalLink(userActivity, delegate: self) {
                    return true
                }
            }
        }
        return false
    }
    
    public func handle(open url: URL) -> Bool {
        if WXApi.handleOpen(url, delegate: self) {
            return true
        }
        return false
    }
    
    public func isInstall() -> Bool {
        return WXApi.isWXAppInstalled()
    }
}

private extension Wechat {
    
    func shareWeb(url: String, title: String, description: String, thumb: Any, to scene: WechatScene, finished: ((_ error: Error?) -> Void)?) {
        
        if let error = prepare() {
            finished?(error)
            return
        }

        let prosess: ((_ url: String, _ title: String, _ description: String, _ thumb: Data, _ scene: WechatScene, _ finished: ((_ error: Error?) -> Void)?) -> Void) = { (url, title, description, thumb, scene, finished) in

            let webObjc = WXWebpageObject()
            webObjc.webpageUrl = url
            
            let message = WXMediaMessage()
            message.title = title
            message.description = description
            message.thumbData = thumb
            message.mediaObject = webObjc
            
            let req = SendMessageToWXReq()
            req.bText = false
            req.message = message
            req.scene = Int32(scene.rawValue)
            
            WXApi.send(req) { [weak self] (success) in
                guard success else {
                    finished?(NSError(domain: "Wechat", code: 10001, userInfo: [NSLocalizedDescriptionKey : "分享失败"]))
                    return
                }
                self?.finished = finished
            }
        }
        
        switch thumb {
        case let thumbData as Data:
            prosess(url, title, description, thumbData, scene, finished)
            
        case let thumbUrl as URL:
            
            let loading = ATLoadView(text: "处理中...")
            loading.show()
            SDWebImageDownloader.shared.downloadImage(with: thumbUrl) { (image, data, error, fi) in
                loading.hide()
                guard error == nil, let thumbData = data else {
                    let error = NSError(domain: "Wechat", code: 10000, userInfo: [NSLocalizedDescriptionKey : error?.localizedDescription ?? "缩略图获取失败"])
                    finished?(error)
                    return
                }
                prosess(url, title, description, thumbData, scene, finished)
            }
            
        default:
            let error = NSError(domain: "Wechat", code: 10000, userInfo: [NSLocalizedDescriptionKey : "thumb 类型必须为 UIImage 或 URL"])
            finished?(error)
        }
    }
    
    func prepare() -> Error? {
        guard isInstall() else {
            return NSError(domain: "Wechat", code: 10000, userInfo: [NSLocalizedDescriptionKey : "\(WechatScene.sesson)未安装"])
        }
        return nil
    }
    
    func validate(image data: Data, isThumb: Bool = false) -> Error? {
        let kb = 1024
        let mb = kb * 1024
        let refer = (isThumb ? kb * 64 : mb * 25)
        guard data.count < refer else {
            return NSError(domain: "Wechat", code: 10001, userInfo: [NSLocalizedDescriptionKey : isThumb ? "缩略图太大" : "图片太大"])
        }
        return nil
    }   
}


extension Wechat: WXApiDelegate {
    
    public func onReq(_ req: BaseReq) {}
    
    public func onResp(_ resp: BaseResp) {
        
        switch resp {
            
        case let response as SendMessageToWXResp:
            guard response.errCode == 0 else {
                let text = resp.errStr
                let error = NSError(domain: "Wechat", code: 10000, userInfo: [NSLocalizedDescriptionKey : "\(text)"])
                finished?(error)
                return
            }
            finished?(nil)
            
        default: break
        }
    }
}
