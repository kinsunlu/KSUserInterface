//
//  ButtonViewController.swift
//  KSUserInterfaceGuide
//
//  Created by Kinsun on 2022/8/9.
//

import UIKit
import KSUserInterface

open class ButtonViewController: KSSecondaryViewController<ButtonViewController.View> {
    
    open override func loadView() {
        let view = View()
        let selector = #selector(_didClick(button:))
        view.buttonItem.contentView.addTarget(self, action: selector, for: .touchUpInside)
        view.borderButtonItem.contentView.addTarget(self, action: selector, for: .touchUpInside)
        view.gradientButtonItem.contentView.addTarget(self, action: selector, for: .touchUpInside)
        view.imageButtonItem.contentView.addTarget(self, action: selector, for: .touchUpInside)
        view.navRightButton.addTarget(self, action: #selector(_didClick(navRightButton:)), for: .touchUpInside)
        self.view = view
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        title = "KSButton"
    }
    
    @objc private func _didClick(button: UIControl) {
        button.isSelected = !button.isSelected
    }
    
    @objc private func _didClick(navRightButton: KSTextButton) {
        let view = view
        let isEnabled = navRightButton.isSelected
        navRightButton.isSelected = !isEnabled
        view.buttonItem.contentView.isEnabled = isEnabled
        view.borderButtonItem.contentView.isEnabled = isEnabled
        view.gradientButtonItem.contentView.isEnabled = isEnabled
        view.imageButtonItem.contentView.isEnabled = isEnabled
        view.textButtonItem.contentView.isEnabled = isEnabled
        view.itemButtonItem.contentView.isEnabled = isEnabled
    }

}

extension ButtonViewController {
    
    open class View: ScrollSecondaryView {
        
        required public init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        fileprivate let buttonItem: WidgetItem<KSButton> = {
            let button = KSButton(type: .custom)
            button.isRoundedCorners = true
            button.titleLabel?.font = .boldSystemFont(ofSize: 14.0)
            button.setTitleColor(.ks_white, for: .normal)
            button.setTitle("失去响应", for: .disabled)
            button.setBackgroundColor(.ks_lightGray, for: .disabled)
            button.setTitle("正常状态", for: .normal)
            button.setBackgroundColor(.ks_main, for: .normal)
            button.setTitle("高亮状态", for: .highlighted)
            button.setBackgroundColor(.ks_lightMain, for: .highlighted)
            button.setTitle("选中状态", for: .selected)
            button.setBackgroundColor(.ks_red, for: .selected)
            button.setTitle("选中失去响应", for: [.disabled, .selected])
            button.setTitleColor(.ks_white, for: [.disabled, .selected])
            button.setBackgroundColor(.ks_lightGray, for: [.disabled, .selected])
            
            let item = WidgetItem<KSButton>(contentView: button)
            item.set(title: "KSButton", description: "继承自UIButton，为其增加了依据状态实时变更背景色的功能。")
            return item
        }()
        
        fileprivate let borderButtonItem: WidgetItem<KSBorderButton> = {
            let button = KSBorderButton(type: .custom)
            button.isRoundedCorners = true
            button.titleLabel?.font = .boldSystemFont(ofSize: 14.0)
            button.setTitle("失去响应", for: .disabled)
            button.setTitleColor(.ks_lightGray, for: .disabled)
            button.setBorderColor(.ks_lightGray, for: .disabled)
            button.setBackgroundColor(.clear, for: .disabled)
            button.setTitle("正常状态", for: .normal)
            button.setTitleColor(.ks_main, for: .normal)
            button.setBorderColor(.ks_main, for: .normal)
            button.setBackgroundColor(.clear, for: .normal)
            button.setTitle("高亮状态", for: .highlighted)
            button.setTitleColor(.ks_lightMain, for: .highlighted)
            button.setBorderColor(.ks_lightMain, for: .highlighted)
            button.setBackgroundColor(.clear, for: .highlighted)
            button.setTitle("选中状态", for: .selected)
            button.setTitleColor(.ks_red, for: .selected)
            button.setBorderColor(.ks_red, for: .selected)
            button.setBackgroundColor(.clear, for: .selected)
            button.setTitle("选中失去响应", for: [.disabled, .selected])
            button.setTitleColor(.ks_lightGray, for: [.disabled, .selected])
            button.setBorderColor(.ks_lightGray, for: [.disabled, .selected])
            button.setBackgroundColor(.clear, for: [.disabled, .selected])
            
            let item = WidgetItem<KSBorderButton>(contentView: button)
            item.set(title: "KSBorderButton", description: "继承自KSButton，为其增加了依据状态实时变更边框色的功能。")
            return item
        }()
        
        fileprivate let gradientButtonItem: WidgetItem<KSGradientButton> = {
            let button = KSGradientButton(type: .custom)
            button.isRoundedCorners = true
            button.titleLabel?.font = .boldSystemFont(ofSize: 14.0)
            button.setTitleColor(.ks_white, for: .normal)
            button.setTitle("失去响应", for: .disabled)
            button.setBackgroundColors([.ks_lightGray, .ks_white], for: .disabled)
            button.setTitle("正常状态", for: .normal)
            button.setBackgroundColors([.ks_main, .ks_white], for: .normal)
            button.setTitle("高亮状态", for: .highlighted)
            button.setBackgroundColors([.ks_lightMain, .ks_white], for: .highlighted)
            button.setTitle("选中状态", for: .selected)
            button.setBackgroundColors([.ks_red, .ks_white], for: .selected)
            button.setTitle("选中失去响应", for: [.disabled, .selected])
            button.setBackgroundColors([.ks_lightGray, .ks_white], for: [.disabled, .selected])
            
            let item = WidgetItem<KSGradientButton>(contentView: button)
            item.set(title: "KSGradientButton", description: "继承自UIButton，为其增加了依据状态实时变更渐变背景色的功能。")
            return item
        }()
        
        fileprivate let imageButtonItem: WidgetItem<KSImageButton> = {
            let button = KSImageButton()
            button.normalImage = #imageLiteral(resourceName: "icon_imageButton_n")
            button.selectedImage = #imageLiteral(resourceName: "icon_imageButton_h")
            
            let item = WidgetItem<KSImageButton>(contentView: button)
            item.contentSize = CGSize(width: 97.0, height: 50.0)
            item.set(title: "KSImageButton", description: "继承自KSBoxLayoutButton，简单的单图按钮。")
            return item
        }()
        
        fileprivate let textButtonItem: WidgetItem<KSTextButton> = {
            let button = KSTextButton()
            if let label = button.contentView {
                label.font = .boldSystemFont(ofSize: 14.0)
                label.textColor = .ks_black
                label.text = "KSTextButton"
            }
            
            let item = WidgetItem<KSTextButton>(contentView: button)
            item.set(title: "KSTextButton", description: "继承自KSBoxLayoutButton，简单的单标签按钮。")
            return item
        }()
        
        fileprivate let itemButtonItem: WidgetItem<KSItemButton> = {
            let button = KSItemButton()
            button.imageView?.image = #imageLiteral(resourceName: "icon_itemButton")
            button.titleLabel?.text = "联系客服"
            
            let item = WidgetItem<KSItemButton>(contentView: button)
            item.contentSize = CGSize(width: 72.0, height: 50.0)
            item.set(title: "KSItemButton", description: "继承自UIControl，简单的上图下文结构按钮。")
            return item
        }()
        
        public let navRightButton: KSTextButton = {
            let button = KSTextButton()
            if let label = button.contentView {
                label.font = .systemFont(ofSize: 11.0)
                label.textColor = .ks_lightGray7
                label.text = "disable状态切换"
            }
            button.contentInset = UIEdgeInsets(top: 15.5, left: 11.0, bottom: 15.5, right: 11.0)
            return button
        }()
        
        override init(frame: CGRect, navigationView: KSSecondaryNavigationView) {
            super.init(frame: frame, navigationView: navigationView)
            navigationView.addRightView(navRightButton)
            items = [buttonItem, borderButtonItem, gradientButtonItem, imageButtonItem, textButtonItem, itemButtonItem]
        }
        
    }
    
}
