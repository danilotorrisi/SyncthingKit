//
//  EventPuller.swift
//  Syncthing-Finder
//
//  Created by Danilo Torrisi on 18/01/15.
//  Copyright (c) 2015 Danilo Torrisi. All rights reserved.
//

import Foundation

private let _shareEventPuller = EventPuller()

/**
The EventPuller manages the events, retrieving them from the Syncthing API every N sec. You can configure the interval by modifiny the interval property.
*/
public class EventPuller {
    
    /**
    Returns the shared event puller. Do not instantiate new event pullers, really don't do it.
    */
    public class var sharedInstance: EventPuller { return _shareEventPuller }
    
    /**
    The pull interval between subsequential pull requets. ( msec ).
    */
    public var interval: UInt64 = 100
    
    /**
    The event pull limit. Every time the pull wakes up, it fetches a limited amount of events.
    */
    public var limit: Int = 100
    
    /**
    The last event retrieved. Every time pull() has been called, it updates the EventPuller.lastIdentifier with the latest Event identifier found. Returns nil when pull has not been called yet.
    */
    private var lastIdentifier: Int? = nil {
        didSet { println("[EventPuller] Did update last identifier with value \(lastIdentifier ?? 0)") }
    }
    
    // The private init.
    private init() {
        
        // Start pulling..
        pull()
    }

    
    // The pull function that has been called every pull interval
    func pull() {
        
        // Get the last identifier.
        let lastIdentifier = self.lastIdentifier ?? 0
        let limit = self.limit
        
        // Asynchrously.
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            
            println("[EventPuller] Will retrieve events since \(lastIdentifier) limit \(limit) ")
            
            // Retrieve new events
            _ = retrieveNewEvents(lastIdentifier ?? 0, limit).onSuccess { (events) in
                
                println("[EventPuller] Did retrieve \(events.count) events...")
                
                // Set the last identifier.
                self.lastIdentifier = events.last?.identifier
                
                // Pull again after an interfval msec.
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(self.interval * NSEC_PER_MSEC)), dispatch_get_main_queue(), self.pull)
            }
        
        }
    }
}