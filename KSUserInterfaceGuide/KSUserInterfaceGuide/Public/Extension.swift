//
//  Extension.swift
//  KSUserInterfaceGuide
//
//  Created by Kinsun on 2022/8/17.
//

import UIKit

public extension UIResponder {
    
    /// 查找响应链中的指定类型响应者
    /// eg. 想要查找view所在的控制器 let controller: UIViewController = view.find()
    /// 建议使用后缓存得到的值，频繁使用会增加性能损耗
    /// - Returns: 响应者
    func find<T: UIResponder>() -> T? {
        var next = next
        while let n = next {
            if let next = n as? T {
                return next
            } else { next = n.next }
        }
        return nil
    }
    
}
