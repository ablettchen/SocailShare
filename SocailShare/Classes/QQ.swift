//
//  QQ.swift
//  SocailShare
//
//  Created by ablett on 2020/9/1.
//

import Foundation



public enum QQScene: Int, CustomStringConvertible {
    
    case qq = 0
    case qZone = 1
    
    public var description: String {
        switch self {
        case .qq: return "QQ"
        case .qZone: return "QQ空间"
        }
    }
}

public class QQ: NSObject {
    
    /// 单例
    public static let shared = QQ()
    
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
    public func shareText(_ text: String, to scene: QQScene, finished: ((_ error: Error?) -> Void)?) {
        
        if let error = prepare() {
            finished?(error)
            return
        }
        
        let textObjc = QQApiTextObject.init(text: text)
        let req = SendMessageToQQReq.init(content: textObjc)
        var code: QQApiSendResultCode = .EQQAPISENDSUCESS;
        if scene == .qq {
            code = QQApiInterface.send(req)
        }else if scene == .qZone {
            code = QQApiInterface.sendReq(toQZone: req)
        }
        if code != .EQQAPISENDSUCESS {
            finished?(NSError.init(domain: "QQ", code: 10001, userInfo: [NSLocalizedDescriptionKey : "分享失败(\(code.rawValue))"]))
        }else {
            self.finished = finished
        }
    }
    
    /// 分享图片
    /// - Parameters:
    ///   - image: 图片
    ///   - scene: 场景
    ///   - finished: 完成回调
    public func shareImage(_ image: UIImage, to scene: QQScene, finished: ((_ error: Error?) -> Void)?) {
        
        if let error = prepare() {
            finished?(error)
            return
        }
        
        if let error = validate(image: image) {
            finished?(error)
            return
        }
        
        let imageData = image.jpegData(compressionQuality: 1.0)!
        
        let imageObjc = QQApiImageObject.init(data: imageData, previewImageData: nil, title: "", description: "")
        let req = SendMessageToQQReq.init(content: imageObjc)
        var code: QQApiSendResultCode = .EQQAPISENDSUCESS;
        if scene == .qq {
            code = QQApiInterface.send(req)
        }else if scene == .qZone {
            code = QQApiInterface.sendReq(toQZone: req)
        }
        if code != .EQQAPISENDSUCESS {
            finished?(NSError.init(domain: "QQ", code: 10001, userInfo: [NSLocalizedDescriptionKey : "分享失败(\(code.rawValue))"]))
        }else {
            self.finished = finished
        }
    }
    
    
    /// 分享网页链接
    /// - Parameters:
    ///   - title: 标题
    ///   - description: 描述
    ///   - thumb: 缩略图
    ///   - url: 链接
    ///   - scene: 场景
    ///   - finished: 完成回调
    public func shareWeb(title: String, description: String, thumb: UIImage, url: String, to scene: QQScene, finished: ((_ error: Error?) -> Void)?) {
        
        if let error = prepare() {
            finished?(error)
            return
        }
        
        if let error = validate(image: thumb, isThumb: true) {
            finished?(error)
            return
        }
        
        let thumbData = thumb.jpegData(compressionQuality: 1.0)!
        
        let webObjc = QQApiNewsObject.init(url: URL(string: url), title: title, description: description, previewImageData: thumbData, targetContentType: .news)
        let req = SendMessageToQQReq.init(content: webObjc)
        var code: QQApiSendResultCode = .EQQAPISENDSUCESS;
        if scene == .qq {
            code = QQApiInterface.send(req)
        }else if scene == .qZone {
            code = QQApiInterface.sendReq(toQZone: req)
        }
        if code != .EQQAPISENDSUCESS {
            finished?(NSError.init(domain: "QQ", code: 10001, userInfo: [NSLocalizedDescriptionKey : "分享失败(\(code.rawValue))"]))
        }else {
            self.finished = finished
        }
    }
}

extension QQ {

    public func register(appKey: String, universalLink: String) {
        self.appKey = appKey
        self.universalLink = universalLink
        TencentOAuth.init(appId: appKey, enableUniveralLink: true, universalLink:universalLink, delegate: self)
    }
    
    public func can(handleUniversalLink url: URL) -> Bool {
        return TencentOAuth.canHandleUniversalLink(url)
    }
    
    public func can(open url: URL) -> Bool {
        return TencentOAuth.canHandleOpen(url)
    }
    
    public func handle(continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                if TencentOAuth.canHandleUniversalLink(url) {
                    QQApiInterface.handleOpenUniversallink(url, delegate: self)
                    return TencentOAuth.handleUniversalLink(url)
                }
            }
        }
        return true
    }
    
    public func handle(open url: URL) -> Bool {
        if TencentOAuth.canHandleOpen(url) {
            return TencentOAuth.handleOpen(url)
        }
        return true
    }
    
    func isInstall() -> Bool {
        return QQApiInterface.isQQInstalled()
    }
    
    func register(delegate: TencentSessionDelegate) {
        TencentOAuth.init(appId: appKey, enableUniveralLink: true, universalLink:universalLink, delegate: delegate)
    }
    
}

private extension QQ {
    
    func prepare() -> Error? {
        register(delegate: self)
        guard isInstall() else {
            return NSError(domain: "QQ", code: 10000, userInfo: [NSLocalizedDescriptionKey : "\(QQScene.qq)未安装"])
        }
        return nil
    }

    func validate(image: UIImage, isThumb: Bool = false) -> Error? {
        let data = image.jpegData(compressionQuality: 1.0)!
        let refer = (isThumb ? 1024 : 1024 * 5)
        guard (data.count / 1000) < refer else {
            return NSError.init(domain: "Scene", code: 10001, userInfo: [NSLocalizedDescriptionKey : isThumb ? "缩略图太大" : "图片太大"])
        }
        return nil
    }
}

extension QQ: TencentSessionDelegate {
    
    public func tencentDidLogin() {}

    public func tencentDidNotLogin(_ cancelled: Bool) {}

    public func tencentDidNotNetWork() {}

    public func responseDidReceived(_ response: APIResponse!, forMessage message: String!) {}
}

extension QQ: QQApiInterfaceDelegate {
    
    public func onReq(_ req: QQBaseReq!) {}
    
    public func onResp(_ resp: QQBaseResp!) {
        switch resp.type {
        case 2:
            
            let req = resp as? SendMessageToQQResp
            let text = resp.errorDescription;
            let text1 = resp.result
            
            guard resp.result == "0" else {
                let text = resp.errorDescription ?? "分享失败"
                let error = NSError(domain: "QQ", code: 10000, userInfo: [NSLocalizedDescriptionKey : "\(text)"])
                finished?(error)
                return
            }
            finished?(nil)
            
        default: break
        }
    }
    
    public func isOnlineResponse(_ response: [AnyHashable : Any]!) {}
}
