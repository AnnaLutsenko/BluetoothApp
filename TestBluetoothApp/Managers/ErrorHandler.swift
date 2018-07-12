//
//  ErrorHandler.swift
//  TestBluetoothApp
//
//  Created by Anna on 12.07.2018.
//  Copyright © 2018 Anna Lutsenko. All rights reserved.
//

import Foundation


enum RequestError: Error {
    case wrongData
    case unknownError
    
    var localizedDescription: String {
        switch self {
        case .wrongData:
            return "Server returned wrong data. Try later please"
        default:
            return "Ops! Something went wrong. Could you try later."
        }
    }
}
