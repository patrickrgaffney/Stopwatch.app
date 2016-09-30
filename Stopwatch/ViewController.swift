//
//  ViewController.swift
//  Stopwatch
//
//  Created by Patrick Gaffney on 09/19/16.
//  Copyright © 2016 Patrick Gaffney. All rights reserved.
//

import UIKit

class ViewController: UIViewController, StopwatchDelegate, UITableViewDataSource, UITableViewDelegate {

    /// Interface builder outlets.
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    @IBOutlet weak var millisecondsLabel: UILabel!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var lapBtn: UIButton!
    @IBOutlet weak var lapsTableView: UITableView!
    
    /// Private instance of Stopwatch.
    private var watch: Stopwatch!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        watch = Stopwatch(delegate: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeTimerUI()
        lapsTableView.delegate = self
        lapsTableView.dataSource = self
    }
    
    // *****************************************************************
    // MARK: - StopwatchDelegate Methods
    // *****************************************************************
    
    /// Sent when the Timer has been updated with a new time -- every 0.01 seconds.
    func currentTimerUpdated(seconds: String, minutes: String, milliseconds: String) {
        minutesLabel.text = minutes
        secondsLabel.text = seconds
        millisecondsLabel.text = milliseconds
        lapsTableView.reloadData()
    }
    
    /// Sent when a new Timer is started.
    func timerHasStarted() {
        startBtn.setTitle("Stop", for: .normal)
        lapBtn.setTitle("Lap", for: .normal)
        lapBtn.isEnabled = true
    }
    
    /// Sent when the current Timer is stopped.
    func timerHasStopped() {
        startBtn.setTitle("Start", for: .normal)
        
        if let _ = watch.timer, (watch.timer?.isValid)! == false {
            lapBtn.setTitle("Reset", for: .normal)
        }
        else {
            lapBtn.isEnabled = false
        }
    }
    
    /// Sent when the a user-preformed reset of the timer occurs.
    func timerWasReset() {
        lapsTableView.reloadData()
        initializeTimerUI()
    }
    
    // *****************************************************************
    // MARK: - UI Manipulation and Drawing.
    // *****************************************************************
    
    /// Initialize the Timer UI.
    func initializeTimerUI() {
        minutesLabel.text = "00"
        secondsLabel.text = "00"
        millisecondsLabel.text = "00"
        lapBtn.isEnabled = false
        timerHasStopped()
    }

    // *****************************************************************
    // MARK: - Interface Builder Action Methods
    // *****************************************************************
    
    /// Action-function for the Start/Stop button.
    @IBAction func startBtnPressed(_ sender: AnyObject) {
        
        /// If watch.timer exists and is valid, stop the timer. Otherwise, start one.
        if let _ = watch.timer, (watch.timer?.isValid)! {
            watch.stopTimer()
        }
        else {
            watch.startTimer()
        }
    }
    
    /// Action-function for Lap/Reset button.
    @IBAction func lapBtnPressed(_ sender: AnyObject) {
        
        if let _ = watch.timer, (watch.timer?.isValid)! {
            watch.completeLap()
        }
        else {
            watch.resetTimer()
        }
        
    }
    
    // *****************************************************************
    // MARK: - Table View Methods
    // *****************************************************************
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LapCell", for: indexPath)
        cell.textLabel?.text = "Lap \(indexPath.row + 1)"
        cell.detailTextLabel?.text = "\(watch.laps[indexPath.row])"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watch.laps.count
    }
    
}

