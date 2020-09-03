//
//  ShareAdapter.swift
//  SocailShare_Example
//
//  Created by ablett on 2020/9/3.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import SocailShare

/// 分享适配器（给主项目OC分享用）
public class ShareAdapter: NSObject {
    
    @objc
    static public func isInstalledEnable(_ flag: Bool = false) {
        ShareManager.shared.isInstalledEnable = flag
    }
    
    @objc
    static public func preset(scenes: [Scene]) {
        ShareManager.shared.scenes = scenes
    }
    
    @objc
    static public func shareImage(_ image: UIImage, to type: SceneType, finished: @escaping((_ success: Bool, _ errorMessage: String) -> Void)) {
        ShareManager.shared.share(resource: image, to: type) { (error) in
            guard error == nil else {
                finished(false, error?.localizedDescription ?? "分享失败")
                return
            }
            finished(true, "")
        }
    }
    
    @objc
    static public func shareWeb(url: String, title: String, description: String, thumb: UIImage, to type: SceneType, finished: @escaping((_ success: Bool, _ errorMessage: String) -> Void)) {
        let web = ResourceWeb(url: url, title: title, description: description, thumb: thumb)
        ShareManager.shared.share(resource: web, to: type) { (error) in
            guard error == nil else {
                finished(false, error?.localizedDescription ?? "分享失败")
                return
            }
            finished(true, "")
        }
    }
    
    @objc
    static public func show(image: UIImage, finished: @escaping((_ success: Bool, _ errorMessage: String, _ scene: Scene) -> Void)) {
        ShareManager.shared.show(resource: image) { (error, scene) in
            guard error == nil else {
                finished(false, error?.localizedDescription ?? "分享失败", scene)
                return
            }
            finished(true, "", scene)
        }
    }
    
    @objc
    static public func show(image: UIImage, to types: [NSInteger], finished: @escaping((_ success: Bool, _ errorMessage: String, _ scene: Scene) -> Void)) {
        var ss: [SceneType] = []
        for type in types {
            if let s = SceneType.init(rawValue: type) {
                ss.append(s)
            }
        }
        ShareManager.shared.show(resource: image, to: ss) { (error, scene) in
            guard error == nil else {
                finished(false, error?.localizedDescription ?? "分享失败", scene)
                return
            }
            finished(true, "", scene)
        }
    }
    
    @objc
    static public func show(webUrl: String, title: String, description: String, thumb: UIImage, finished: @escaping((_ success: Bool, _ errorMessage: String, _ scene: Scene) -> Void)) {
        let web = ResourceWeb(url: webUrl, title: title, description: description, thumb: thumb)
        ShareManager.shared.show(resource: web) { (error, scene) in
            guard error == nil else {
                finished(false, error?.localizedDescription ?? "分享失败", scene)
                return
            }
            finished(true, "", scene)
        }
    }
    
    @objc
    static public func show(webUrl: String, title: String, description: String, thumb: UIImage, to types: [NSInteger], finished: @escaping((_ success: Bool, _ errorMessage: String, _ scene: Scene) -> Void)) {
        var ss: [SceneType] = []
        for type in types {
            if let s = SceneType.init(rawValue: type) {
                ss.append(s)
            }
        }
        let web = ResourceWeb(url: webUrl, title: title, description: description, thumb: thumb)
        ShareManager.shared.show(resource: web, to: ss) { (error, scene) in
            guard error == nil else {
                finished(false, error?.localizedDescription ?? "分享失败", scene)
                return
            }
            finished(true, "", scene)
        }
    }
    
    @objc
    static public func register(qqKey: String, qqLink: String, wechatKey: String, wechatLink: String) {
        ShareManager.shared.register(qqKey: qqKey, qqLink: qqLink, wechatKey: wechatKey, wechatLink: wechatLink)
    }
    
    @objc
    static public func handle(continue userActivity: NSUserActivity) -> Bool {
        return ShareManager.shared.handle(continue: userActivity)
    }
    
    @objc
    static public func handle(open url: URL) -> Bool {
        return ShareManager.shared.handle(open: url)
    }
    
}

