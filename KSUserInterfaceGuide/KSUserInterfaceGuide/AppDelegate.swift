//
//  AppDelegate.swift
//  KSUserInterfaceGuide
//
//  Created by Kinsun on 2022/8/9.
//

import UIKit
import KSUserInterface

@main
open class AppDelegate: UIResponder, UIApplicationDelegate {

    open var window: UIWindow? = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .ks_white
        window.rootViewController = KSNavigationController(rootViewController: MainViewController())
        return window
    }()

    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 11.0, *) {
            let scrollView = UIScrollView.appearance(whenContainedInInstancesOf: [KSBaseView.self])
            scrollView.contentInsetAdjustmentBehavior = .never
            if #available(iOS 13.0, *) {
                scrollView.automaticallyAdjustsScrollIndicatorInsets = false
            }
        }
        
        let tableView = UITableView.appearance(whenContainedInInstancesOf: [KSBaseView.self])
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 0.0
        tableView.estimatedSectionHeaderHeight = 0.0
        tableView.estimatedSectionFooterHeight = 0.0
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0.0
        }
        
        let appearance = KSLoadingView.appearance()
        appearance.setImage(UIImage(named: "icon_loadingView_empty"), for: .emptyData)
        appearance.setImage(UIImage(named: "icon_loadingView_error"), for: .loadFailure)
        appearance.setImage(UIImage(named: "icon_loadingView_nonet"), for: .noNetwork)
        appearance.setTitle("暂无数据", for: .emptyData)
        appearance.setTitle("加载失败，点击重试", for: .loadFailure)
        appearance.setTitle("无法连接到网络", for: .noNetwork)
        
        window?.makeKeyAndVisible()
        return true
    }


}

