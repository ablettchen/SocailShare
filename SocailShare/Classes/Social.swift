//
//  BLShare.swift
//  Beile
//
//  Created by ablett on 2020/8/24.
//  Copyright © 2020 ablettchen@gmail.com. All rights reserved.
//

import UIKit

/// 平台类型
public enum SocialType: Int, CustomStringConvertible {
    
    case wechat         = 1
    case wechatTimeline = 2
    case QQ             = 3
    case QZone          = 4
    
    public var description: String {
        switch self {
        case .wechat:           return "微信"
        case .wechatTimeline:   return "微信朋友圈"
        case .QQ:               return "QQ"
        case .QZone:            return "QQ空间"
        }
    }
}

public struct Social {
    
    /// 平台类型
    public var type: SocialType
    
    /// 展示图标
    public var icon: UIImage
    
    /// 公钥
    public var appKey: String
    
    /// 私钥
    public var appSecret: String

    /// 通用链接
    public var universalLink: String
    
    /// 分享文本
    /// - Parameters:
    ///   - text: 文本
    ///   - finished: 完成回调
    public func shareText(_ text: String, finished: ((_ error: Error?) -> Void)?) {
        guard prepare(exception: finished) else {return}
        debugPrint("share \(text) to \(self.type)")
        
        switch type {
        case .wechat, .wechatTimeline:
            
            let scene: Int32 = Int32((type == .wechat) ? WXSceneSession.rawValue : WXSceneTimeline.rawValue)
            
            let req = SendMessageToWXReq()
            req.bText = true
            req.text = text
            req.scene = scene
            WXApi.send(req) { (success) in
                debugPrint("\(success)")
            }
                
        case .QQ, .QZone:
            
            let textObjc = QQApiTextObject.init(text: text)
            let req = SendMessageToQQReq.init(content: textObjc)
            var code: QQApiSendResultCode = .EQQAPISENDSUCESS;
            if type == .QQ {
                code = QQApiInterface.sendReq(toQZone: req)
            }else if type == .QZone {
                code = QQApiInterface.sendReq(toQZone: req)
            }
            if code != .EQQAPISENDSUCESS {
                finished?(NSError.init(domain: "Social", code: 10001, userInfo: [NSLocalizedDescriptionKey : "error:\(code.rawValue)"]))
            }
            
        }
    }
    
    /// 分享图片
    /// - Parameters:
    ///   - image: 图片
    ///   - finished: 完成回调
    public func shareImage(_ image: UIImage, finished: ((_ error: Error?) -> Void)?) {
        guard prepare(exception: finished) else {return}
        debugPrint("share \(image) to \(self.type)")
        
        let data = image.jpegData(compressionQuality: 1.0)!
        
        switch type {
        case .wechat, .wechatTimeline:
            
            let scene: Int32 = Int32((type == .wechat) ? WXSceneSession.rawValue : WXSceneTimeline.rawValue)
            
            let imageObjc = WXImageObject()
            imageObjc.imageData = data
            
            let message = WXMediaMessage()
            message.thumbData = data
            message.mediaObject = imageObjc
            
            let req = SendMessageToWXReq()
            req.bText = false
            req.message = message
            req.scene = scene
            
            WXApi.send(req) { (success) in
                debugPrint("\(success)")
            }
                
        case .QQ, .QZone:
            
            let imageObjc = QQApiImageObject.init(data: data, previewImageData: data, title: "", description: "")
            let req = SendMessageToQQReq.init(content: imageObjc)
            var code: QQApiSendResultCode = .EQQAPISENDSUCESS;
            if type == .QQ {
                code = QQApiInterface.sendReq(toQZone: req)
            }else if type == .QZone {
                code = QQApiInterface.sendReq(toQZone: req)
            }
            if code != .EQQAPISENDSUCESS {
                finished?(NSError.init(domain: "Social", code: 10001, userInfo: [NSLocalizedDescriptionKey : "error:\(code.rawValue)"]))
            }
        }
        
    }
    
    /// 分享网页
    /// - Parameters:
    ///   - title: 标题
    ///   - description: 描述
    ///   - thumb: 缩略图
    ///   - finished: 完成回调
    public func shareWeb(title: String, description: String, thumb: UIImage, url: String, finished: ((_ error: Error?) -> Void)?) {
        guard prepare(exception: finished) else {return}
        debugPrint("share \(url) to \(self.type)")
        
        let data = thumb.jpegData(compressionQuality: 1.0)!
        
        switch type {
        case .wechat, .wechatTimeline:
            
            let webObjc = WXWebpageObject()
            webObjc.webpageUrl = url
            
            let message = WXMediaMessage()
            message.title = title
            message.description = description
            message.thumbData = data
            message.mediaObject = webObjc
            
            let req = SendMessageToWXReq()
            req.bText = false
            req.message = message
            req.scene = Int32(WXSceneSession.rawValue)
            WXApi.send(req) { (success) in
                debugPrint("\(success)")
            }
                
        case .QQ, .QZone:

            let webObjc = QQApiNewsObject.init(url: URL(string: url), title: title, description: description, previewImageData: data, targetContentType: .news)
            let req = SendMessageToQQReq.init(content: webObjc)
            var code: QQApiSendResultCode = .EQQAPISENDSUCESS;
            if type == .QQ {
                code = QQApiInterface.sendReq(toQZone: req)
            }else if type == .QZone {
                code = QQApiInterface.sendReq(toQZone: req)
            }
            if code != .EQQAPISENDSUCESS {
                finished?(NSError.init(domain: "Social", code: 10001, userInfo: [NSLocalizedDescriptionKey : "error:\(code.rawValue)"]))
            }
        }
    }
    
    /// 信息注册
    public func register(delegate: TencentSessionDelegate? = nil)  {
        
        switch type {
        case .wechat, .wechatTimeline:
            WXApi.registerApp(appKey, universalLink: universalLink)
            
        case .QQ, .QZone:
            debugPrint(type)
            TencentOAuth.init(appId: appKey, enableUniveralLink: true, universalLink:universalLink, delegate: delegate)
        }
    }
    
    /// 检测是否安装
    /// - Returns: 是否安装
    public func isInstall() -> Bool {
        switch type {
        case .wechat, .wechatTimeline:
            return WXApi.isWXAppInstalled()
            
        case .QQ, .QZone:
            return QQApiInterface.isQQInstalled()
        }
        return false
    }
    
    public init(type: SocialType, icon: UIImage, appKey: String, appSecret: String, universalLink: String) {
        self.type = type
        self.icon = icon
        self.appKey = appKey
        self.appSecret = appSecret
        self.universalLink = universalLink
    }
    
}

private extension Social {
    
    /// 准备
    /// - Parameter exception: 完成回调
    func prepare(exception: ((_ error: Error) -> Void)?) -> Bool {
        
        register()
        
        guard isInstall() else {
            var name = ""
            switch type {
            case .wechat, .wechatTimeline:
                name = SocialType.wechat.description
            case .QQ, .QZone:
                name = SocialType.QQ.description
            }
            let error = NSError(domain: "Social", code: 10000, userInfo: [NSLocalizedDescriptionKey : "\(name)未安装"])
            exception?(error)
            return false
        }
        
        return true
    }
}




