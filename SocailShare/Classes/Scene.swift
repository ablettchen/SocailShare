//
//  BLShare.swift
//  Beile
//
//  Created by ablett on 2020/8/24.
//  Copyright © 2020 ablettchen@gmail.com. All rights reserved.
//

import UIKit

/// 场景类型
public enum SceneType: Int, CustomStringConvertible {
    
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

/// 场景
public struct Scene {
    
    /// 场景类型
    public var type: SceneType
    
    /// 图标
    public var icon: UIImage
    
    public init(type: SceneType, icon: UIImage) {
        self.type = type
        self.icon = icon
    }
    
    public func enable() -> Bool {
        switch type {
        case .wechat, .wechatTimeline:
            return Wechat.shared.isInstall()
        case .QQ, .QZone:
            return QQ.shared.isInstall()
        }
    }
}






