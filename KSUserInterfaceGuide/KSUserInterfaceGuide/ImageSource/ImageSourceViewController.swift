//
//  ImageSourceViewController.swift
//  KSUserInterfaceGuide
//
//  Created by Kinsun on 2022/8/11.
//

import UIKit
import KSUserInterface

open class ImageSourceViewController: KSSecondaryViewControllerDefault {
    
    private let _collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 11.0, left: 11.0, bottom: 11.0, right: 11.0)
        layout.minimumLineSpacing = 7.0
        layout.minimumInteritemSpacing = 7.0
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(_Cell.self, forCellWithReuseIdentifier: _Cell.iden)
        return collectionView
    }()
    
    private let _iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isHidden = true
        return imageView
    }()
    
    open override func loadView() {
        super.loadView()
        guard let navigationView = view.navigationView else { return }
        let button = KSTextButton()
        if let label = button.contentView {
            label.font = .boldSystemFont(ofSize: 18.0)
            label.text = "选择照片"
            label.textColor = .ks_black
        }
        button.contentInset = UIEdgeInsets(top: 11.0, left: 11.0, bottom: 11.0, right: 11.0)
        button.addTarget(self, action: #selector(_didClickRightButton), for: .touchUpInside)
        navigationView.addRightView(button)
        _collectionView.dataSource = self
        _collectionView.delegate = self
        view.addSubview(_collectionView)
        view.addSubview(_iconView)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        title = "KSImageSource"
        KSImagePickerController.authorityCheckUp(with: self, type: .photoLibrary) { _ in
            
        } cancelHandler: { [weak self] _ in
            self?.closeCurrentViewController()
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bounds = view.bounds
        _collectionView.frame = bounds
        let windowWidth = bounds.size.width
        let inset = UIEdgeInsets(top: view.navigationView?.frame.maxY ?? 0.0, left: 0.0, bottom: view.safeAreaInsets.bottom, right: 0.0)
        _collectionView.contentInset = inset
        _collectionView.scrollIndicatorInsets = inset
        if let layout = _collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let inset = layout.sectionInset
            let itemW = ceil((windowWidth-inset.left-inset.right-layout.minimumLineSpacing*2.0)/3.0)
            layout.itemSize = CGSize(width: itemW, height: itemW)
        }
        _iconView.frame = CGRect(x: 0.0, y: inset.top, width: windowWidth, height: windowWidth)
    }
    
    @objc private func _didClickRightButton() {
        let alertView = _AlertView(frame: .zero)
        alertView.frame = CGRect(origin: .zero, size: alertView.sizeThatFits(CGSize(width: 280.0, height: .infinity)))
        let alert = KSAlertViewController()
        alert.alertView = KSStrutView(contentView: alertView)
        alert.isFollowKeyboard = true
        alert.isClickBackgroundCloseEnable = true
        
        alertView.cancelButton.add(.touchUpInside) { [weak alert] _ in
            alert?.dismiss(animated: true)
        }
        alertView.okButton.add(.touchUpInside) { [weak alert, weak self] _ in
            alert?.dismiss(animated: true) {
                guard let alertView = (alert?.alertView as? KSStrutView)?.contentView as? _AlertView else { return }
                let index = alertView.segmented.selectedSegmentIndex
                if index == 0 {
                    self?._openEditPhotosLibary(isMask: alertView.maskStyleView.rightView?.isOn ?? false)
                } else {
                    self?._openPhotosLibary(isVideoType: index != 1, count: UInt(alertView.countView.rightView?.text ?? "1") ?? 1)
                }
            }
        }
        
        present(alert, animated: true)
    }
    
    private func _openEditPhotosLibary(isMask: Bool) {
        let ctl = KSImagePickerController(editPictureStyle: isMask ? .circular : .normal)
        ctl.delegate = self
        present(KSNavigationController(rootViewController: ctl), animated: true)
    }
    
    private func _openPhotosLibary(isVideoType: Bool, count: UInt) {
        let ctl = KSImagePickerController(mediaType: isVideoType ? .video : .picture, maxItemCount: count)
        ctl.delegate = self
        present(KSNavigationController(rootViewController: ctl), animated: true)
    }
    
    private var _list: [KSImagePickerItemModel]? {
        didSet {
            _collectionView.reloadData()
        }
    }

}

extension ImageSourceViewController: UICollectionViewDataSource, UICollectionViewDelegate, KSImagePickerControllerDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        _list?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: _Cell.iden, for: indexPath) as! _Cell
        cell.model = _list?[indexPath.item]
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let list = _list, !list.isEmpty {
            let ctl = MediaViewerViewController()
            ctl.willBeginCloseAnimation = { [weak self] in
                self?._collectionView.scrollToItem(at: IndexPath(item: Int($0), section: 0), at: .init(rawValue: 0), animated: false)
            }
            ctl.itemFrameAtIndex = { [weak self] in
                guard let self = self, let cell = self._collectionView.cellForItem(at: IndexPath(item: Int($0), section: 0)) as? _Cell else { return .zero }
                return cell.convert(cell.bounds, to: self.view)
            }
            ctl.getThumbCallback = { [weak self] in
                guard let self = self, let cell = self._collectionView.cellForItem(at: IndexPath(item: Int($0), section: 0)) as? _Cell else { return nil }
                return cell.thumb
            }
            ctl.setDataArray(list, currentIndex: indexPath.item)
            present(ctl, animated: true)
        }
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    public func imagePicker(_ imagePicker: KSImagePickerController, didFinishSelectedAssetModelArray assetModelArray: [KSImagePickerItemModel], mediaType: KSImagePickerController.MediaType) {
        _list = assetModelArray
        _collectionView.isHidden = false
        _iconView.isHidden = true
    }
    
    public func imagePicker(_ imagePicker: KSImagePickerController, didFinishEdit image: UIImage) {
        _collectionView.isHidden = true
        _iconView.image = image
        _iconView.isHidden = false
    }
    
}

extension ImageSourceViewController {
    
    fileprivate class _AlertView: KSStackView {
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public let titleLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 14.0)
            label.textColor = .ks_gray
            label.numberOfLines = 0
            label.text = "Tips！\"编辑照片\"模式为可以进入照片编辑页面一般用于用户选择头像。\"编辑照片\"模式只可以选择一张照片，不可以选择视频。"
            return label
        }()
        
        public let segmented: UISegmentedControl = {
            let segmented = UISegmentedControl(items: ["编辑照片", "多张照片", "多支影片"])
            segmented.selectedSegmentIndex = 0
            return segmented
        }()
        
        public let maskStyleView: _Item<UISwitch> = {
            let view = _Item<UISwitch>()
            view.title = "使用编辑照片页蒙版"
            view.rightView = UISwitch()
            view.isFullRightView = false
            return view
        }()
        
        public let countView: _Item<UITextField> = {
            let textField = UITextField()
            textField.font = .systemFont(ofSize: 16.0)
            textField.textAlignment = .right
            textField.textColor = .ks_black
            textField.placeholder = "请输入数量"
            textField.keyboardType = .numberPad
            let view = _Item<UITextField>()
            view.title = "选择资源的数量"
            view.isEnabled = false
            view.rightView = textField
            return view
        }()
        
        public let cancelButton: KSTextButton = {
            let button = KSTextButton()
            if let label = button.contentView {
                label.font = .systemFont(ofSize: 18.0)
                label.textColor = .ks_black
                label.text = "取消"
            }
            button.contentInset = UIEdgeInsets(top: 7.0, left: 20.0, bottom: 7.0, right: 20.0)
            return button
        }()
        
        public let okButton: KSTextButton = {
            let button = KSTextButton()
            if let label = button.contentView {
                label.font = .systemFont(ofSize: 18.0)
                label.textColor = .ks_black
                label.text = "确定"
            }
            button.contentInset = UIEdgeInsets(top: 7.0, left: 20.0, bottom: 7.0, right: 20.0)
            return button
        }()
        
        override init(frame: CGRect) {
            let operation = KSStackView(subviews: [cancelButton, okButton])
            operation.axis = .horizontal
            operation.stackLayout = .center
            operation.subviewLayout = .bothEnds
            operation.spacing = 40.0
            super.init(subviews: [titleLabel, segmented, maskStyleView, countView, operation])
            backgroundColor = .ks_white
            let layer = self.layer
            layer.cornerRadius = 10.0
            layer.masksToBounds = true
            
            axis = .vertical
            stackLayout = .bothEnds
            subviewLayout = .bothEnds
            spacing = 7.0
            contentInset = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
            
            segmented.add(.valueChanged) { [weak self] in
                guard let seg = $0 as? UISegmentedControl else { return }
                let isFirst = seg.selectedSegmentIndex == 0
                self?.maskStyleView.isEnabled = isFirst
                if let countView = self?.countView {
                    countView.isEnabled = !isFirst
                    if isFirst {
                        countView.rightView?.resignFirstResponder()
                    } else {
                        countView.rightView?.becomeFirstResponder()
                    }
                }
            }
        }
        
    }
    
    private class _Cell: UICollectionViewCell {
        
        public static let iden = "ImageSourceViewController._Cell"
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private let _videoTagLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 11.0)
            label.textAlignment = .center
            label.text = "视频"
            label.textColor = .ks_white
            label.backgroundColor = UIColor(hex: 0x000000, alpha: 0.5)
            return label
        }()
        
        private let _imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            return imageView
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.addSubview(_imageView)
            contentView.addSubview(_videoTagLabel)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            let bounds = contentView.bounds
            _imageView.frame = bounds
            let windowSize = bounds.size
            _videoTagLabel.frame = CGRect(x: 0.0, y: windowSize.height-20.0, width: windowSize.width, height: 20.0)
        }
        
        open var model: KSImagePickerItemModel? {
            didSet {
                guard let model = model else {
                    _imageView.image = nil
                    _videoTagLabel.isHidden = true
                    return
                }
                let asset = model.asset
                _videoTagLabel.isHidden = asset.mediaType != .video
                PHImageManager.default().requestImage(for: asset, targetSize: bounds.size, contentMode: .aspectFill, options: KSImagePickerItemModel.pictureViewerOptions) { [weak _imageView] image, _ in
                    _imageView?.image = image
                }
            }
        }
        
        open var thumb: UIImage? {
            _imageView.image
        }
        
    }
    
}

extension ImageSourceViewController._AlertView {
    
    fileprivate class _Item<V: UIView>: UIControl {
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private let _titleLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16.0)
            label.textColor = .ks_black
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(_titleLabel)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            let windowSize = bounds.size
            let windowWidth = windowSize.width
            let windowHeight = windowSize.height
            let titleSize = _titleLabel.sizeThatFits(windowSize)
            _titleLabel.frame = CGRect(origin: CGPoint(x: 0.0, y: (windowHeight-titleSize.height)*0.5), size: titleSize)
            guard let rightView = rightView else { return }
            let x = _titleLabel.frame.maxX+7.0
            let w = windowWidth-x
            if isFullRightView {
                rightView.frame = CGRect(x: x, y: 0.0, width: w, height: windowHeight)
            } else {
                let rightViewSize = rightView.sizeThatFits(CGSize(width: w, height: windowHeight))
                rightView.frame = CGRect(origin: CGPoint(x: windowWidth-rightViewSize.width, y: (windowHeight-rightViewSize.height)*0.5), size: rightViewSize)
            }
        }
        
        open var title: String? {
            set { _titleLabel.text = newValue }
            get { _titleLabel.text }
        }
        
        open var rightView: V? {
            didSet {
                guard oldValue != rightView else { return }
                oldValue?.removeFromSuperview()
                if let rightView = rightView {
                    addSubview(rightView)
                }
                setNeedsLayout()
            }
        }
        
        open var isFullRightView = true {
            didSet {
                guard oldValue != isFullRightView else { return }
                setNeedsLayout()
            }
        }
        
        override var isEnabled: Bool {
            didSet {
                alpha = isEnabled ? 1.0 : 0.5
            }
        }
        
        override func sizeThatFits(_ size: CGSize) -> CGSize {
            CGSize(width: size.width, height: min(size.height, 40.0))
        }
        
    }
    
}
