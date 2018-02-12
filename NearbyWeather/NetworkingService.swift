//
//  NetworkingService.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 10.02.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import Foundation
import Alamofire

enum ReachabilityStatus {
    case unknown
    case disconnected
    case connected
}

class NetworkingService {
    
    // MARK: - Public Assets
    
    public static var shared: NetworkingService!
    
    
    // MARK: - Properties
    
    private let reachabilityManager: NetworkReachabilityManager?
    private var reachabilityStatus: ReachabilityStatus
    
    // MARK: - Initialization
    
    private init() {
        self.reachabilityManager = NetworkReachabilityManager()
        self.reachabilityStatus = .unknown
        
        beginListeningNetworkReachability()
    }
    
    deinit {
        reachabilityManager?.stopListening()
    }
    
    // MARK: - Private Methods
    
    func beginListeningNetworkReachability() {
        reachabilityManager?.listener = { status in
            switch status {
            case .unknown: self.reachabilityStatus = .unknown
            case .notReachable: self.reachabilityStatus = .disconnected
            case .reachable(.ethernetOrWiFi), .reachable(.wwan): self.reachabilityStatus = .connected
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: kNetworkReachabilityChanged), object: self)
        }
        reachabilityManager?.startListening()
    }
    
    
    // MARK: - Public Methods
    
    public static func instantiateSharedInstance() {
        shared = NetworkingService()
    }
}
