//
//  CommandProtocol.swift
//  TestBluetoothApp
//
//  Created by Anna on 14.07.2018.
//  Copyright © 2018 Anna Lutsenko. All rights reserved.
//

import Foundation

protocol CommandResponse {
    init(from data: Data)
    func parseData(_ data: Data)
}

protocol CommandProtocol {
    var u16Command: CommandsU16 { get }
    var data: Data { get }
}

extension CommandResponse {
    
    func parseData(_ data: Data) {
        print("\(self) in HEX: \(data.convertToHEX())")
    }
}
