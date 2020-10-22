//
//  Extensions.swift
//  SocailShare
//
//  Created by ablett on 2020/9/17.
//

extension UIImage {
    
    func compress(refer: uint) -> Data? {
        var count: CGFloat = 1
        var data = self.jpegData(compressionQuality: count)
        if (data?.count ?? 0 ) < refer {return data}
        var max: CGFloat = 1
        var min: CGFloat = 0
        for _ in 0 ..< 6 {
            count = (max + min) / 2.0
            data = self.jpegData(compressionQuality: count)
            if CGFloat(data?.count ?? 0) < CGFloat(refer) * 0.9 {
                min = count
            }else if CGFloat(data?.count ?? 0) > CGFloat(refer) {
                max = count
            }else {
                break
            }
        }
        return data
    }
}

extension UIView {
    
    func filletedCorner(_ cornerRadii:CGSize,_ roundingCorners:UIRectCorner)  {
        let fieldPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: roundingCorners, cornerRadii:cornerRadii)
        let fieldLayer = CAShapeLayer()
        fieldLayer.frame = bounds
        fieldLayer.path = fieldPath.cgPath
        self.layer.mask = fieldLayer
    }
    
    func removeAllSubviews() {
        while subviews.count > 0 {
            subviews.last?.removeFromSuperview()
        }
    }
}


extension UIDevice {
    
    func isiPhoneX() -> Bool {
        let isiOS11 = systemVersionLessThanOrEqualTo(version: "11")
        let minHeight = min(UIScreen.main.nativeBounds.size.width, UIScreen.main.nativeBounds.size.height)
        let maxLength = max(UIScreen.main.nativeBounds.size.width, UIScreen.main.nativeBounds.size.height)
        return isiOS11 && isPhone() && (minHeight >= 375  && maxLength >= 812)
    }
    
    func isiPhone5() -> Bool {
        let screenHeight = UIScreen.main.nativeBounds.size.height;
        if isPhone() && screenHeight == 1136 {
            return true
        }
        return false
    }
    
    func isPhone() -> Bool {
        return userInterfaceIdiom == .phone
    }
    
    func systemVersionLessThanOrEqualTo(version: String) -> Bool {
        let options: NSString.CompareOptions = [.numeric]
        let value = systemVersion.compare(version, options: options, range: nil, locale: nil)
        return value != ComparisonResult.orderedDescending
    }
}
