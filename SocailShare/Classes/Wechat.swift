//
//  Socials.swift
//  SocailShare
//
//  Created by ablett on 2020/9/1.
//

import Foundation


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
                finished?(NSError.init(domain: "Wechat", code: 10001, userInfo: [NSLocalizedDescriptionKey : "分享失败"]))
                return
            }
            self?.finished = finished
        }
    }
    
    /// 分享图片
    /// - Parameters:
    ///   - image: 图片
    ///   - scene: 场景
    ///   - finished: 完成回调
    public func shareImage(_ image: UIImage, to scene: WechatScene, finished: ((_ error: Error?) -> Void)?) {
        
        if let error = prepare() {
            finished?(error)
            return
        }
        
        if let error = validate(image: image) {
            finished?(error)
            return
        }
        
        let imageData = image.jpegData(compressionQuality: 1.0)!
        
        let imageObjc = WXImageObject()
        imageObjc.imageData = imageData
        
        let message = WXMediaMessage()
        message.mediaObject = imageObjc
        
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = Int32(scene.rawValue)
        
        WXApi.send(req) { [weak self] (success) in
            guard success else {
                finished?(NSError.init(domain: "Wechat", code: 10001, userInfo: [NSLocalizedDescriptionKey : "分享失败"]))
                return
            }
            self?.finished = finished
        }        
    }
    
    /// 分享链接
    /// - Parameters:
    ///   - url: 链接
    ///   - title: 标题
    ///   - description: 描述
    ///   - thumb: 缩略图
    ///   - scene: 场景
    ///   - finished: 完成回调
    public func shareWeb(url: String, title: String, description: String, thumb: UIImage, to scene: WechatScene, finished: ((_ error: Error?) -> Void)?) {
        
        if let error = prepare() {
            finished?(error)
            return
        }
        
        if let error = validate(image: thumb, isThumb: true) {
            finished?(error)
            return
        }
        
        let thumbData = thumb.jpegData(compressionQuality: 1.0)!
        
        
        let webObjc = WXWebpageObject()
        webObjc.webpageUrl = url
        
        let message = WXMediaMessage()
        message.title = title
        message.description = description
        message.thumbData = thumbData
        message.mediaObject = webObjc
        
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = Int32(scene.rawValue)
        
        WXApi.send(req) { [weak self] (success) in
            guard success else {
                finished?(NSError.init(domain: "Wechat", code: 10001, userInfo: [NSLocalizedDescriptionKey : "分享失败"]))
                return
            }
            self?.finished = finished
        }
    }
}

extension Wechat {
    
    public func register(appKey: String, universalLink: String) {
        self.appKey = appKey
        self.universalLink = universalLink
        if WXApi.registerApp(appKey, universalLink: universalLink) { debugPrint("\(WechatScene.sesson)注册成功") }
        else { debugPrint("\(WechatScene.sesson)注册失败") }
    }
    
    public func handle(continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let url = userActivity.webpageURL
        let wechatShare = url?.host == "platformId=wechat" && url?.scheme == appKey
        if wechatShare {
            return WXApi.handleOpenUniversalLink(userActivity, delegate: self)
        }
        return true
    }
    
    public func handle(open url: URL) -> Bool {
        let wechatShare = url.host == "platformId=wechat" && url.scheme == appKey
        if wechatShare {
            return WXApi.handleOpen(url, delegate: self)
        }
        return true
    }
    
    public func isInstall() -> Bool {
        return WXApi.isWXAppInstalled()
    }
}

private extension Wechat {
    
    /// 准备
    /// - Returns: 错误信息
    func prepare() -> Error? {
        guard isInstall() else {
            return NSError(domain: "Wechat", code: 10000, userInfo: [NSLocalizedDescriptionKey : "\(WechatScene.sesson)未安装"])
        }
        return nil
    }
    
    /// 图片校验
    /// - Parameters:
    ///   - image: 图片
    ///   - isThumb: 是否缩略图
    /// - Returns: 错误信息
    func validate(image: UIImage, isThumb: Bool = false) -> Error? {
        let data = image.jpegData(compressionQuality: 1.0)!
        let kb = 1024
        let mb = kb * 1024
        let refer = (isThumb ? kb * 64 : mb * 25)
        guard data.count < refer else {
            return NSError.init(domain: "Wechat", code: 10001, userInfo: [NSLocalizedDescriptionKey : isThumb ? "缩略图太大" : "图片太大"])
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
