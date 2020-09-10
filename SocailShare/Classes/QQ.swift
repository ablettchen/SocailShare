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
        
        let textObjc = QQApiTextObject(text: text)
        let req = SendMessageToQQReq(content: textObjc)
        var code: QQApiSendResultCode = .EQQAPISENDSUCESS;
        if scene == .qq {
            code = QQApiInterface.send(req)
        }else if scene == .qZone {
            code = QQApiInterface.sendReq(toQZone: req)
        }
        if code != .EQQAPISENDSUCESS {
            finished?(NSError(domain: "QQ", code: 10001, userInfo: [NSLocalizedDescriptionKey : "分享失败(\(code.rawValue))"]))
        }else {
            self.finished = finished
        }
    }
    
    /// 分享图片
    /// - Parameters:
    ///   - data: 图片
    ///   - scene: 场景
    ///   - finished: 完成回调
    public func shareImage(_ data: Data, to scene: QQScene, finished: ((_ error: Error?) -> Void)?) {
        
        if let error = prepare() {
            finished?(error)
            return
        }
        
        if let error = validate(image: data) {
            finished?(error)
            return
        }
        
        let imageObj = QQApiImageObject(data: data, previewImageData: nil, title: "", description: "")
        let req = SendMessageToQQReq(content: imageObj)
        var code: QQApiSendResultCode = .EQQAPISENDSUCESS;
        if scene == .qq {
            code = QQApiInterface.send(req)
        }else if scene == .qZone {
            code = QQApiInterface.sendReq(toQZone: req)
        }
        if code != .EQQAPISENDSUCESS {
            finished?(NSError(domain: "QQ", code: 10001, userInfo: [NSLocalizedDescriptionKey : "分享失败(\(code.rawValue))"]))
        }else {
            self.finished = finished
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
    public func shareWeb(url: String, title: String, description: String, thumbData: Data, to scene: QQScene, finished: ((_ error: Error?) -> Void)?) {
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
    public func shareWeb(url: String, title: String, description: String, thumbURL: URL, to scene: QQScene, finished: ((_ error: Error?) -> Void)?) {
        shareWeb(url: url, title: title, description: description, thumb: thumbURL, to: scene, finished: finished)
    }

}

extension QQ {

    public func register(appKey: String, universalLink: String) {
        self.appKey = appKey
        self.universalLink = universalLink
        _ = TencentOAuth(appId: appKey, enableUniveralLink: true, universalLink:universalLink, delegate: self)
    }
    
    public func can(handleUniversalLink url: URL) -> Bool {
        return TencentOAuth.canHandleUniversalLink(url)
    }
    
    public func can(open url: URL) -> Bool {
        return TencentOAuth.canHandleOpen(url)
    }
    
    public func handle(continue userActivity: NSUserActivity) -> Bool {
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
    
    public func isInstall() -> Bool {
        return QQApiInterface.isQQInstalled()
    }
}

private extension QQ {
    
    func shareWeb(url: String, title: String, description: String, thumb: Any, to scene: QQScene, finished: ((_ error: Error?) -> Void)?) {
        
        if let error = prepare() {
            finished?(error)
            return
        }

        var thumbObj: QQApiNewsObject? = nil
        
        switch thumb {
        case let thumbData as Data:
            if let error = validate(image: thumbData, isThumb: true) {
                finished?(error)
                return
            }
            thumbObj = QQApiNewsObject(url: URL(string: url), title: title, description: description, previewImageData: thumbData, targetContentType: .news)

        case let thumbUrl as URL:
            thumbObj = QQApiNewsObject(url: URL(string: url), title: title, description: description, previewImageURL: thumbUrl, targetContentType: .news)
            
        default:
            let error = NSError(domain: "QQ", code: 10000, userInfo: [NSLocalizedDescriptionKey : "thumb 类型必须为 Data 或 URL"])
            finished?(error)
            return
        }
        
        guard let thumbO = thumbObj else {
            let error = NSError(domain: "QQ", code: 10000, userInfo: [NSLocalizedDescriptionKey : "缩略图获取失败"])
            finished?(error)
            return
        }
        
        let req = SendMessageToQQReq(content: thumbO)
        var code: QQApiSendResultCode = .EQQAPISENDSUCESS;
        if scene == .qq {
            code = QQApiInterface.send(req)
        }else if scene == .qZone {
            code = QQApiInterface.sendReq(toQZone: req)
        }
        if code != .EQQAPISENDSUCESS {
            finished?(NSError(domain: "QQ", code: 10001, userInfo: [NSLocalizedDescriptionKey : "分享失败(\(code.rawValue))"]))
        }else {
            self.finished = finished
        }
    }

    func prepare() -> Error? {
        guard isInstall() else {
            return NSError(domain: "QQ", code: 10000, userInfo: [NSLocalizedDescriptionKey : "\(QQScene.qq)未安装"])
        }
        return nil
    }

    func validate(image data: Data, isThumb: Bool = false) -> Error? {
        let kb = 1024
        let mb = kb * 1024
        let refer = (isThumb ? mb * 1 : mb * 5)
        guard data.count < refer else {
            return NSError(domain: "QQ", code: 10001, userInfo: [NSLocalizedDescriptionKey : isThumb ? "缩略图太大" : "图片太大"])
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
