//
//  ThemeExtension.swift
//  Helping Hands
//
//  Created by Manasa Tipparam on 4/2/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import Foundation

public protocol Theme {
    
    var backgroundColor: UIColor { get }
    var tintColor: UIColor { get }
    var navigationBarTintColor: UIColor? { get }
    var navigationBarTranslucent: Bool { get }
    
    var navigationTitleFont: UIFont { get }
    var navigationTitleColor: UIColor { get }
    
    var tableViewBackgroundColor: UIColor { get }
    
    var headlineFont: UIFont { get }
    var headlineColor: UIColor { get }
    
    var bodyTextFont: UIFont { get }
    var bodyTextColor: UIColor { get }
    
    // ...
    
}

extension Theme {
    
    public var backgroundColor: UIColor { return UIColor.white }
    public var tintColor: UIColor { return UIColor(hex: "#1B212C") }
    public var navigationBarTintColor: UIColor? { return UIColor.white }
    public var navigationBarTranslucent: Bool { return true }
    
    public var navigationTitleFont: UIFont { return UIFont(name: "Gidole-Regular", size: 17)! }
    public var navigationTitleColor: UIColor { return UIColor(hex: "#1B212C") }
    
    public var tableViewBackgroundColor: UIColor { return UIColor.white }
    
    public var headlineFont: UIFont { return UIFont(name: "Gidole-Regular", size: 19)! }
    public var headlineColor: UIColor { return UIColor(hex: "#1B212C") }
    
    public var bodyTextFont: UIFont { return UIFont(name: "Gidole-Regular", size: 17)! }
    public var bodyTextColor: UIColor { return UIColor(hex: "#1B212C") }
    
    public func applyBackgroundColor(views: [UIView]) {
        views.forEach {
            $0.backgroundColor = backgroundColor
        }
    }
    
    public func applyNavBarTintColor(navBar: UINavigationController) {
        navBar.navigationBar.barTintColor = navigationBarTintColor
    }
    
    public func applyTintColor_Font(navBar: UINavigationController) {
        navBar.navigationBar.tintColor = tintColor
        navBar.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: navigationTitleColor, NSAttributedStringKey.font: UIFont(name: "Gidole-Regular", size: 23)!]
    }
    
    public func applyHeadlineStyle(labels: [UILabel]) {
        labels.forEach {
            $0.font = headlineFont
            $0.textColor = headlineColor
        }
    }
    
    public func applyBodyTextStyle(labels: [UILabel]) {
        labels.forEach {
            $0.font = bodyTextFont
            $0.textColor = bodyTextColor
        }
    }
    
    public func applyButtonTextStyle(buttons: [UIButton]) {
        buttons.forEach {
            $0.titleLabel?.font = bodyTextFont
            $0.setTitleColor(bodyTextColor, for: .normal) 

        }
    }
    
    public func applyTableViewBackgroundColor(tableView: UITableView) {
        tableView.backgroundColor = tableViewBackgroundColor
    }
    
}

public struct DefaultTheme: Theme {
    
    public var backgroundColor: UIColor = UIColor.white
    public var tintColor: UIColor = UIColor(hex: "#1B212C")
    public var navigationBarTintColor: UIColor? = UIColor.white
    public var navigationBarTranslucent: Bool = false
    
    public var tableViewBackgroundColor: UIColor = UIColor.white
    
    public var navigationTitleColor: UIColor = UIColor(hex: "#1B212C")
    public var headlineColor: UIColor { return UIColor(hex: "#1B212C") }
    public var bodyTextColor: UIColor { return UIColor(hex: "#1B212C") }
    public var bodyTextFont: UIFont { return UIFont(name: "Gidole-Regular", size: 17)! }
    
    public init() {}
    
}

public struct DarkTheme: Theme {
    
    public var backgroundColor: UIColor = UIColor(hex: "#1B212C")
    public var tintColor: UIColor = UIColor.white
    public var navigationBarTintColor: UIColor? = UIColor(hex: "#1B212C")
    public var navigationBarTranslucent: Bool = false
    
    public var tableViewBackgroundColor: UIColor = UIColor(hex: "#1B212C")
    
    public var navigationTitleColor: UIColor = UIColor.white
    public var headlineColor: UIColor { return UIColor.white }
    public var bodyTextColor: UIColor { return UIColor.white }
    public var bodyTextFont: UIFont { return UIFont(name: "Gidole-Regular", size: 17)! }
    
    public init() {}
    
}
