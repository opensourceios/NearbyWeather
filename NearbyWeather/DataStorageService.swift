//
//  DataStorageService.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 08.01.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import Foundation

enum Directory {
    case documents
    case caches
}

class DataStorageService {    
    
    // MARK: -  Public Functions
    
    static func storeJson<T: Encodable>(forCodable codable: T, toFileWithName fileName: String) {
        guard let fileBaseURL = documentsDirectoryURL else { return }
        let fileExtension = "json"
        let filePathURL = fileBaseURL.appendingPathComponent(fileName).appendingPathExtension(fileExtension)
        
        do {
            let data = try JSONEncoder().encode(codable)
            try data.write(to: filePathURL)
        } catch let error {
            print("💥 DataStorageService: Error while writing data to \(filePathURL.path). Error-Description: \(error.localizedDescription)")
        }
    }
    
    static func retrieveJson<T: Decodable>(fromFileWithName fileName: String, andDecodeAsType type: T.Type) -> T? {
        guard let fileBaseURL = documentsDirectoryURL else { return nil }
        let fileExtension = "json"
        let filePathURL = fileBaseURL.appendingPathComponent(fileName).appendingPathExtension(fileExtension)
        
        
        if !FileManager.default.fileExists(atPath: filePathURL.path) {
            print("💥 DataStorageService: File at path \(filePathURL.path) does not exist!")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: filePathURL)
            let model = try JSONDecoder().decode(type, from: data)
            return model
        } catch let error {
            print("💥 DataStorageService: Error while retrieving data from \(filePathURL.path). Error-Description: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    // MARK: - Private Functions
    
    static private var documentsDirectoryURL: URL? {
        guard let fileBaseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            // nil checking for error reporting
            print("💥 DataStorageService: Could not construct documents directory url.")
            return nil
        }
        return fileBaseURL
    }
}
