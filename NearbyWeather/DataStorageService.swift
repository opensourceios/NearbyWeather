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
    
    static func storeFile<T: Encodable>(withFileNwame fileName: String, forObject object: T, toDirectory directory: Directory) {
        guard let url = getURL(forDirectory: directory)?.appendingPathComponent(fileName, isDirectory: false) else {
            print("💥 DataStorageService: Could not construct url for storing file \(fileName)")
            return
        }
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    static func retrieveFile<T: Decodable>(withFileName fileName: String, fromDirectory directory: Directory, asType type: T.Type) -> T? {
        guard let url = getURL(forDirectory: directory)?.appendingPathComponent(fileName, isDirectory: false) else {
            print("💥 DataStorageService: Could not construct url for retrieval of file \(fileName)")
            return nil
        }
        
        if !FileManager.default.fileExists(atPath: url.path) {
            print("💥 DataStorageService: File at path \(url.path) does not exist!")
            return nil
        }
        
        if let data = FileManager.default.contents(atPath: url.path) {
            let decoder = JSONDecoder()
            do {
                let model = try decoder.decode(type, from: data)
                return model
            } catch {
                fatalError(error.localizedDescription)
            }
        } else {
            print("💥 DataStorageService: No data at \(url.path)!")
            return nil
        }
    }
    
    
    // MARK: - Private Functions
    
    static fileprivate func getURL(forDirectory directory: Directory) -> URL? {
        var searchPathDirectory: FileManager.SearchPathDirectory
        
        switch directory {
        case .documents: searchPathDirectory = .documentDirectory
        case .caches: searchPathDirectory = .cachesDirectory
        }
        return FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first
    }
}
