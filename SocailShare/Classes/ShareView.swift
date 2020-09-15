//
//  ShareView.swift
//  Beile
//
//  Created by ablett on 2020/8/24.
//  Copyright © 2020 ablettchen@gmail.com. All rights reserved.
//

import UIKit
import SnapKit
import ATCategories

public class ShareView: UIView {
    
    public func show(in view: UIView? = nil, items: [(name: String, icon: UIImage?)], action: ((_ index: Int) -> Void)?) {
        datas = items
        didSelected = action
        show(in: view ?? UIApplication.shared.keyWindow!)
    }
    
    private var didSelected: ((Int) -> Void)?
    
    private var datas: [(name: String, icon: UIImage?)] = []
    
    private var didShow: ((_ listView: ShareView) -> Void)?
    
    private var didHide: ((_ listView: ShareView) -> Void)?
    
    private lazy var effectView: UIVisualEffectView = {
        let view = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .extraLight))
        return view
    }()

    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.alpha = 0.001
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = UIColor(hexString: "#898989")
        label.textAlignment = .center
        return label
    }()
    
    public private(set) lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10);
        
        let view = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.isPagingEnabled = true
        view.register(ShareItemCell.self, forCellWithReuseIdentifier: "ShareItemCell")
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never
        }
        view.backgroundColor = .clear
        view.decelerationRate = .fast
        return view;
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.setTitle("取消", for: .normal)
        button.setTitleColor(UIColor(hexString: "#898989"), for: .normal)
        button.addTarget(self, action: #selector(closeAction(_:)), for: .touchUpInside)
        button.backgroundColor = .white
        return button
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let topInset: CGFloat = 15
    private var contentHeight: CGFloat = 140
    private let buttonHeight: CGFloat = 50
}

private extension ShareView {
    
    func prepare() {
        backgroundColor = .white
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        backgroundView.addGestureRecognizer(tap)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    private func show(in view: UIView) {
        show(in: view) { [weak self] (finished) in
            self?.didShow?(self!)
        }
    }
    
    private func hide() {
        hide { [weak self] (finished) in
            self?.didHide?(self!)
        }
    }
}

private extension ShareView {
    
    @objc func closeAction(_ sender: UIButton) {
        hide()
    }
    
    @objc func tapAction(_ sender: UITapGestureRecognizer) {
        hide()
    }
    
    func show(in view: UIView, completion: ((Bool) -> Void)?) -> Void {

        if self.superview != nil {return}
        
        if UIDevice.current.isiPhone5() {
            contentHeight = 120
        }
        
        view.addSubview(backgroundView)
        backgroundView.snp.remakeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        backgroundView.addSubview(self)
        self.snp.remakeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalTo(topInset + contentHeight + buttonHeight + (UIDevice.current.isiPhoneX() ? 34 : 0))
            make.top.equalTo(backgroundView.snp.bottom)
        }
        self.superview?.layoutIfNeeded()
        
        self.filletedCorner(
            CGSize(width: 15, height: 15),
            UIRectCorner(rawValue: (UIRectCorner.topLeft.rawValue) | (UIRectCorner.topRight.rawValue))
        )
        
        let unSafeArea = UIView()
        unSafeArea.backgroundColor = .white
        addSubview(unSafeArea)
        unSafeArea.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(UIDevice.current.isiPhoneX() ? 34 : 0.01)
        }
        
        addSubview(closeButton)
        closeButton.snp.remakeConstraints { (make) in
            make.bottom.equalTo(unSafeArea.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(buttonHeight)
        }
        
        let botLine = UIView()
        botLine.backgroundColor = UIColor(hexString: "#eeeeee")
        addSubview(botLine)
        botLine.snp.makeConstraints { (make) in
            make.bottom.equalTo(closeButton.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.bottom.equalTo(botLine.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(contentHeight)
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        
        self.superview?.layoutIfNeeded()
        bringSubviewToFront(view)
        let opitons = AnimationOptions(
            rawValue:(UIView.AnimationOptions.curveEaseOut.rawValue | UIView.AnimationOptions.beginFromCurrentState.rawValue)
        )
        UIView.animate(withDuration: 0.25, delay: 0, options: opitons, animations: { [weak self] in
            self?.backgroundView.alpha = 1.0
            self?.snp.remakeConstraints { (make) in
                make.width.equalToSuperview()
                make.height.equalTo(self!.topInset + self!.contentHeight + self!.buttonHeight + (UIDevice.current.isiPhoneX() ? 34 : 0))
                make.bottom.equalToSuperview()
            }
            self?.superview?.layoutIfNeeded()
        }) { (finished) in
            completion?(finished)
        }
    }
    
    func hide(completion: ((Bool) -> Void)?) -> Void {
        if self.superview == nil {return}
        let opitons = AnimationOptions(
            rawValue:(UIView.AnimationOptions.curveEaseIn.rawValue | UIView.AnimationOptions.beginFromCurrentState.rawValue)
        )
        UIView.animate(withDuration: 0.25, delay: 0, options: opitons, animations: {[weak self] in
            self?.backgroundView.alpha = 0.001
            self?.snp.remakeConstraints { (make) in
                make.width.equalToSuperview()
                make.height.equalTo(self!.topInset + self!.contentHeight + self!.buttonHeight + (UIDevice.current.isiPhoneX() ? 34 : 0))
                make.top.equalTo(self!.backgroundView.snp.bottom)
            }
            self?.superview?.layoutIfNeeded()
        }) { [weak self] (finished) in
            self?.removeFromSuperview()
            self?.backgroundView.removeFromSuperview()
            completion?(true)
        }
    }
    
}

extension ShareView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view?.isEqual(backgroundView) ?? false
    }
}

extension ShareView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ShareItemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShareItemCell", for: indexPath) as! ShareItemCell
        cell.title = datas[indexPath.item].name
        cell.icon = datas[indexPath.item].icon
        return cell
    }
}

extension ShareView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        hide { [weak self] (finished) in
            self?.didSelected?(indexPath.item)
        }
    }
}

extension ShareView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.superview?.layoutIfNeeded()
        return CGSize(width: collectionView.at_height / 2.0, height: collectionView.at_height)
    }
}

class ShareItemCell: UICollectionViewCell {
    
    public var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    public var icon: UIImage? {
        didSet {
            iconView.image = icon
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = UIColor(hexString: "#666666")
        label.textAlignment = .center
        return label
    }()
    
    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func prepare() {
        backgroundColor = .clear
        addSubview(titleLabel)
        addSubview(iconView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let iconSize = CGSize(width: 55, height: 55)
        let space: CGFloat = 10.0
        let titleHeigit: CGFloat = 11.0
        
        iconView.snp.remakeConstraints { (make) in
            make.size.equalTo(iconSize)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset((at_height - iconSize.height - space - titleHeigit) / 2.0)
        }
        
        titleLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(iconView.snp.bottom).offset(space)
            make.centerX.equalToSuperview()
            make.height.equalTo(titleHeigit)
        }
    }
}

fileprivate extension UIView {
    
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

fileprivate extension UIDevice {
    
    func isiPhoneX() -> Bool {
        let screenHeight = UIScreen.main.nativeBounds.size.height;
        if screenHeight == 2436 || screenHeight == 1792 || screenHeight == 2688 || screenHeight == 1624 {
            return true
        }
        return false
    }
    
    func isiPhone5() -> Bool {
        let screenHeight = UIScreen.main.nativeBounds.size.height;
        if screenHeight == 1136 {
            return true
        }
        return false
    }
}
