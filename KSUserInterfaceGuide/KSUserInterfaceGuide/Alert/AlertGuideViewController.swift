//
//  AlertGuideViewController.swift
//  KSUserInterfaceGuide
//
//  Created by Kinsun on 2022/8/12.
//

import UIKit
import KSUserInterface

open class AlertGuideViewController: KSSecondaryViewController<ScrollSecondaryView> {
    
    private lazy var _systemAlertItem: WidgetItem<KSTextButton> = {
        let item = Self.TextButtonItem(text: "点击展示样式", title: "SystemAlertViewController", description: "继承自KSAlertViewController，一个自定义系统类型的Alert。")
        item.contentView.add(.touchUpInside) { [weak self] _ in
            let alert = SystemAlertViewController(title: "SystemAlertViewController", message: "内容内容内容内容内容内容内容内容")
            alert.add(button: .Ok)
            self?.present(alert, animated: true)
        }
        return item
    }()
    
    private lazy var _systemAlertPushItem: WidgetItem<KSTextButton> = {
        let item = Self.TextButtonItem(text: "点击展示样式", title: "SystemAlertViewController", description: "继承自KSAlertViewController，一个自定义系统类型的Alert，点击确认即可push出一个新的测试页面。")
        item.contentView.add(.touchUpInside) { [weak self] _ in
            let alert = SystemAlertViewController(title: "SystemAlertViewController", message: "点击确认即可push出一个新的测试页面")
            alert.didClickButtonCallback = {
                if $1.style == .highlight {
                    let ctl = KSSecondaryViewController()
                    ctl.title = "测试标题"
                    $0.push(ctl)
                } else {
                    $0.close()
                }
            }
            alert.add(button: .Cancel)
            alert.add(button: .Ok)
            self?.present(KSTransparentNavigationController(rootViewController: alert), animated: true)
        }
        return item
    }()
    
    private lazy var _customAlertItem: WidgetItem<KSTextButton> = {
        let item = Self.TextButtonItem(text: "点击展示样式", title: "KSAlertViewController", description: "无需继承直接使用KSAlertViewController展示一个自定义的AlertView。")
        item.contentView.add(.touchUpInside) { [weak self] _ in
            let alert = KSAlertViewController()
            alert.isClickBackgroundCloseEnable = true;
            let contentView = KSImageButton()
            contentView.backgroundColor = .ks_white
            contentView.normalImage = #imageLiteral(resourceName: "icon_loadingView_nonet")
            contentView.contentInset = UIEdgeInsets(top: 24.0, left: 12.0, bottom: 24.0, right: 12.0)
            contentView.add(.touchUpInside) { _ in
                KSToastShowMessage("你点击了KSImageButton")
            }
            alert.alertView = contentView
            
            let animation = CABasicAnimation(keyPath: "transform.rotation.x")
            animation.duration = 0.3
            animation.fromValue = Double.pi*0.5
            animation.toValue = 0.0
            animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
            alert.showAnimation = animation;
            
            animation.fromValue = 0.0
            animation.toValue = Double.pi*0.5
            alert.hiddenAnimation = animation;
            
            self?.present(alert, animated: true)
        }
        return item
    }()
    
    private lazy var _inputAlertItem: WidgetItem<KSTextButton> = {
        let item = Self.TextButtonItem(text: "点击展示样式", title: "KSAlertViewController", description: "测试键盘跟随，直接使用KSAlertViewController展示一个自定义的AlertView。")
        item.contentView.add(.touchUpInside) { [weak self] _ in
            let titleLabel = UILabel()
            titleLabel.font = .boldSystemFont(ofSize: 16.0)
            titleLabel.textAlignment = .center
            titleLabel.text = "测试键盘弹起效果"
            
            let textFiled = UITextField(frame: CGRect(origin: .zero, size: CGSize(width: 280.0, height: 64.0)))
            textFiled.font = .systemFont(ofSize: 16.0)
            textFiled.placeholder = "输入测试文字"
            textFiled.returnKeyType = .done
            textFiled.clearButtonMode = .whileEditing
            textFiled.textColor = .ks_black
            textFiled.borderStyle = .roundedRect
            textFiled.backgroundColor = .ks_white
            
            let textFiled2 = UITextField(frame: CGRect(origin: .zero, size: CGSize(width: 280.0, height: 64.0)))
            textFiled2.font = .systemFont(ofSize: 16.0)
            textFiled2.placeholder = "输入测试文字2"
            textFiled2.returnKeyType = .done
            textFiled2.clearButtonMode = .whileEditing
            textFiled2.textColor = .ks_black
            textFiled2.borderStyle = .roundedRect
            textFiled2.backgroundColor = .ks_white
            
            let view = KSStackView(subviews: [titleLabel, textFiled, textFiled2])
            view.backgroundColor = .ks_white
            view.axis = .vertical
            view.stackLayout = .center
            view.subviewLayout = .bothEnds
            view.spacing = 12.0
            view.contentInset = UIEdgeInsets(top: 24.0, left: 24.0, bottom: 24.0, right: 24.0)
            view.frame = CGRect(origin: .zero, size: CGSize(width: 330.0, height: view.sizeThatFits(.zero).height))
            
            let alert = KSAlertViewController()
            alert.isFollowKeyboard = true
            alert.isClickBackgroundCloseEnable = true
            alert.alertView = KSStrutView(contentView: view)
            self?.present(alert, animated: true)
        }
        return item
    }()
    
    private lazy var _inputActionSheetItem: WidgetItem<KSTextButton> = {
        let item = Self.TextButtonItem(text: "点击展示样式", title: "KSActionSheetViewController", description: "测试键盘跟随，直接使用KSActionSheetViewController展示一个自定义的ActionSheetView。")
        item.contentView.add(.touchUpInside) { [weak self] _ in
            let titleLabel = UILabel()
            titleLabel.font = .boldSystemFont(ofSize: 16.0)
            titleLabel.textAlignment = .center
            titleLabel.text = "测试键盘弹起效果"
            
            let textFiled = UITextField(frame: CGRect(origin: .zero, size: CGSize(width: 280.0, height: 64.0)))
            textFiled.font = .systemFont(ofSize: 16.0)
            textFiled.placeholder = "输入测试文字"
            textFiled.returnKeyType = .done
            textFiled.clearButtonMode = .whileEditing
            textFiled.textColor = .ks_black
            textFiled.borderStyle = .roundedRect
            textFiled.backgroundColor = .ks_white
            
            let textFiled2 = UITextField(frame: CGRect(origin: .zero, size: CGSize(width: 280.0, height: 64.0)))
            textFiled2.font = .systemFont(ofSize: 16.0)
            textFiled2.placeholder = "输入测试文字2"
            textFiled2.returnKeyType = .done
            textFiled2.clearButtonMode = .whileEditing
            textFiled2.textColor = .ks_black
            textFiled2.borderStyle = .roundedRect
            textFiled2.backgroundColor = .ks_white
            
            let view = KSStackView(subviews: [titleLabel, textFiled, textFiled2])
            view.backgroundColor = .ks_white
            view.axis = .vertical
            view.stackLayout = .center
            view.subviewLayout = .bothEnds
            view.spacing = 12.0
            view.contentInset = UIEdgeInsets(top: 24.0, left: 24.0, bottom: 24.0, right: 24.0)
            view.frame = CGRect(origin: .zero, size: CGSize(width: self?.view.bounds.size.width ?? 330.0, height: view.sizeThatFits(.zero).height))
            
            let actionSheet = KSActionSheetViewController()
            actionSheet.isFollowKeyboard = true
            actionSheet.isClickBackgroundCloseEnable = true
            actionSheet.actionSheetView = KSStrutView(contentView: view)
            self?.present(actionSheet, animated: true)
        }
        return item
    }()

    private lazy var _systemActionSheetItem: WidgetItem<KSTextButton> = {
        let item = Self.TextButtonItem(text: "点击展示样式", title: "ShareActionSheetViewController", description: "继承自KSActionSheetViewController，一个分享样式的ActionSheet。点击item还可展示在actionSheet上push出新的页面")
        item.contentView.add(.touchUpInside) { [weak self] _ in
            self?.present(KSTransparentNavigationController(rootViewController: ShareActionSheetViewController()), animated: true)
        }
        return item
    }()
    
    open override func loadView() {
        let view = ScrollSecondaryView()
        view.items = [_systemAlertItem, _systemAlertPushItem, _customAlertItem, _inputAlertItem, _inputActionSheetItem, _systemActionSheetItem]
        self.view = view
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        title = "KSAlertGuide"
    }

}

extension AlertGuideViewController {
    
    static private func TextButtonItem(text: String, title: String, description: String? = nil) -> WidgetItem<KSTextButton> {
        let button = KSTextButton()
        if let label = button.contentView {
            label.font = .boldSystemFont(ofSize: 14.0)
            label.textColor = UIColor(hex: 0x0000FF)
            label.text = text
        }
        let item = WidgetItem<KSTextButton>(contentView: button)
        item.set(title: title, description: description)
        return item
    }
    
}
