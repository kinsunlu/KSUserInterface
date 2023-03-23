//
//  ScrollSecondaryView.swift
//  KSUserInterfaceGuide
//
//  Created by Kinsun on 2022/8/12.
//

import UIKit
import KSUserInterface

open class ScrollSecondaryView: KSSecondaryView {
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .ks_background
        return scrollView
    }()
    
    public override init(frame: CGRect, navigationView: KSSecondaryNavigationView) {
        super.init(frame: frame, navigationView: navigationView)
        addSubview(scrollView)
    }
    
    open var items: [UIView]? {
        didSet {
            guard items != oldValue else { return }
            oldValue?.forEach { $0.removeFromSuperview() }
            items?.forEach { scrollView.addSubview($0) }
            setNeedsLayout()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = bounds
        scrollView.frame = bounds
        let inset = UIEdgeInsets(top: navigationView?.frame.maxY ?? 0.0, left: 0.0, bottom: safeAreaInsets.bottom, right: 0.0)
        scrollView.contentInset = inset
        scrollView.scrollIndicatorInsets = inset
        
        guard let items = items, !items.isEmpty else { return }
        let windowSize = bounds.size
        var lastY = CGFloat(11.0)
        for item in items {
            let frame = CGRect(origin: CGPoint(x: 0.0, y: lastY), size: item.sizeThatFits(windowSize))
            item.frame = frame
            lastY = frame.maxY+11.0
        }
        scrollView.contentSize = CGSize(width: 0.0, height: lastY)
    }
    
}
