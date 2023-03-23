//
//  DialogViewController.swift
//  KSUserInterfaceGuide
//
//  Created by Kinsun on 2022/8/11.
//

import UIKit
import KSUserInterface

open class DialogViewController: KSSecondaryViewController<ScrollSecondaryView> {
    
    private lazy var _topView: WidgetItem<KSDialogView> = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17.0)
        label.textColor = .ks_white
        label.numberOfLines = 0
        label.text = "我是测试文案，箭头在上面的测试文案"
        
        let view = KSDialogView(direction: .top)
        view.backgroundColor = UIColor(hex: 0x02E77F)
        view.contentInset = UIEdgeInsets(top: 7.0, left: 7.0, bottom: 7.0, right: 7.0)
        view.contentView = label
        
        let item = WidgetItem<KSDialogView>(contentView: view)
        item.contentSize = view.sizeThatFits(CGSize(width: 200.0, height: .greatestFiniteMagnitude))
        item.set(title: "KSDialogViewIndicatorDirection.top", description: "可在气泡内添加任意视图")
        return item
    }()
    
    private lazy var _bottomView: WidgetItem<KSDialogView> = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "icon_itemButton"))
        imageView.contentMode = .center
        
        let view = KSDialogView(direction: .bottom)
        view.backgroundColor = UIColor(hex: 0x02E77F)
        view.contentInset = UIEdgeInsets(top: 7.0, left: 7.0, bottom: 7.0, right: 7.0)
        view.contentView = imageView
        
        let item = WidgetItem<KSDialogView>(contentView: view)
        item.contentSize = view.sizeThatFits(CGSize(width: 200.0, height: .greatestFiniteMagnitude))
        item.set(title: "KSDialogViewIndicatorDirection.bottom", description: "可在气泡内添加任意视图")
        return item
    }()
    
    private lazy var _leftView: WidgetItem<KSDialogView> = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11.0)
        label.textColor = .ks_white
        label.numberOfLines = 0
        label.text = "我是测试文案，箭头在左面的测试文案，再多加一点字吧，再多加一点字吧。"
        
        let view = KSDialogView(direction: .left)
        view.backgroundColor = UIColor(hex: 0x02E77F)
        view.contentInset = UIEdgeInsets(top: 7.0, left: 7.0, bottom: 7.0, right: 7.0)
        view.contentView = label
        
        let item = WidgetItem<KSDialogView>(contentView: view)
        item.contentSize = view.sizeThatFits(CGSize(width: 200.0, height: .greatestFiniteMagnitude))
        item.set(title: "KSDialogViewIndicatorDirection.left", description: "可在气泡内添加任意视图")
        return item
    }()
    
    private lazy var _rightView: WidgetItem<KSDialogView> = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "icon_loadingView_empty"))
        imageView.contentMode = .center
        
        let view = KSDialogView(direction: .right)
        view.backgroundColor = UIColor(hex: 0x02E77F)
        view.contentInset = UIEdgeInsets(top: 7.0, left: 7.0, bottom: 7.0, right: 7.0)
        view.contentView = imageView
        
        let item = WidgetItem<KSDialogView>(contentView: view)
        item.contentSize = view.sizeThatFits(CGSize(width: 200.0, height: .greatestFiniteMagnitude))
        item.set(title: "KSDialogViewIndicatorDirection.right", description: "可在气泡内添加任意视图")
        return item
    }()
    
    open override func loadView() {
        let view = ScrollSecondaryView()
        view.items = [_topView, _bottomView, _leftView, _rightView]
        self.view = view
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        title = "KSDialogView"
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let scrollView = view.scrollView
        let windowSize = scrollView.bounds.size
        _topView.frame = CGRect(origin: CGPoint(x: 0.0, y: 11.0), size: _topView.sizeThatFits(windowSize))
        _bottomView.frame = CGRect(origin: CGPoint(x: 0.0, y: _topView.frame.maxY+11.0), size: _bottomView.sizeThatFits(windowSize))
        _leftView.frame = CGRect(origin: CGPoint(x: 0.0, y: _bottomView.frame.maxY+11.0), size: _leftView.sizeThatFits(windowSize))
        _rightView.frame = CGRect(origin: CGPoint(x: 0.0, y: _leftView.frame.maxY+11.0), size: _rightView.sizeThatFits(windowSize))
        scrollView.contentSize = CGSize(width: 0.0, height: _rightView.frame.maxY+11.0)
    }

}
