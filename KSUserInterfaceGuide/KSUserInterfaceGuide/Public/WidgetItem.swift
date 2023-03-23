//
//  WidgetItem.swift
//  KSUserInterfaceGuide
//
//  Created by Kinsun on 2022/8/11.
//

import UIKit

open class WidgetItem<V: UIView>: UIView {
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let _lable: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    public let contentView: V
    
    public init(frame: CGRect = .zero, contentView: V) {
        self.contentView = contentView
        super.init(frame: frame)
        backgroundColor = .ks_white
        addSubview(_lable)
        addSubview(contentView)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let windowSize = bounds.size
        let windowWidth = windowSize.width
        let windowHeight = windowSize.height
        let margin = CGFloat(11.0)
        contentView.frame = CGRect(origin: CGPoint(x: (windowWidth-contentSize.width)*0.5, y: windowHeight-contentSize.height-margin), size: contentSize)
        _lable.frame = CGRect(x: margin, y: margin, width: windowWidth-margin*2.0, height: contentView.frame.minY-margin*2.0)
    }
    
    open var contentSize = CGSize(width: 300.0, height: 44.0) {
        didSet {
            guard contentSize != oldValue else { return }
            setNeedsLayout()
        }
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        let windowWidth = size.width
        let margin = CGFloat(11.0)
        return CGSize(width: windowWidth, height: _lable.sizeThatFits(CGSize(width: windowWidth-margin*2.0, height: size.height)).height+margin*3.0+contentSize.height)
    }
    
    open func set(title: String, description: String? = nil) {
        let string = NSMutableAttributedString(string: title, attributes: [.foregroundColor: UIColor.ks_black, .font: UIFont.boldSystemFont(ofSize: 16.0)])
        if let description = description, !description.isEmpty {
            string.append(NSAttributedString(string: " "+description, attributes: [.foregroundColor: UIColor.ks_lightGray7, .font: UIFont.systemFont(ofSize: 14.0)]))
        }
        _lable.attributedText = string
    }
    
}
