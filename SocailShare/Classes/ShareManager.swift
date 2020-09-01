//
//  ShareManager.swift
//  Beile
//
//  Created by ablett on 2020/8/24.
//  Copyright © 2020 ablettchen@gmail.com. All rights reserved.
//

import UIKit
import Foundation

/// 社会化分享
public class ShareManager: NSObject {

    /// 单例
    public static let shared = ShareManager()
    
    /// 是否验证平台已安装
    public var isOnlyShowInstalled = false
    
    /// 平台信息预设
    public var socails: [Social] = []
    
    private var finished: ((_ error: Error?) -> Void)?

    /// 分享
    /// - Parameters:
    ///   - resource: 资源
    ///   - socail: 平台
    ///   - finished: 完成回调
    public func share(resource: Any, type: SocialType, finished: ((_ error: Error?) -> Void)?) {
        if let socail = ShareManager.presetValidate(type: type, exception: finished) {
            self.finished = finished
            switch resource {
            case let text as String:
                socail.shareText(text, finished: finished)
            case let image as UIImage:
                socail.shareImage(image, finished: finished)
            case let web as ResourceWeb:
                socail.shareWeb(title: web.title, description: web.description, thumb: web.thumb, url:web.url, finished: finished)
            default:
                let text = "\(resource):资源类型不支持"
                let error = NSError(domain: "ShareManager", code: 10001, userInfo: [NSLocalizedDescriptionKey : text])
                finished?(error)
            }
        }
    }

    /// 分享文本弹窗
    /// - Parameters:
    ///   - resource: 资源
    ///   - types: 平台
    ///   - finished: 完成回到
    public func show(resource: Any, socails types: [SocialType]? = nil, finished: ((_ error: Error?, _ socail: Social?) -> Void)?) {
        let socails = ShareManager.installValidate(types: types)
        let items = ShareManager.items(socails: socails)
        let alert = ShareView()
        alert.show(items: items) { (index) in
            guard index < socails.count else {
                debugPrint("分享平台为空")
                return
            }
            let socail = socails[index]
            ShareManager.shared.share(resource: resource, type: socail.type) { (error) in
                finished?(error, socail)
            }
        }
    }
    
    /// 注册平台信息
    public func register() {
        let socails = ShareManager.shared.socails
        for socail in socails {
            socail.register(delegate: self)
        }
    }
    
    public func handle(continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return WXApi.handleOpenUniversalLink(userActivity, delegate: self)
    } 
    
    public func handle(open url: URL) -> Bool {
        let wechatShare = url.host == "platformId=wechat" && url.scheme == ShareManager.socail(.wechat)?.appKey
        let qqShare = url.host == "response_from_qq"
        if wechatShare {
            WXApi.handleOpen(url, delegate: self)
        }else if qqShare {
            if TencentOAuth.canHandleUniversalLink(url) {TencentOAuth.handleUniversalLink(url)}
            else if TencentOAuth.canHandleOpen(url) {TencentOAuth.handleOpen(url)}
        }
        return false
    }
}

extension ShareManager: WXApiDelegate {
    
    public func onReq(_ req: BaseReq) {
        
    }
    
    public func onResp(_ resp: BaseResp) {
        finished?(nil)
    }
}

extension ShareManager: TencentSessionDelegate {

    public func tencentDidLogin() {}

    public func tencentDidNotLogin(_ cancelled: Bool) {}

    public func tencentDidNotNetWork() {}

    public func responseDidReceived(_ response: APIResponse!, forMessage message: String!) {
        debugPrint("\(message)")
    }
}

private extension ShareManager {
    
    /// 平台信息转 UI 展示元素
    /// - Parameter socails: 平台
    /// - Returns: ui 展示元素
    static func items(socails: [Social]) -> [(name: String, icon: UIImage?)] {
        var items: [(name: String, icon: UIImage?)] = []
        for socail in socails {
            items.append((socail.type.description, socail.icon))
        }
        return items
    }
    
    /// 以平台类型取预设平台信息
    /// - Parameter type: 平台类型
    /// - Returns: 平台模型
    static func socail(_ type: SocialType) -> Social? {
        for s in ShareManager.shared.socails {
            if s.type == type {
                return s
            }
        }
        return nil
    }
    
    /// 以平台类型取预设平台信息
    /// - Parameter types: 平台类型
    /// - Returns: 平台模型
    static func socails(_ types: [SocialType]?) -> [Social]? {
        var socails: [Social]? = []
        if let types = types {
            for type in types {
                if let socail = ShareManager.socail(type) {
                    socails?.append(socail)
                }
            }
            return socails
        }
        return nil
    }
    
    /// 分享平台信息验证
    /// - Parameters:
    ///   - type: 类型
    ///   - exception: 异常回调
    /// - Returns: 平台
    static func presetValidate(type: SocialType, exception: ((_ error: Error) -> Void)?) -> Social? {
        guard let socail = ShareManager.socail(type) else {
            let text = "未找到\(type.description)"
            let error = NSError(domain: "ShareManager", code: 10000, userInfo: [NSLocalizedDescriptionKey : text])
            exception?(error)
            return nil
        }
        return socail
    }
    
    /// 安装信息校验
    /// - Parameter types: 平台类型
    /// - Returns: 平台
    static func installValidate(types: [SocialType]? = nil) -> [Social] {
        var socails = ShareManager.socails(types) ?? ShareManager.shared.socails
        var instailled: [Social] = []
        if ShareManager.shared.isOnlyShowInstalled {
            for socail in socails {
                if socail.isInstall() {
                    instailled.append(socail)
                }
            }
            socails = instailled
        }
        return socails
    }
}





/// 网页
public struct ResourceWeb {
    
    /// 标题
    public var title: String
    
    /// 描述
    public var description: String
    
    /// 缩略图
    public var thumb: UIImage
    
    /// 链接
    public var url: String
    
    public init(title: String, description: String, thumb: UIImage, url: String) {
        self.title = title
        self.description = description
        self.thumb = thumb
        self.url = url
    }
}
