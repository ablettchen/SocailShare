//
//  ShareManager.swift
//  Beile
//
//  Created by ablett on 2020/8/24.
//  Copyright © 2020 ablettchen@gmail.com. All rights reserved.
//

import UIKit
import Foundation
import ATToast

/// 社会化分享
public class ShareManager: NSObject {
    
    /// 单例
    public static let shared = ShareManager()
    
    /// 是否只已安装可见
    public var isInstalledEnable = true
    
    /// 平台信息预设
    public var scenes: [Scene] = []
    
    /// 分享
    /// - Parameters:
    ///   - resource: 资源 ( 类型：String、Data/URL、ResourceWeb )
    ///   - type: 场景
    ///   - finished: 完成回调
    public func share(resource: Any, to type: SceneType, finished: ((_ error: Error?) -> Void)?) {
        if let _ = ShareManager.presetValidate(type: type, exception: finished) {
            switch resource {
            case let text as String:
                
                switch type {
                case .wechat: Wechat.shared.shareText(text, to: .sesson, finished: finished)
                case .wechatTimeline: Wechat.shared.shareText(text, to: .timeline, finished: finished)
                case .QQ: QQ.shared.shareText(text, to: .qq, finished: finished)
                case .qZone: QQ.shared.shareText(text, to: .qZone, finished: finished)
                case .copy: ShareManager.pasteboard(text, finished: nil)
                @unknown default: finished?(NSError(domain: "ShareManager", code: 10000, userInfo: [NSLocalizedDescriptionKey : "未找到\(sceneDescription(type))"]))
                }
                
            case let imageData as Data:
                
                switch type {
                case .wechat: Wechat.shared.shareImage(data: imageData, to: .sesson, finished: finished)
                case .wechatTimeline: Wechat.shared.shareImage(data: imageData, to: .timeline, finished: finished)
                case .QQ: QQ.shared.shareImage(data: imageData, to: .qq, finished: finished)
                case .qZone: QQ.shared.shareImage(data: imageData, to: .qZone, finished: finished)
                case .copy:
                    let text = "图片二进制数据无法复制"
                    let error = NSError(domain: "ShareManager", code: 10001, userInfo: [NSLocalizedDescriptionKey : text])
                    finished?(error)
                @unknown default: finished?(NSError(domain: "ShareManager", code: 10000, userInfo: [NSLocalizedDescriptionKey : "未找到\(sceneDescription(type))"]))
                }
                
            case let imageURL as URL:
                
                switch type {
                case .wechat: Wechat.shared.shareImage(url: imageURL, to: .sesson, finished: finished)
                case .wechatTimeline: Wechat.shared.shareImage(url: imageURL, to: .timeline, finished: finished)
                case .QQ: QQ.shared.shareImage(url: imageURL, to: .qq, finished: finished)
                case .qZone: QQ.shared.shareImage(url: imageURL, to: .qZone, finished: finished)
                case .copy:
                    let text = "图片二进制数据无法复制"
                    let error = NSError(domain: "ShareManager", code: 10001, userInfo: [NSLocalizedDescriptionKey : text])
                    finished?(error)
                @unknown default: finished?(NSError(domain: "ShareManager", code: 10000, userInfo: [NSLocalizedDescriptionKey : "未找到\(sceneDescription(type))"]))
                }
                
            case let web as ResourceWeb:
                
                switch web.thumb {
                case let thumbData as Data:
                    switch type {
                    case .wechat: Wechat.shared.shareWeb(url: web.url, title: web.title, description: web.description, thumbData: thumbData, to: .sesson, finished: finished)
                    case .wechatTimeline: Wechat.shared.shareWeb(url: web.url, title: web.title, description: web.description, thumbData: thumbData, to: .timeline, finished: finished)
                    case .QQ: QQ.shared.shareWeb(url: web.url, title: web.title, description: web.description, thumbData: thumbData, to: .qq, finished: finished)
                    case .qZone: QQ.shared.shareWeb(url: web.url, title: web.title, description: web.description, thumbData: thumbData, to: .qZone, finished: finished)
                    case .copy: ShareManager.pasteboard(web.url, finished: nil)
                    @unknown default: finished?(NSError(domain: "ShareManager", code: 10000, userInfo: [NSLocalizedDescriptionKey : "未找到\(sceneDescription(type))"]))
                    }
                    
                case let thumbURL as URL:
                    switch type {
                    case .wechat: Wechat.shared.shareWeb(url: web.url, title: web.title, description: web.description, thumbURL: thumbURL, to: .sesson, finished: finished)
                    case .wechatTimeline: Wechat.shared.shareWeb(url: web.url, title: web.title, description: web.description, thumbURL: thumbURL, to: .timeline, finished: finished)
                    case .QQ: QQ.shared.shareWeb(url: web.url, title: web.title, description: web.description, thumbURL: thumbURL, to: .qq, finished: finished)
                    case .qZone: QQ.shared.shareWeb(url: web.url, title: web.title, description: web.description, thumbURL: thumbURL, to: .qZone, finished: finished)
                    case .copy: ShareManager.pasteboard(web.url, finished: nil)
                    @unknown default: finished?(NSError(domain: "ShareManager", code: 10000, userInfo: [NSLocalizedDescriptionKey : "未找到\(sceneDescription(type))"]))
                    }
                    
                default:
                    let text = "ResourceWeb.thumb 类型必须为 Data 或 URL"
                    let error = NSError(domain: "ShareManager", code: 10001, userInfo: [NSLocalizedDescriptionKey : text])
                    finished?(error)
                }
                
            default:
                let text = "\(resource):资源类型不支持"
                let error = NSError(domain: "ShareManager", code: 10001, userInfo: [NSLocalizedDescriptionKey : text])
                finished?(error)
            }
        }
    }
    
    /// 分享弹窗
    /// - Parameters:
    ///   - resource: 资源 ( 类型：String、Data/URL、ResourceWeb )
    ///   - types: 场景
    ///   - finished: 完成回调
    public func show(resource: Any, to types: [SceneType]? = nil, isLandscape: Bool? = false, finished: ((_ error: Error?, _ socail: Scene) -> Void)?) {
        let scenes = ShareManager.enableValidate(types: types, reource: resource)
        let items = ShareManager.items(scenes: scenes)
        guard isLandscape ?? false else {
            let alert = ShareView()
            alert.show(items: items) { (index) in
                guard index < scenes.count else {
                    debugPrint("分享平台为空")
                    return
                }
                let scene = scenes[index]
                ShareManager.shared.share(resource: resource, to: scene.type) { (error) in
                    finished?(error, scene)
                }
            }
            return
        }
        
        let alert = LandscapeShareView()
        alert.show(items: items) { (index) in
            guard index < scenes.count else {
                debugPrint("分享平台为空")
                return
            }
            let scene = scenes[index]
            ShareManager.shared.share(resource: resource, to: scene.type) { (error) in
                finished?(error, scene)
            }
        }
    }
    
    /// 注册平台信息
    public func register(qqKey: String, qqLink: String, wechatKey: String, wechatLink: String) {
        QQ.shared.register(appKey: qqKey, universalLink: qqLink)
        Wechat.shared.register(appKey: wechatKey, universalLink: wechatLink)
    }
    
    public func handle(continue userActivity: NSUserActivity) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                if QQ.shared.can(handleUniversalLink: url) {
                    return QQ.shared.handle(continue: userActivity)
                }else {
                    return Wechat.shared.handle(continue: userActivity)
                }
            }
        }
        return false
    } 
    
    public func handle(open url: URL) -> Bool {
        if QQ.shared.can(open: url) {
            return QQ.shared.handle(open: url)
        }else {
            return Wechat.shared.handle(open: url)
        }
    }
}

private extension ShareManager {
    
    static func pasteboard(_ text: String, finished: ((_ error: Error?) -> Void)?) {
        UIPasteboard.general.string = text
        UIApplication.shared.keyWindow!.showToast("复制成功")
        finished?(nil)
    }
    
    /// 场景转 UI 展示元素
    /// - Parameter socails: 场景
    /// - Returns: ui 展示元素
    static func items(scenes: [Scene]) -> [(name: String, icon: UIImage?)] {
        var items: [(name: String, icon: UIImage?)] = []
        for scene in scenes {
            items.append((sceneDescription(scene.type), scene.icon))
        }
        return items
    }
    
    /// 以类型取场景
    /// - Parameter type: 场景类型
    /// - Returns: 场景
    static func scene(_ type: SceneType) -> Scene? {
        for s in ShareManager.shared.scenes {
            if s.type == type {
                return s
            }
        }
        return nil
    }
    
    /// 以类型取场景
    /// - Parameter types: 场景类型
    /// - Returns: 场景
    static func scenes(_ types: [SceneType]?) -> [Scene]? {
        var scenes: [Scene]? = []
        if let types = types {
            for type in types {
                if let scene = ShareManager.scene(type) {
                    scenes?.append(scene)
                }
            }
            return scenes
        }
        return nil
    }
    
    /// 预设信息校验
    /// - Parameters:
    ///   - type: 类型
    ///   - exception: 异常回调
    /// - Returns: 场景
    static func presetValidate(type: SceneType, exception: ((_ error: Error) -> Void)?) -> Scene? {
        guard let scene = ShareManager.scene(type) else {
            let text = "未找到\(sceneDescription(type))"
            let error = NSError(domain: "ShareManager", code: 10000, userInfo: [NSLocalizedDescriptionKey : text])
            exception?(error)
            return nil
        }
        return scene
    }
    
    /// 场景可用校验
    /// - Parameter types: 场景类型
    /// - Returns: 场景
    static func enableValidate(types: [SceneType]? = nil, reource: Any) -> [Scene] {
        var scenes = ShareManager.scenes(types) ?? ShareManager.shared.scenes
        var instailled: [Scene] = []
        if ShareManager.shared.isInstalledEnable {
            for scene in scenes {
                if scene.enable(reource: reource) {
                    instailled.append(scene)
                }
            }
            scenes = instailled
        }
        return scenes
    }
}
