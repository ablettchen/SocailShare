//
//  Resource.swift
//  SocailShare
//
//  Created by ablett on 2020/9/3.
//

import Foundation

/// 网页
public struct ResourceWeb {
    
    /// 链接
    public var url: String
    
    /// 标题
    public var title: String
    
    /// 描述
    public var description: String
    
    /// 缩略图
    public var thumb: UIImage
    
    public init( url: String, title: String, description: String, thumb: UIImage) {
        self.url = url
        self.title = title
        self.description = description
        self.thumb = thumb
    }
}
