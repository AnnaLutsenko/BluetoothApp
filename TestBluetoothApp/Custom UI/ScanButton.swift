//
//  ScanButton.swift
//  TestBluetoothApp
//
//  Created by Anna on 19.06.2018.
//  Copyright © 2018 Anna Lutsenko. All rights reserved.
//

import UIKit

class ScanButton: UIButton {


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        style(with: .clear)
    }
    
    func style(with color: UIColor) {
        layer.borderWidth = 1.5
        layer.borderColor = color.cgColor
        layer.cornerRadius = 3
    }

    func setupDisabledState() {
        setTitleColor(.lightGray, for: .disabled)
    }
    
    func update(isScanning: Bool){
        let title = isScanning ? "Stop Scanning" : "Start Scanning"
        setTitle(title, for: UIControlState())
        
        let titleColor: UIColor = isScanning ? .btBlue : .white
        setTitleColor(titleColor, for: UIControlState())
        
        backgroundColor = isScanning ? UIColor.clear : .btBlue
    }
}
