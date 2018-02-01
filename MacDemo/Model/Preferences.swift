//
//  Preferences.swift
//  MacDemo
//
//  Created by zr on 2018/2/1.
//  Copyright © 2018年 ZR. All rights reserved.
//

import Cocoa

struct Preferences {
    
    // 1
    var selectedTime: TimeInterval {
        get {
            // 2
            let savedTime = UserDefaults.standard.double(forKey: "selectedTime")
            if savedTime > 0 {
                return savedTime
            }
            // 3
            return 360
        }
        set {
            // 4
            UserDefaults.standard.set(newValue, forKey: "selectedTime")
        }
    }
    
}
