//
//  Worker.swift
//  Application
//
//  Created by Mario Matheus on 03/07/19.
//

import Foundation
import Dispatch


class Worker {
    
    static let queue = Worker()
    private let workerQueue: DispatchQueue
    
    private init() {
        workerQueue = DispatchQueue(label: "worker")
    }
    
    func execute(_ block: (() -> Void)) {
        workerQueue.sync {
            block()
        }
    }
    
}
