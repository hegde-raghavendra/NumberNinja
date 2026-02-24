//
//  Item.swift
//  Number Ninja Jr
//
//  Created by Raghavendra Hegde on 2/22/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
