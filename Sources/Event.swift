//
//  Event.swift
//  Syncthing-Finder
//
//  Created by Danilo Torrisi on 16/01/15.
//  Copyright (c) 2015 Danilo Torrisi. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import BrightFutures

public struct Event: Printable {
    
    /**
    Based on the Event Interface wiki on github
    https://github.com/syncthing/syncthing/wiki/Event-Interface
    */
    public enum Type : Printable
    {
        /**
        Emitted exactly once, when syncthing starts, before parsing configuration etc
        */
        case Starting(home: String)
        /**
        Emitted exactly once, when initialization is complete and syncthing is ready to start exchanging data with other devices.
        */
        case StartupComplete
        /**
        The Ping event is generated automatically every five minutes. This means that even in the absence of any other activity, the event polling HTTP request will return within five minutes.
        */
        case Ping
        /**
        Emitted when a new device is discovered using local discovery.
        */
        case DeviceDiscovered(addrs: [String], device: String)
        /**
        Generated each time a connection to a device has been established.
        */
        case DeviceConnected(addr: String, identifier: String)
        /**
        Generated each time a connection to a device has been terminated.
        */
        case DeviceDisconnected(error: String, identifier: String)
        
        /**
        Generated each time new index information is received from a device.
        */
        case RemoteIndexUpdated(device: String, folder: String, items: Int)
        
        /**
        Generated when the local index information has changed, due to synchronizing an item from the cluster.
        */
        case LocalIndexUpdated(flags: String, modified: String, name: String, folder: String, size: Int)
        
        /**
        Generated when syncthing begins synchronizing a file to a newer version.
        */
        case ItemStarted(item: String, folder: String)
        
        /**
        Emitted when a folder changes state. Possible states are idle, scanning, cleaning and syncing. The field duration is the number of seconds the folder spent in state from. In the example below, the folder default was in state scanning for 0.198 seconds and is now in state idle.
        */
        case StateChanged(folder: String, from: String, duration: Double, to: String)
        
        /**
        Emitted when a device sends index information for a folder we do not have, or have but do not share with the device in question.
        */
        case FolderRejected(device: String, folder: String)
        
        /**
        Emitted when there is a connection from a device we are not configured to talk to.
        */
        case DeviceRejected(address: String, device: String)
        
        /**
        Emitted after the config has been saved by the user or by Syncthing itself.
        */
        case ConfigSaved(version: String)
        
        /**
        Emitted during file downloads for each folder for each file. By default only a single file in a folder is handled at the same time, but custom configuration can cause multiple files to be shown.
        */
        case DownloadProgress
        
        // Private initializer to build a Type from its json representation. Because the type and its data are on the event top level json object you have to pass the event representation.
        init?(json: JSON) {
            
            // If type string found
            if let type = json["type"].string {
                
                // Get the data.
                let data = json["data"]
                
                // Check the type
                switch type {
                    
                // On starting, we have to fetch the home string on the data json object.
                case "Starting": self = Type.Starting(home: data["home"].stringValue)
                
                // On startup complete, no data to be fetched at all.
                case "StartupComplete": self = Type.StartupComplete
                    
                // On ping, no data to be fetched at all.
                case "Ping": self = Type.Ping
                    
                // On device discovered, fetch addrs and device.
                case "DeviceDiscovered": self = Type.DeviceDiscovered(addrs: data["addres"].arrayObject as? [String] ?? [], device: data["device"].stringValue)
                    
                // On device connected, fetch addrs and device.
                case "DeviceConnected": self = Type.DeviceConnected(addr: data["addr"].stringValue, identifier: data["id"].stringValue)

                // On device disconnected, fetch error and id.
                case "DeviceDisconnected": self = Type.DeviceDisconnected(error: data["error"].stringValue, identifier: data["id"].stringValue)
                    
                // On remote index update.
                case "RemoteIndexUpdated": self = Type.RemoteIndexUpdated(device: data["device"].stringValue, folder: data["folder"].stringValue, items: data["items"].intValue)
                    
                // On local index update.
                case "LocalIndexUpdated": self = Type.LocalIndexUpdated(flags: data["flags"].stringValue, modified: data["modified"].stringValue, name: data["name"].stringValue, folder: data["folder"].stringValue, size: data["size"].intValue)
                    
                // On item started.
                case "ItemStarted": self = Type.ItemStarted(item: data["item"].stringValue, folder: data["folder"].stringValue)
                    
                // On state changed
                case "StateChanged": self = Type.StateChanged(folder: data["folder"].stringValue, from: data["from"].stringValue, duration: data["duration"].doubleValue, to: data["to"].stringValue)
                    
                // On folder rejected
                case "FolderRejected": self = Type.FolderRejected(device: data["device"].stringValue, folder: data["folder"].stringValue)
                    
                // On device rejected
                case "DeviceRejected": self = Type.DeviceRejected(address: data["address"].stringValue, device: data["device"].stringValue)
                    
                // On config saved
                case "ConfigSaved": self = Type.ConfigSaved(version: data["version"].stringValue)
                    
                // On download progress.
                case "DownloadProgress": self = Type.DownloadProgress
                
                // Otherwise
                default:
                    
                    println("[Event] Malformed json object, could not obtain the Event on type \(type)")
                    return nil
                }
                
            } else {

                // If something happened, return nil
                return nil

            }
        }
        
        // MARK: - Printable
        public var description: String {
            switch self {
            case .Starting(let home):                                                           return "Starting home: \(home)"
            case .StartupComplete:                                                              return "StartupComplete"
            case .Ping:                                                                         return "Ping"
            case .DeviceDiscovered(let addrs, let device):                                      return "DeviceDiscovered addrs: \(addrs), device: \(device)"
            case .DeviceConnected(let addr, let identifier):                                    return "DeviceConnected addr: \(addr), identifier: \(identifier)"
            case .DeviceDisconnected(let error, let identifier):                                return "DeviceDisconnected error: \(error), identifier: \(identifier)"
            case .RemoteIndexUpdated(let device, let folder, let items):                        return "RemoteIndexUpdated device: \(device), folder: \(folder), items: \(items)"
            case .LocalIndexUpdated(let flags, let modified, let name, let folder, let size):   return "LocalIndexUpdated flags: \(flags), modified: \(modified), name: \(name), folder: \(folder), size: \(size)"
            case .ItemStarted(let item, let folder):                                            return "ItemStarted item: \(item), folder: \(folder)"
            case .StateChanged(let folder, let from, let duration, let to):                     return "StateChanged folder: \(folder), from: \(from), duration: \(duration), to: \(to)"
            case .DeviceRejected(let address, let device):                                      return "DeviceRejected address: \(address), device: \(device)"
            case .ConfigSaved(let version):                                                     return "ConfigSaved version: \(version)"
            case .DownloadProgress:                                                             return "DownloadProgress"
            default:                                                                            return "Unknown"
            }
        }
    }
    
    
    /**
    The ID field on the even.
    */
    public let identifier: Int
    
    /**
    The event type.
    */
    public let type: Type
    
    // The private init in order to retrieve an event from its json representation.
    private init?(json: JSON) {
        
        // Get the fiedls
        if let identifier = json["id"].int      { self.identifier = identifier } else { return nil }
        if let typeString = json["type"].string { if let type = Type(json: json) { self.type = type } else { return nil } } else { return nil }
    }
    
    // MARK: - Printable
    public var description: String {
        return "Event: \(identifier) \(type)"
    }
}

public func retrieveNewEvents(lastIdentifier: Int, limit: Int) -> Future<Array<Event>> {
    
    // Get the events from the Syncthing API.
    return Syncthing.get("events", parameters: ["since": lastIdentifier, "limit": limit]).map { (json) in
        
        // Get all the json object and map to Event
        return json.array?.map { Event(json: $0)! } ?? []
    }
}
