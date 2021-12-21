//
//  BPMTapper.swift
//  bpm
//
//  Created by Harry Clegg on 03/10/2021.
//

import Foundation

class BPMTapper {
    
    let placeholderString = "bpm"
    let waitingForSecondString = "..."
    
    // Store time since last click to find intervals.
    var lastPress : NSDate = NSDate()
    
    // Reset if no click for 1.5 seconds
    let resetInterval : Double = 1.5
    var resetTimer : Timer = Timer()
    
    // Store average of time between clicks, and how many have occurred.
    var nClicks : UInt = 0
    var averageInterval : Double = 0
    
    var averageIntervalAsString : String {
        return String(Int(60 / self.averageInterval))
    }
    
    func recordInterval(withNewInterval newInterval: Double) -> String {
        // The user has clicked, increment counter.
        self.nClicks += 1
        
        if self.nClicks == 1 {
            // Clear the average interval.
            self.averageInterval = 0
            
            // Do nothing until we get a second press. Display placeholder.
            return self.waitingForSecondString
            
        } else {
            // How long do all the existing presses equate to?
            let totalTime = ((self.averageInterval * Double(self.nClicks - 2)) + newInterval)
            
            // Now we can find the average of all click intervals.
            self.averageInterval = totalTime / Double(self.nClicks - 1);
            
            // Display average bpm.
            return self.averageIntervalAsString
        }
    }
    
    func click(withResetCallback callback: @escaping (String) -> Void, andWasRightClick rightClick : Bool) -> String {
        
        if rightClick {
            // Reset internal variables if right click.
            self.clear()
            self.lastPress = NSDate()
        }
        
        // Clear any existing timer.
        self.resetTimer.invalidate()
        
        // Create a timer that will reset the bpm bar item message to placeholder after time is up.
        self.resetTimer = Timer.scheduledTimer(withTimeInterval: self.resetInterval,  repeats: false) { timer in
            callback(self.reset())
        }
        
        // Determine how long since last press.
        let thisInterval = NSDate().timeIntervalSince(self.lastPress as Date)
        
        // Store current time for next call.
        self.lastPress = NSDate()
        
        // Store the new value by melding it in to the existing average.
        // This function returns the string to display to the user.
        return self.recordInterval(withNewInterval: thisInterval)
    }
    
    func clear() {
        // Clear average interval tracking variables.
        self.nClicks = 0
        self.averageInterval = 0
    }
    
    func reset() -> String {
        // Clear average interval tracking variables.
        self.clear()
        
        // We don't want the timer to fire now in any case.
        self.resetTimer.invalidate()
        
        return self.placeholderString
    }
    
}
