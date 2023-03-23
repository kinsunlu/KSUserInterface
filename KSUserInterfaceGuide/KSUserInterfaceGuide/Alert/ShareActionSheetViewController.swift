//
//  ShareActionSheetViewController.swift
//  KSUserInterfaceGuide
//
//  Created by Kinsun on 2022/4/1.
//

import UIKit
import KSUserInterface

/// 一个分享页面的实现方式
open class ShareActionSheetViewController: KSActionSheetViewController {
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = "分享到"
    }
    
    private lazy var _contentView = UIImageView(image: UIImage(named: "img_share_poster_universe.jpg"))
    
    open override func loadView() {
        super.loadView()
        view.insertSubview(_contentView, at: 0)
    }

    open override func loadActionSheetView() -> UIView {
        let view = View()
        view.titleLabel.text = title
        view.modelArray = modelArray
        view.cancelButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        return view
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let view = self.view
        let top, bottom: CGFloat
        if #available(iOS 11.0, *) {
            let inset = view.safeAreaInsets
            top = inset.top
            bottom = inset.bottom
        } else {
            top = 0.0
            bottom = 0.0
        }
        let windowSize = view.bounds.size
        let actionSheetHeight = actionSheetView.sizeThatFits(windowSize).height+bottom
        let margin = CGFloat(20.0)
        let viewY = margin+top
        let viewH = windowSize.height-actionSheetHeight-viewY-margin
        let viewW = ceil(viewH*0.462)
        let viewX = (windowSize.width-viewW)*0.5
        _contentView.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
    }
    
    open override var title: String? {
        didSet {
            if isViewLoaded, let view = actionSheetView as? View {
                view.titleLabel.text = title
            }
        }
    }
    
    open lazy var modelArray: [Model] = {
        let c: (Model, UIViewController) -> Void = {
            let ctl = KSSecondaryViewController()
            ctl.title = $0.title
            $1.push(ctl)
        }
        return [Model(title: "微信", icon: #imageLiteral(resourceName: "icon_share_wechat"), operations: c),
                Model(title: "朋友圈", icon: #imageLiteral(resourceName: "icon_share_timeline"), operations: c),
                Model(title: "QQ", icon: #imageLiteral(resourceName: "icon_share_qq"), operations: c),
                Model(title: "QQ空间", icon: #imageLiteral(resourceName: "icon_share_qzone"), operations: c)]
    }()

}

extension ShareActionSheetViewController {
    
    open class View: UIView {
        
        public required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public let titleLabel: UILabel = {
            let label = UILabel()
            label.font = .boldSystemFont(ofSize: 14.0)
            label.textColor = .ks_black
            label.textAlignment = .center
            return label
        }()
        
        private let _line: CALayer = {
            let layer = CALayer()
            layer.backgroundColor = UIColor.ks_lightGray.cgColor
            return layer
        }()
        
        public let cancelButton: KSTextButton = {
            let button = KSTextButton()
            if let titleLabel = button.contentView {
                titleLabel.font = .systemFont(ofSize: 14.0)
                titleLabel.textColor = .ks_lightGray7
                titleLabel.text = "取消"
            }
            return button
        }()
        
        public override init(frame: CGRect) {
            super.init(frame: frame)
            if #available(iOS 11.0, *) {
                let layer = layer
                layer.cornerRadius = 9.0
                layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                layer.masksToBounds = true
            }
            backgroundColor = .ks_white
            addSubview(titleLabel)
            layer.addSublayer(_line)
            addSubview(cancelButton)
        }
        
        open override func layoutSubviews() {
            super.layoutSubviews()
            guard let items = _items, !items.isEmpty else { return }
            let windowSize = bounds.size
            let windowWidth = windowSize.width
            let windowHeight = windowSize.height
            titleLabel.frame = CGRect(x: 0.0, y: 24.0, width: windowWidth, height: 20.0)
            var viewH = CGFloat(50.0)
            cancelButton.frame = CGRect(x: 0.0, y: windowHeight-viewH, width: windowWidth, height: viewH)
            viewH = 1.0
            _line.frame = CGRect(x: 0.0, y: cancelButton.frame.minY-viewH, width: windowWidth, height: viewH)
            let viewY = titleLabel.frame.maxY
            let maxHeight = _line.frame.minY-viewY
            let marginH = CGFloat(40.0)
            let maxWidth = (windowWidth-marginH*2.0)/CGFloat(items.count)
            let margin = (maxWidth-(maxHeight-66.0))*0.5 /// 17+8+17+24=66
            let imageViewInset = UIEdgeInsets(top: 17.0, left: margin, bottom: 8.0, right: margin)
            let titleLabelInset = UIEdgeInsets(top: 8.0, left: 0.0, bottom: 24.0, right: 0.0)
            items.enumerated().forEach {
                let item = $0.1
                item.imageViewInset = imageViewInset
                item.titleLabelInset = titleLabelInset
                let viewX = maxWidth*CGFloat($0.0)+marginH
                item.frame = CGRect(x: viewX, y: viewY, width: maxWidth, height: maxHeight)
            }
        }
        
        /// ⚠️⚠️⚠️⚠️⚠️一定要实现这个方法，ShareActionSheetViewController才能知道ActionSheetView的size是什么。
        /// - Parameter size: 最大尺寸（superview的size）
        /// - Returns: ActionSheetView的size
        open override func sizeThatFits(_ size: CGSize) -> CGSize {
            /// 15+15+20+1+40+17+8+40+17+20+24=217
            CGSize(width: size.width, height: 217.0)
        }
        
        private var _items: [_Item]? {
            didSet {
                oldValue?.forEach { $0.removeFromSuperview() }
            }
        }
        
        open var modelArray: [Model]? {
            didSet {
                let selector = #selector(_didClick(item:))
                _items = modelArray?.map { [weak self] in
                    let item = _Item()
                    item.model = $0
                    item.addTarget(self, action: selector, for: .touchUpInside)
                    self?.addSubview(item)
                    return item
                }
            }
        }
        
        @objc private func _didClick(item: _Item) {
            guard let controller: UIViewController = find(),
                      let model = item.model else { return }
            model.operations(model, controller)
        }
        
    }
    
    public struct Model {
        
        public let title: String
        public let icon: UIImage?
        public let operations: (Self, UIViewController) -> Void
        
        init(title: String, icon: UIImage?, operations: @escaping (Self, UIViewController) -> Void) {
            self.title = title
            self.icon = icon
            self.operations = operations
        }
        
    }
    
}

extension ShareActionSheetViewController.View {
    
    private class _Item: KSItemButton {
        
        open var model: ShareActionSheetViewController.Model? {
            didSet {
                imageView?.image = model?.icon
                titleLabel?.text = model?.title
            }
        }
        
    }
    
}
