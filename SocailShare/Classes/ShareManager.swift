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
    public var scenes: [Scene] = []

    /// 分享
    /// - Parameters:
    ///   - resource: 资源
    ///   - type: 场景
    ///   - finished: 完成回调
    public func share(resource: Any, type: SceneType, finished: ((_ error: Error?) -> Void)?) {
        if let _ = ShareManager.presetValidate(type: type, exception: finished) {
            switch resource {
            case let text as String:
                
                switch type {
                case .wechat: Wechat.shared.shareText(text, to: .sesson, finished: finished)
                case .wechatTimeline: Wechat.shared.shareText(text, to: .timeline, finished: finished)
                case .QQ: QQ.shared.shareText(text, to: .qq, finished: finished)
                case .QZone: QQ.shared.shareText(text, to: .qZone, finished: finished)
                }
                
            case let image as UIImage:
                
                switch type {
                case .wechat: Wechat.shared.shareImage(image, to: .sesson, finished: finished)
                case .wechatTimeline: Wechat.shared.shareImage(image, to: .timeline, finished: finished)
                case .QQ: QQ.shared.shareImage(image, to: .qq, finished: finished)
                case .QZone: QQ.shared.shareImage(image, to: .qZone, finished: finished)
                }

            case let web as ResourceWeb:
                
                switch type {
                case .wechat: Wechat.shared.shareWeb(title: web.title, description: web.description, thumb: web.thumb, url: web.url, to: .sesson, finished: finished)
                case .wechatTimeline: Wechat.shared.shareWeb(title: web.title, description: web.description, thumb: web.thumb, url: web.url, to: .timeline, finished: finished)
                case .QQ: QQ.shared.shareWeb(title: web.title, description: web.description, thumb: web.thumb, url: web.url, to: .qq, finished: finished)
                case .QZone: QQ.shared.shareWeb(title: web.title, description: web.description, thumb: web.thumb, url: web.url, to: .qZone, finished: finished)
                }

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
    ///   - types: 场景
    ///   - finished: 完成回到
    public func show(resource: Any, types: [SceneType]? = nil, finished: ((_ error: Error?, _ socail: Scene?) -> Void)?) {
        let scenes = ShareManager.enableValidate(types: types)
        let items = ShareManager.items(scenes: scenes)
        let alert = ShareView()
        alert.show(items: items) { (index) in
            guard index < scenes.count else {
                debugPrint("分享平台为空")
                return
            }
            let scene = scenes[index]
            ShareManager.shared.share(resource: resource, type: scene.type) { (error) in
                finished?(error, scene)
            }
        }
    }
    
    /// 注册平台信息
    public func register(qqKey: String, qqLink: String, wechatKey: String, wechatLink: String) {
        QQ.shared.register(appKey: qqKey, universalLink: qqLink)
        Wechat.shared.register(appKey: wechatKey, universalLink: wechatLink)
    }
    
    public func handle(continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                if QQ.shared.can(handleUniversalLink: url) {
                    return QQ.shared.handle(continue: userActivity, restorationHandler: restorationHandler)
                }else {
                    return Wechat.shared.handle(continue: userActivity, restorationHandler: restorationHandler)
                }
            }
        }
        return true
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
    
    /// 场景转 UI 展示元素
    /// - Parameter socails: 场景
    /// - Returns: ui 展示元素
    static func items(scenes: [Scene]) -> [(name: String, icon: UIImage?)] {
        var items: [(name: String, icon: UIImage?)] = []
        for scene in scenes {
            items.append((scene.type.description, scene.icon))
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
            let text = "未找到\(type.description)"
            let error = NSError(domain: "ShareManager", code: 10000, userInfo: [NSLocalizedDescriptionKey : text])
            exception?(error)
            return nil
        }
        return scene
    }
    
    /// 场景可用校验
    /// - Parameter types: 场景类型
    /// - Returns: 场景
    static func enableValidate(types: [SceneType]? = nil) -> [Scene] {
        var scenes = ShareManager.scenes(types) ?? ShareManager.shared.scenes
        var instailled: [Scene] = []
        if ShareManager.shared.isOnlyShowInstalled {
            for scene in scenes {
                if scene.enable() {
                    instailled.append(scene)
                }
            }
            scenes = instailled
        }
        return scenes
    }
}






