//
//  Stopwatch.swift
//  Stopwatch
//
//  Created by Patrick Gaffney on 09/19/16.
//  Copyright © 2016 Patrick Gaffney. All rights reserved.
//

import Foundation


/// The class protocol for a Stopwatch instance.
protocol StopwatchDelegate: class {
    func currentTimerUpdated(seconds: String, minutes: String, milliseconds: String)
    func timerHasStarted()
    func timerHasStopped()
    func timerWasReset()
}


/// A container for a stopwatch.
class Stopwatch {
    
    // *****************************************************************
    // MARK: - Stopwatch Properties
    // *****************************************************************
    
    /// The middleman for communicating with the view controller.
    weak var delegate: StopwatchDelegate?
    
    /// The actual Timer for this stopwatch.
    private(set) var timer: Timer?
    
    /// The time at which the timer was started.
    private(set) var timerStartTime: TimeInterval = 0
    
    /// The Timer-time at which the last user *pause* occurred.
    private(set) var timerSavedTime: TimeInterval = 0
    
    /// An array of laps. Laps as saved as an actual string representation
    /// of current running time.
    private(set) var laps = [String]()
    
    /// The number of the currently running lap.
    private(set) var currentLap = 0
    
    private(set) var lapStartTime: TimeInterval?
    private(set) var lapSavedTime: TimeInterval = 0
    
    // *****************************************************************
    // MARK: - Stopwatch Class Methods
    // *****************************************************************

    /// Create a new Stopwatch by locating the middleman and starting the timer.
    ///
    /// - Parameter delegate: the middleman to communicate to the view controller.
    /// - Returns: An instance to a ticking `Stopwatch`.
    ///
    init(delegate: StopwatchDelegate) {
        self.delegate = delegate
    }
    
    // *****************************************************************
    // MARK: - Stopwatch Timer Methods
    // *****************************************************************
    
    /// Start the stopwatch's timer.
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self,
                                     selector: #selector(timerHasTicked(timer:)),
                                     userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
        
        laps.append("")
        
        /// Record the time at which we started this timer.
        timerStartTime = Date.timeIntervalSinceReferenceDate
        lapStartTime = timerStartTime
        
        delegate?.timerHasStarted()
    }
    
    /// Pause the Timer and any current lap.
    func stopTimer() {
        /// Save the Time delta of the current Timer.
        let currentTime = Date.timeIntervalSinceReferenceDate
        timerSavedTime += currentTime - timerStartTime
        lapSavedTime   += currentTime - lapStartTime!
        
        timer?.invalidate()
        delegate?.timerHasStopped()
    }
    
    /// Reset the Timer and all of the laps.
    func resetTimer() {
        timerSavedTime = 0
        currentLap = 0
        lapSavedTime = 0
        lapStartTime = nil
        laps.removeAll()
        delegate?.timerWasReset()
    }
    
    /// End the current lap and start a new lap.
    func completeLap() {
        laps.append("")
        currentLap += 1
        
        lapStartTime = Date.timeIntervalSinceReferenceDate
        lapSavedTime = 0
    }
    
    /// Compute the new time values time values:
    ///
    /// - `minutes`: starts at 0 and increments to 59
    /// - `seconds`: starts at 0 and increments to 59
    /// - `milliseconds`: starts at 0 and increments to 99
    ///
    /// - Parameter timer: The instance of the currently *running* Timer.
    ///
    @objc private func timerHasTicked(timer: Timer) {
        
        /// Find the time delta between start time and now.
        let currentTime = Date.timeIntervalSinceReferenceDate
        let timerElapsedTime: TimeInterval = (currentTime - timerStartTime) + timerSavedTime
        let lapElapsedTime: TimeInterval = (currentTime - lapStartTime!) + lapSavedTime
        
        /// Convert elapsed time to minutes, seconds, and milliseconds.
        let minutes = Int(timerElapsedTime / 60.0)
        let seconds = Int(timerElapsedTime - (TimeInterval(minutes) * 60))
        let milliseconds = Int((timerElapsedTime - TimeInterval(seconds)) * 100)
        
        let lapMinutes = Int(lapElapsedTime / 60.0)
        let lapSeconds = Int(lapElapsedTime - (TimeInterval(lapMinutes) * 60))
        let lapMilliseconds = Int((lapElapsedTime - TimeInterval(lapSeconds)) * 100)
        
        /// Update the current lap.
        laps[currentLap] = "\(String(format: "%02u", lapMinutes)):\(String(format: "%02u", lapSeconds)).\(String(format: "%02u", lapMilliseconds))"
        
        /// Let the delegate know the Time has been updated.
        delegate?.currentTimerUpdated(seconds: String(format: "%02u", seconds),
                                      minutes: String(format: "%02u", minutes),
                                      milliseconds: String(format: "%02u", milliseconds))
    }
}
