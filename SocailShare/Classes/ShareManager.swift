//
//  ShareManager.swift
//  Beile
//
//  Created by ablett on 2020/8/24.
//  Copyright © 2020 ablettchen@gmail.com. All rights reserved.
//

import UIKit

/// 社会化分享
public class ShareManager {

    /// 单例
    static let shared = ShareManager()
    
    /// 是否验证平台已安装
    var isOnlyShowInstalled = false
    
    /// 平台信息预设
    var socails: [Social] = []

    /// 分享
    /// - Parameters:
    ///   - resource: 资源
    ///   - socail: 平台
    ///   - finished: 完成回调
    func share(resource: Any, type: SocialType, finished: ((_ error: Error?) -> Void)?) {
        if let socail = ShareManager.presetValidate(type: type, exception: finished) {
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
    func show(resource: Any, socails types: [SocialType]? = nil, finished: ((_ error: Error?, _ socail: Social?) -> Void)?) {
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
    func register() {
        let socails = ShareManager.shared.socails
        for socail in socails {
            socail.register()
        }
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
    var title: String
    
    /// 描述
    var description: String
    
    /// 缩略图
    var thumb: UIImage
    
    /// 链接
    var url: String
}
