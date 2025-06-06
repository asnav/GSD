//
//  Session.swift
//  GSD
//
//  Created by Asaf Navon on 5/15/25.
//

import Foundation
import SwiftData

@Model
final class Session {
    var startingTime: Date
    var cycles: [WorkRestCycle] = []
    
    init(startingTime: Date) {
        self.startingTime = startingTime
    }
}

@Model
class WorkRestCycle {
    var workTime: TimeInterval // Duration in seconds
    var restTime: TimeInterval // Duration in seconds
    
    init(workTime: TimeInterval, restTime: TimeInterval) {
        self.workTime = workTime
        self.restTime = restTime
    }
}
