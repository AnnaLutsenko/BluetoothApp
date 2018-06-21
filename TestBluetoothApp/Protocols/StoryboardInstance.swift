//
//  StoryboardInstance.swift
//  TestBluetoothApp
//
//  Created by Anna on 20.06.2018.
//  Copyright © 2018 Anna Lutsenko. All rights reserved.
//

import UIKit
import Foundation

extension UIStoryboard {
    static var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: .main)
    }
}

protocol StoryboardInstance {
    static func storyboardInstance(from storyboard: UIStoryboard, controllerID: String) -> Self?
}

extension StoryboardInstance where Self: UIViewController {
    static var defaultControllerID: String {
        return String(describing: self)
    }
    
    static func storyboardInstance(from storyboard: UIStoryboard = .main, controllerID: String = defaultControllerID) -> Self? {
        let vc = storyboard.instantiateViewController(withIdentifier: controllerID)
        return vc as? Self
    }
}

