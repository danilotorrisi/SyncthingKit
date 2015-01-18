//
//  Syncthing.swift
//  Syncthing-Finder
//
//  Created by Danilo Torrisi on 18/01/15.
//  Copyright (c) 2015 Danilo Torrisi. All rights reserved.
//

import Foundation
import Alamofire
import BrightFutures
import SwiftyJSON

public struct Syncthing {
    
    /**
    The address used to establish a connection with the Syncthing REST API. Default: localhost.
    */
    static public var address: String = "localhost"
    
    /**
    The port used to establish a connection with the Syncthing REST API. Default: 8080.
    */
    static public var port: UInt16 = 8080
    
    /**
    Returns a future JSON object obtained by a GET request to the Syncthing API on the given action passing the given data.
    */
    public static func get(action: String, parameters: [String: NSObject] = [:]) -> Future<JSON> {
        let promise = Promise<JSON>()
        
        // Send a GET request.
        request(.GET, "http://\(address):\(port)/rest/\(action)", parameters: parameters).responseSwiftyJSON { (_, _, res, error) in

            // Return the promise success or failure.
            if let anError = error { promise.failure(anError) }
            else { promise.success(res) }
        }
        
        return promise.future
    }
}