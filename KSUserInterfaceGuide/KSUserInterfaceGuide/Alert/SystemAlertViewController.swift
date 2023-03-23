//
//  SystemAlertViewController.swift
//  KSUserInterfaceGuide
//
//  Created by Kinsun on 2022/8/12.
//

import UIKit
import KSUserInterface

/// 一个简单的自定义Alert实现方式
open class SystemAlertViewController: KSAlertViewController {

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public let body: NSAttributedString
    
    public init(body: NSAttributedString) {
        self.body = body
        super.init(nibName: nil, bundle: nil)
    }
    
    open override func loadAlertView() -> UIView {
        let view = AlertView()
        view.contentInset = contentInset
        view.body = body
        return view
    }
    
    open var contentInset = UIEdgeInsets(top: 24.0, left: 24.0, bottom: 24.0, right: 24.0) {
        didSet {
            if isViewLoaded, let view = alertView as? AlertView {
                view.contentInset = contentInset
            }
        }
    }
    
    open var buttons: [Button] {
        (alertView as! AlertView).buttons
    }
    
    open func add(button: Button) {
        (alertView as! AlertView).add(button: button)
        button.addTarget(self, action: #selector(_didClick(button:)), for: .touchUpInside)
    }
    
    open func remove(button: Button) {
        (alertView as! AlertView).remove(button: button)
    }
    
    open var didClickButtonCallback: ((SystemAlertViewController, Button) -> Void)?
    
    @objc private func _didClick(button: KSTextButton) {
        if let c = didClickButtonCallback {
            c(self, button as! Button)
        } else {
            close()
        }
    }
    
    convenience public init(title: String? = nil, titleColor: UIColor = .ks_black, message: Any? = nil) {
        lazy var attributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 17.0), .foregroundColor: titleColor, .paragraphStyle: {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineSpacing = 4.0
            paragraphStyle.paragraphSpacing = 8.0
            paragraphStyle.lineBreakMode = .byCharWrapping
            return paragraphStyle
        }()]
        let body: NSMutableAttributedString
        if let title = title, !title.isEmpty {
            body = NSMutableAttributedString(string: title, attributes: attributes)
        } else {
            body = NSMutableAttributedString()
        }
        if let message = message {
            if body.length > 0 {
                body.append(NSAttributedString(string: "\n", attributes: attributes))
            }
            if let m = message as? String {
                let paragraphStyle2 = NSMutableParagraphStyle()
                paragraphStyle2.alignment = .left
                paragraphStyle2.lineSpacing = 4.0
                paragraphStyle2.paragraphSpacing = 4.0
                paragraphStyle2.lineBreakMode = .byCharWrapping
                body.append(NSAttributedString(string: m, attributes: [.font: UIFont.systemFont(ofSize: 13.0), .foregroundColor: UIColor.ks_lightGray7, .paragraphStyle: paragraphStyle2]))
            } else if let m = message as? NSAttributedString {
                body.append(m)
            }
        }
        self.init(body: body)
    }
    
    convenience public init(title: String, strongMessage: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.0
        paragraphStyle.paragraphSpacing = 4.0
        paragraphStyle.lineBreakMode = .byCharWrapping
        paragraphStyle.alignment = .center
        let m = NSAttributedString(string: strongMessage, attributes: [.font: UIFont.systemFont(ofSize: 14.0), .foregroundColor: UIColor.ks_black, .paragraphStyle: paragraphStyle])
        self.init(title: title, message: m)
    }

}

extension SystemAlertViewController {
    
    open class AlertView: UIView {
        
        public required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private let _contentLabel: UILabel = {
            let label = UILabel()
            label.numberOfLines = 0
            return label
        }()
        
        public override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .ks_white
            let layer = self.layer
            layer.cornerRadius = 9.0
            layer.masksToBounds = true
            addSubview(_contentLabel)
        }
        
        open override func layoutSubviews() {
            super.layoutSubviews()
            let windowSize = bounds.size
            let windowWidth = windowSize.width
            let left = contentInset.left
            let margin = CGFloat(12.0)
            let count = CGFloat(buttons.count)
            let maxW = windowWidth-left-contentInset.right
            let viewH = CGFloat(38.0)
            let viewY = windowSize.height-viewH-contentInset.bottom
            if buttons.count <= 1 {
                if let button = buttons.first {
                    let viewW = CGFloat(146.0)
                    button.frame = CGRect(x: (windowWidth-viewW)*0.5, y: viewY, width: viewW, height: viewH)
                }
            } else {
                let viewW = floor((maxW-margin*(count-1))/count)
                buttons.enumerated().forEach {
                    let viewX = (viewW+margin)*CGFloat($0.0)+left
                    $0.1.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
                }
            }
            let top = contentInset.top
            _contentLabel.frame = CGRect(x: left, y: top, width: maxW, height: viewY-24.0-top)
        }
        
        /// ⚠️⚠️⚠️⚠️⚠️一定要实现这个方法，KSAlertViewController才能知道AlertView的size是什么。
        /// - Parameter size: 最大尺寸（superview的size）
        /// - Returns: AlertView的size
        open override func sizeThatFits(_ size: CGSize) -> CGSize {
            let width = min(size.width, 327.0)
            let def = contentInset.top+contentInset.bottom+62.0 /// 24+38=62
            let maxH = size.height-def
            let maxW = width-contentInset.left-contentInset.right
            let r = _contentLabel.sizeThatFits(CGSize(width: maxW, height: maxH))
            return CGSize(width: width, height: r.height+def)
        }
        
        open var contentInset = UIEdgeInsets.zero {
            didSet { setNeedsLayout() }
        }
        
        open var body: NSAttributedString? {
            set { _contentLabel.attributedText = newValue }
            get { _contentLabel.attributedText }
        }
        
        open private(set) var buttons = [Button]()
        
        open func add(button: Button) {
            guard !buttons.contains(button) else { return }
            addSubview(button)
            buttons.append(button)
            setNeedsLayout()
        }
        
        open func remove(button: Button) {
            guard buttons.contains(button) else { return }
            button.removeFromSuperview()
            buttons.removeAll { $0 == button }
            setNeedsLayout()
        }
        
    }
    
    open class Button: KSTextButton {
        
        public enum Style {
            case normal, highlight, appropriate, striking
        }
        
        public required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override init(frame: CGRect) {
            super.init(frame: frame)
            if let label = contentView {
                label.font = .boldSystemFont(ofSize: 16.0)
                label.textColor = UIColor(hex: 0x1A1A1A)
                label.adjustsFontSizeToFitWidth = true
            }
            backgroundColor = .ks_white
            contentInset = UIEdgeInsets(top: 8.0, left: 12.0, bottom: 8.0, right: 12.0)
            let layer = self.layer as! CAGradientLayer
            layer.cornerRadius = 9.0
            layer.masksToBounds = true
            layer.borderColor = UIColor.ks_lightGray7.cgColor
            layer.borderWidth = 1.0
            layer.colors = [UIColor(hex: 0x8E75FE).cgColor, UIColor(hex: 0xA094FF).cgColor]
            layer.startPoint = CGPoint(x: 0.0, y: 0.5)
            layer.endPoint = CGPoint(x: 1.0, y: 0.5)
            defer { style = .normal }
        }
        
        open var style = Style.normal {
            didSet {
                let layer = self.layer as! CAGradientLayer
                switch style {
                case .normal:
                    backgroundColor = .ks_white
                    layer.colors = nil
                    layer.borderColor = UIColor.ks_lightGray7.cgColor
                    layer.borderWidth = 1.0
                    contentView?.textColor = UIColor(hex: 0x1A1A1A)
                case .highlight:
                    layer.colors = [UIColor(hex: 0x8E75FE).cgColor, UIColor(hex: 0xA094FF).cgColor]
                    layer.startPoint = CGPoint(x: 0.0, y: 0.5)
                    layer.endPoint = CGPoint(x: 1.0, y: 0.5)
                    layer.borderWidth = 0.0
                    contentView?.textColor = .ks_white
                case .appropriate:
                    backgroundColor = .clear
                    let color = UIColor.ks_main
                    layer.colors = nil
                    layer.borderColor = color.cgColor
                    layer.borderWidth = 1.0
                    contentView?.textColor = color
                case .striking:
                    layer.colors = [UIColor(hex: 0xFF9501).cgColor, UIColor(hex: 0xFFC702).cgColor]
                    layer.startPoint = CGPoint(x: 0.0, y: 0.5)
                    layer.endPoint = CGPoint(x: 1.0, y: 0.5)
                    layer.borderWidth = 0.0
                    contentView?.textColor = .ks_white
                }
            }
        }
        
        open override var isEnabled: Bool {
            didSet {
                guard isEnabled != oldValue else { return }
                if isEnabled {
                    let style = style
                    self.style = style
                } else {
                    let layer = self.layer as! CAGradientLayer
                    backgroundColor = .ks_lightGray
                    layer.colors = nil
                    layer.borderWidth = 0.0
                    contentView?.textColor = .ks_lightGray7
                }
            }
        }
        
        open override var isHighlighted: Bool {
            didSet {
                alpha = isHighlighted ? 0.5 : 1.0
            }
        }
        
        open override class var layerClass: AnyClass { CAGradientLayer.self }
        
        convenience public init(title: String, style: Style = .normal) {
            self.init(frame: .zero)
            self.contentView?.text = title
            defer { self.style = style }
        }
        
        class open var Cancel: Self {
            let button = self.init()
            button.contentView?.text = "取消"
            return button
        }
        
        class open var Ok: Self {
            let button = self.init()
            button.style = .highlight
            button.contentView?.text = "确认"
            return button
        }
        
    }
    
}
