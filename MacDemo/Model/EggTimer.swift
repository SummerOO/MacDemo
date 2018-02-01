//
//  EggTimer.swift
//  MacDemo
//
//  Created by zr on 2018/1/31.
//  Copyright © 2018年 ZR. All rights reserved.
//

import Cocoa

protocol EggTimerProtocol {
    func timeRemainingOnTimer(_ timer: EggTimer, timeRemaining: TimeInterval)
    func timerHasFinished(_ timer: EggTimer)
}

class EggTimer {
    
    var delegate: EggTimerProtocol?
    
    var timer: Timer? = nil
    var startTime: Date?
    var duration: TimeInterval = 360 // 默认的计时时间是 6 分钟
    var elapsedTime: TimeInterval = 0
    
    var isStopped: Bool {
        return timer == nil && elapsedTime == 0
    }
    
    var isPaused: Bool {
        return timer == nil && elapsedTime > 0
    }
    
    @objc dynamic func timerAction() {
        // 1
        guard let startTime = startTime else {
            return
        }
        
        // 2
        elapsedTime = -startTime.timeIntervalSinceNow
        
        // 3
        let secondsRemaining = (duration - elapsedTime).rounded()
        
        // 4
        if secondsRemaining <= 0 {
            resetTimer()
            delegate?.timerHasFinished(self)
        } else {
            delegate?.timeRemainingOnTimer(self, timeRemaining: secondsRemaining)
        }
    }
    
    // 1
    func startTimer() {
        startTime = Date()
        elapsedTime = 0
        
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self, selector: #selector(timerAction),
                                     userInfo: nil,
                                     repeats: true)
        timerAction()
    }
    
    // 2
    func resumeTimer() {
        startTime = Date(timeIntervalSinceNow: -elapsedTime)
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(timerAction),
                                     userInfo: nil,
                                     repeats: true)
        timerAction()
    }
    
    // 3
    func stopTimer() {
        // really just pauses the timer
        timer?.invalidate()
        timer = nil
        timerAction()
    }
    
    // 4
    func resetTimer() {
        // 停止计时器 & 重设所有属性
        timer?.invalidate()
        timer = nil
        startTime = nil
        duration = 360
        elapsedTime = 0
        timerAction()
    }
}
