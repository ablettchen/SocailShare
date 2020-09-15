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
    static public func shareImage(data: Data, to type: SceneType, finished: @escaping((_ success: Bool, _ errorMessage: String) -> Void)) {
        ShareManager.shared.share(resource: data, to: type) { (error) in
            guard error == nil else {
                finished(false, error?.localizedDescription ?? "分享失败")
                return
            }
            finished(true, "")
        }
    }
    
    @objc
    static public func shareImage(url: URL, to type: SceneType, finished: @escaping((_ success: Bool, _ errorMessage: String) -> Void)) {
        ShareManager.shared.share(resource: url, to: type) { (error) in
            guard error == nil else {
                finished(false, error?.localizedDescription ?? "分享失败")
                return
            }
            finished(true, "")
        }
    }
    
    @objc
    static public func shareWeb(url: String, title: String, description: String, thumbData: Data, to type: SceneType, finished: @escaping((_ success: Bool, _ errorMessage: String) -> Void)) {
        let web = ResourceWeb(url: url, title: title, description: description, thumb: thumbData)
        ShareManager.shared.share(resource: web, to: type) { (error) in
            guard error == nil else {
                finished(false, error?.localizedDescription ?? "分享失败")
                return
            }
            finished(true, "")
        }
    }
    
    @objc
    static public func shareWeb(url: String, title: String, description: String, thumbURL: URL, to type: SceneType, finished: @escaping((_ success: Bool, _ errorMessage: String) -> Void)) {
        let web = ResourceWeb(url: url, title: title, description: description, thumb: thumbURL)
        ShareManager.shared.share(resource: web, to: type) { (error) in
            guard error == nil else {
                finished(false, error?.localizedDescription ?? "分享失败")
                return
            }
            finished(true, "")
        }
    }
    
    @objc
    static public func show(imageData: Data, finished: @escaping((_ success: Bool, _ errorMessage: String, _ scene: Scene) -> Void)) {
        ShareManager.shared.show(resource: imageData) { (error, scene) in
            guard error == nil else {
                finished(false, error?.localizedDescription ?? "分享失败", scene)
                return
            }
            finished(true, "", scene)
        }
    }
    
    @objc
    static public func show(imageURL: URL, finished: @escaping((_ success: Bool, _ errorMessage: String, _ scene: Scene) -> Void)) {
        ShareManager.shared.show(resource: imageURL) { (error, scene) in
            guard error == nil else {
                finished(false, error?.localizedDescription ?? "分享失败", scene)
                return
            }
            finished(true, "", scene)
        }
    }
    
    @objc
    static public func show(imageData: Data, to types: [NSInteger], finished: @escaping((_ success: Bool, _ errorMessage: String, _ scene: Scene) -> Void)) {
        var ss: [SceneType] = []
        for type in types {
            if let s = SceneType(rawValue: UInt(type)) {
                ss.append(s)
            }
        }
        ShareManager.shared.show(resource: imageData, to: ss) { (error, scene) in
            guard error == nil else {
                finished(false, error?.localizedDescription ?? "分享失败", scene)
                return
            }
            finished(true, "", scene)
        }
    }
    
    @objc
    static public func show(imageURL: URL, to types: [NSInteger], finished: @escaping((_ success: Bool, _ errorMessage: String, _ scene: Scene) -> Void)) {
        var ss: [SceneType] = []
        for type in types {
            if let s = SceneType(rawValue: UInt(type)) {
                ss.append(s)
            }
        }
        ShareManager.shared.show(resource: imageURL, to: ss) { (error, scene) in
            guard error == nil else {
                finished(false, error?.localizedDescription ?? "分享失败", scene)
                return
            }
            finished(true, "", scene)
        }
    }
    
    @objc
    static public func show(webUrl: String, title: String, description: String, thumbData: Data, finished: @escaping((_ success: Bool, _ errorMessage: String, _ scene: Scene) -> Void)) {
        let web = ResourceWeb(url: webUrl, title: title, description: description, thumb: thumbData)
        ShareManager.shared.show(resource: web) { (error, scene) in
            guard error == nil else {
                finished(false, error?.localizedDescription ?? "分享失败", scene)
                return
            }
            finished(true, "", scene)
        }
    }
    
    @objc
    static public func show(webUrl: String, title: String, description: String, thumbData: Data, isLandscape: Bool, finished: @escaping((_ success: Bool, _ errorMessage: String, _ scene: Scene) -> Void)) {
        let web = ResourceWeb(url: webUrl, title: title, description: description, thumb: thumbData)
        ShareManager.shared.show(resource: web, isLandscape: isLandscape) { (error, scene) in
            guard error == nil else {
                finished(false, error?.localizedDescription ?? "分享失败", scene)
                return
            }
            finished(true, "", scene)
        }
    }

    @objc
    static public func show(webUrl: String, title: String, description: String, thumbURL: URL, finished: @escaping((_ success: Bool, _ errorMessage: String, _ scene: Scene) -> Void)) {
        let web = ResourceWeb(url: webUrl, title: title, description: description, thumb: thumbURL)
        ShareManager.shared.show(resource: web) { (error, scene) in
            guard error == nil else {
                finished(false, error?.localizedDescription ?? "分享失败", scene)
                return
            }
            finished(true, "", scene)
        }
    }
    
    @objc
    static public func show(webUrl: String, title: String, description: String, thumbURL: URL, isLandscape: Bool, finished: @escaping((_ success: Bool, _ errorMessage: String, _ scene: Scene) -> Void)) {
        let web = ResourceWeb(url: webUrl, title: title, description: description, thumb: thumbURL)
        ShareManager.shared.show(resource: web, isLandscape: isLandscape) { (error, scene) in
            guard error == nil else {
                finished(false, error?.localizedDescription ?? "分享失败", scene)
                return
            }
            finished(true, "", scene)
        }
    }
    
    @objc
    static public func show(webUrl: String, title: String, description: String, thumbData: Data, to types: [NSInteger], finished: @escaping((_ success: Bool, _ errorMessage: String, _ scene: Scene) -> Void)) {
        var ss: [SceneType] = []
        for type in types {
            if let s = SceneType(rawValue: UInt(type)) {
                ss.append(s)
            }
        }
        let web = ResourceWeb(url: webUrl, title: title, description: description, thumb: thumbData)
        ShareManager.shared.show(resource: web, to: ss) { (error, scene) in
            guard error == nil else {
                finished(false, error?.localizedDescription ?? "分享失败", scene)
                return
            }
            finished(true, "", scene)
        }
    }
    
    @objc
    static public func show(webUrl: String, title: String, description: String, thumbURL: URL, to types: [NSInteger], finished: @escaping((_ success: Bool, _ errorMessage: String, _ scene: Scene) -> Void)) {
        var ss: [SceneType] = []
        for type in types {
            if let s = SceneType(rawValue: UInt(type)) {
                ss.append(s)
            }
        }
        let web = ResourceWeb(url: webUrl, title: title, description: description, thumb: thumbURL)
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

