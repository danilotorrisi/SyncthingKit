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
    The pull interval ( in sec )
    */
    public var interval: Double {
        
        // Every time you set the interval, the timer will be automatically scheduled.
        didSet { resetTimer() }
    }
    
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

    /**
    The pull timer, do not touch.
    Why using dispatch source instead of NSTimer? Because NSTimer requires the target to implement methodSignatureForSelector:, which requires the target to implement NSObjectProtocol. Beacuse I want to play with plain swift, I don't want to use all the Objective-C runtime.
    */
    private var timer: dispatch_source_t?

    /**
    Stop any previous timer and start the new one.
    */
    private func resetTimer() {
        
        println("Starting the event pull with \(interval) sec interval")
        
        // If there was a previous source.
        if let source = timer {
            
            // Cancel it
            dispatch_source_cancel(source)
        }

        // Get the nsec interval.
        let nsecInterval = UInt64(interval * Double(NSEC_PER_SEC))
        
        // Create a source on a background low priority queue.
        let source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0))
        dispatch_source_set_timer(source, dispatch_time(DISPATCH_TIME_NOW, Int64(nsecInterval)), nsecInterval, nsecInterval / 3)
        dispatch_source_set_event_handler(source, pull)
        dispatch_resume(source)
        
        // Keep the timer.
        timer = source
    }
    
    
    // The private init.
    private init() {
        
        // Set up a default interval.
        interval = 1

        // Reset the timer.
        resetTimer()
    }
    
    // The pull function that has been called every pull interval
    func pull() {
        
        // Retrieve new events
        retrieveNewEvents(lastIdentifier ?? 0, limit).onSuccess { (events) in
        
            // Set the last identifier.
            self.lastIdentifier = events.last?.identifier
        }
    }
}