//
//  BLShare.swift
//  Beile
//
//  Created by ablett on 2020/8/24.
//  Copyright © 2020 ablettchen@gmail.com. All rights reserved.
//

import UIKit

///// 场景类型
//@objc public enum SceneType: Int, CustomStringConvertible {
//
//    case wechat         = 1
//    case wechatTimeline = 2
//    case QQ             = 4
//    case QZone          = 5
//    case Copy           = 6
//
//    public var description: String {
//        switch self {
//        case .wechat:           return "微信"
//        case .wechatTimeline:   return "微信朋友圈"
//        case .QQ:               return "QQ"
//        case .qZone:            return "QQ空间"
//        case .copy:             return "复制链接"
//        }
//    }
//}

/// 场景
public class Scene: NSObject {
    
    /// 场景类型
    @objc
    public var type: SceneType
    
    /// 图标
    @objc
    public var icon: UIImage
    
    @objc
    public init(type: SceneType, icon: UIImage) {
        self.type = type
        self.icon = icon
    }
    
    public func enable(reource: Any? = nil) -> Bool {
        switch type {
        case .wechat, .wechatTimeline:
            return Wechat.shared.isInstall()
        case .QQ, .qZone:
            return QQ.shared.isInstall()
        case .copy:
            if let o = reource {
                if o is ResourceWeb {
                    return true
                }
            }
            return false
        @unknown default:
            debugPrint("未知场景")
            return false
        }
    }
}






