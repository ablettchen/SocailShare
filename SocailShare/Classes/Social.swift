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
    
    /// 重定向链接
    public var redirectURL: String

    
    /// 分享文本
    /// - Parameters:
    ///   - text: 文本
    ///   - finished: 完成回调
    public func shareText(_ text: String, finished: ((_ error: Error?) -> Void)?) {
        guard prepare(exception: finished) else {return}
        debugPrint("share \(text) to \(self.type)")
        
    }
    
    /// 分享图片
    /// - Parameters:
    ///   - image: 图片
    ///   - finished: 完成回调
    public func shareImage(_ image: UIImage, finished: ((_ error: Error?) -> Void)?) {
        guard prepare(exception: finished) else {return}
        debugPrint("share \(image) to \(self.type)")
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
    }
    
    /// 信息注册
    public func register() {
        
    }
    
    /// 检测是否安装
    /// - Returns: 是否安装
    public func isInstall() -> Bool {
        return true
    }
    
    public init(type: SocialType, icon: UIImage, appKey: String, appSecret: String, redirectURL: String) {
        self.type = type
        self.icon = icon
        self.appKey = appKey
        self.appSecret = appSecret
        self.redirectURL = redirectURL
    }
    
}

private extension Social {
    
    /// 准备
    /// - Parameter exception: 完成回调
    func prepare(exception: ((_ error: Error) -> Void)?) -> Bool {
        
        register()
        
        guard isInstall() else {
            let error = NSError(domain: "Social", code: 10000, userInfo: [NSLocalizedDescriptionKey : "\(type)未安装"])
            exception?(error)
            return false
        }
        
        return true
    }
}

