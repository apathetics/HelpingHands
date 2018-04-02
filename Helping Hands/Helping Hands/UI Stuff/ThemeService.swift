//
//  ThemeService.swift
//  Helping Hands
//
//  Created by Manasa Tipparam on 4/2/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import Foundation

public protocol Themeable: class {
    func applyTheme(theme: Theme)
}

public class ThemeService {
    
    static let shared = ThemeService()
    public var theme: Theme = DefaultTheme() {
        didSet {
            applyTheme()
        }
    }
    
    private var listeners = NSHashTable<AnyObject>.weakObjects()
    
    public init() {}
    
    public func addThemeable(themable: Themeable, applyImmediately: Bool = true) {
        guard !listeners.contains(themable) else { return }
        listeners.add(themable)
        
        if applyImmediately {
            themable.applyTheme(theme: theme)
        }
    }
    
    private func applyTheme() {
        // Update styles via UIAppearance
        UINavigationBar.appearance().isTranslucent = theme.navigationBarTranslucent
        UINavigationBar.appearance().barTintColor = theme.navigationBarTintColor
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: theme.navigationTitleColor,
            NSAttributedStringKey.font: theme.navigationTitleFont
        ]
        
        // The tintColor will trickle down to each view
        if let window = UIApplication.shared.windows.first {
            window.tintColor = theme.tintColor
        }
        
        // Update each listener. The type cast is needed because allObjects returns [AnyObject]
        listeners.allObjects
            .flatMap { $0 as? Themeable }
            .forEach { $0.applyTheme(theme: theme) }
    }
    
}
