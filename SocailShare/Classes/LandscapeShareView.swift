//
//  LandscapeShareView.swift
//  SocailShare
//
//  Created by ablett on 2020/9/2.
//

import Foundation
import SnapKit
import ATCategories

public class LandscapeShareView: UIView {
    
    public func show(in view: UIView? = nil, items: [(name: String, icon: UIImage?)], action: ((_ index: Int) -> Void)?) {
        datas = items
        didSelected = action
        
        show(in: view ?? UIApplication.shared.keyWindow!)
    }
    
    private var didSelected: ((Int) -> Void)?
    
    private var datas: [(name: String, icon: UIImage?)] = []
    
    private var didShow: ((_ listView: LandscapeShareView) -> Void)?
    
    private var didHide: ((_ listView: LandscapeShareView) -> Void)?
    
    private lazy var effectView: UIVisualEffectView = {
        let view = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .dark))
        view.isUserInteractionEnabled = true
        return view
    }()
    
    /// 背景视图
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.alpha = 0.001
        return view
    }()

    /// 标题标签
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    public private(set) lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10);
        
        let view = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.isPagingEnabled = true
        view.register(LandscapeItemCell.self, forCellWithReuseIdentifier: "LandscapeItemCell")
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never
        }
        view.backgroundColor = .clear
        view.decelerationRate = .fast
        return view;
    }()
    
    /// 关闭按钮
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.setTitle("取消", for: .normal)
        button.setTitleColor(UIColor(hexString: "#898989"), for: .normal)
        button.addTarget(self, action: #selector(closeAction(_:)), for: .touchUpInside)
        button.backgroundColor = .white
        button.alpha = 0.0
        return button
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension LandscapeShareView {
    
    func prepare() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        
        backgroundView.addGestureRecognizer(tap)
        backgroundView.backgroundColor = .clear
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

private extension LandscapeShareView {
    
    @objc func closeAction(_ sender: UIButton) {
        hide()
    }
    
    @objc func tapAction(_ sender: UITapGestureRecognizer) {
        hide()
    }
    
    func show(in view: UIView, completion: ((Bool) -> Void)?) -> Void {
        
        if self.superview != nil {return}
        view.addSubview(backgroundView)
        backgroundView.snp.remakeConstraints { (make) in
            make.edges.equalTo(view)
        }
        backgroundView.alpha = 1.0
        
        backgroundView.addSubview(effectView)
        effectView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        backgroundView.addSubview(self)
        self.snp.remakeConstraints { (make) in
            make.size.equalTo(CGSize(width: 380, height: 305))
            make.center.equalToSuperview()
        }
        
        addSubview(titleLabel)
        titleLabel.snp.remakeConstraints { (make) in
            make.left.right.equalToSuperview().inset(22)
            make.top.equalToSuperview().offset(25)
            make.height.equalTo(40)
        }
        titleLabel.text = "分享到"
        
        let topLine = UIView()
        topLine.alpha = 0.0
        topLine.backgroundColor = UIColor(hexString: "#eeeeee")
        addSubview(topLine)
        topLine.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(13)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        let unSafeArea = UIView()
        unSafeArea.alpha = 0.0
        unSafeArea.backgroundColor = .white
        addSubview(unSafeArea)
        unSafeArea.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(0.01)
        }
        
        addSubview(closeButton)
        closeButton.snp.remakeConstraints { (make) in
            make.bottom.equalTo(unSafeArea.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(80)
        }
        
        let botLine = UIView()
        botLine.alpha = 0.0
        botLine.backgroundColor = UIColor(hexString: "#eeeeee")
        addSubview(botLine)
        botLine.snp.makeConstraints { (make) in
            make.bottom.equalTo(closeButton.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(topLine.snp.bottom)
            make.bottom.equalTo(botLine.snp.top)
            make.left.right.equalToSuperview()
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        
        self.superview?.layoutIfNeeded()
        bringSubviewToFront(view)
        let opitons = AnimationOptions(
            rawValue:(UIView.AnimationOptions.curveEaseOut.rawValue | UIView.AnimationOptions.beginFromCurrentState.rawValue)
        )
        UIView.animate(withDuration: 0.25, delay: 0, options: opitons, animations: { [weak self] in
            self?.alpha = 1.0
        }) { (finished) in
            completion?(finished)
        }
    }
    
    func hide(completion: ((Bool) -> Void)?) -> Void {
        if self.superview == nil {return}
        self.backgroundView.alpha = 0.001
        self.alpha = 0.001
        self.removeFromSuperview()
        self.backgroundView.removeFromSuperview()
        completion?(true)
    }
    
}

extension LandscapeShareView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}

extension LandscapeShareView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LandscapeItemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LandscapeItemCell", for: indexPath) as! LandscapeItemCell
        cell.title = datas[indexPath.item].name
        cell.icon = datas[indexPath.item].icon
        return cell
    }
}

extension LandscapeShareView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        hide { [weak self] (finished) in
            self?.didSelected?(indexPath.item)
        }
    }
}

extension LandscapeShareView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.superview?.layoutIfNeeded()
        return CGSize(width: collectionView.at_height / 2.0, height: collectionView.at_height)
    }
}

class LandscapeItemCell: UICollectionViewCell {
    
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
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    lazy var iconView: UIImageView = {
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
    
    func prepare() {
        backgroundColor = .clear
        
        addSubview(titleLabel)
        addSubview(iconView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let iconSize = CGSize(width: 55, height: 55)
        let space: CGFloat = 20.0
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
