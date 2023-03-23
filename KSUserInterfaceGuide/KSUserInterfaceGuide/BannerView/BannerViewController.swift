//
//  BannerViewController.swift
//  KSUserInterfaceGuide
//
//  Created by Kinsun on 2022/8/9.
//

import UIKit
import KSUserInterface

open class BannerViewController: KSSecondaryViewControllerDefault, KSBannerViewDelegate {
    
    private lazy var _banner: KSBannerView = {
        let banner = KSBannerView()
        banner.isAutoScroll = true
        banner.itemMargin = 44.0
        banner.delegate = self
        return banner
    }()

    open override func loadView() {
        super.loadView()
        let view = self.view
        view.backgroundColor = .ks_white
        view.addSubview(_banner)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        title = "KSBannerView"
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = view.bounds.size.width
        let top = view.navigationView?.frame.maxY ?? 0.0
        _banner.frame = CGRect(x: 0.0, y: top+22.0, width: width, height: ceil(width*0.5625))
    }
    
    open func number(in bannerView: KSBannerView) -> Int {
        10
    }
    
    open func item(in bannerView: KSBannerView) -> UIView {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 120.0)
        label.textAlignment = .center
        label.textColor = .ks_lightRed
        label.backgroundColor = .ks_background
        let layer = label.layer
        layer.cornerRadius = 10.0
        layer.masksToBounds = true
        return label
    }
    
    open func bannerView(_ bannerView: KSBannerView, configurationItem item: UIView, at index: Int) {
        (item as? UILabel)?.text = String(index)
    }
    
    public func bannerView(_ bannerView: KSBannerView, didClikeItemAt index: Int) {
        KSToastShowMessage("你点击了第\(index)个Item")
    }
    
    public func bannerView(_ bannerView: KSBannerView, didChangeCurrentItemAt index: Int) {
        KSToastShowMessage("滚动到了第\(index)个Item")
    }

}
