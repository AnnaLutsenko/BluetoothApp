//
//  FirmwareManager.swift
//  TestBluetoothApp
//
//  Created by Anna on 12.07.2018.
//  Copyright © 2018 Anna Lutsenko. All rights reserved.
//

import Foundation

class FirmwareManager {
    //
    typealias Success = (Data) -> Void
    typealias Failure = (Error) -> Void
    //
    let fileMNG = FileManager.default
    //
    private let fileURL = "http://4k.com.ua/thor/program-v27.bin"
    private var destinationFilePath: URL?
    
    
    func getFirmware(success: @escaping Success, failure: @escaping Failure) {
        
        // Create destination URL (documentsUrl)
        // Create URL to the source file you want to download (fileURL)
        guard let documentsUrl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?,
            let fileURL = URL(string: fileURL) else { return }
        let destinationFileUrl = documentsUrl.appendingPathComponent(fileURL.lastPathComponent)
        destinationFilePath = destinationFileUrl
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let request = URLRequest(url:fileURL)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Fireware successfully downloaded. Status code: \(statusCode)")
                }
                
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: tempLocalUrl.path), options: .dataReadingMapped)
                    print("Successfully get data: \(data); \(data.count)")
                    success(data)
                } catch let error {
                    failure(error)
                }
                
            }
            else if let err = error {
                failure(err)
                print("Error took place while downloading a file. Error description: %@", err.localizedDescription)
            }
        }
        task.resume()
    }
    
}
