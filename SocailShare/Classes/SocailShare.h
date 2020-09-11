//
//  SocailShare.h
//  SocailShare
//
//  Created by ablett on 2020/8/28.
//

#ifndef SocailShare_h
#define SocailShare_h

typedef NS_ENUM(NSUInteger, SceneType) {
    SceneTypeWechat         = 1,
    SceneTypeWechatTimeline = 2,
    SceneTypeQQ             = 4,
    SceneTypeQZone          = 5,
    SceneTypeCopy           = 6,
};

NS_INLINE NSString * _Nonnull sceneDescription(SceneType type) {
    switch (type) {
        case SceneTypeWechat:
            return @"微信";
        case SceneTypeWechatTimeline:
            return @"微信朋友圈";
        case SceneTypeQQ:
            return @"QQ";
        case SceneTypeQZone:
            return @"QQ空间";
        case SceneTypeCopy:
            return @"复制链接";
        default: return @"";
    }
}

#endif /* SocailShare_h */
