//
//  ObservationCard.swift
//  Lloyds
//
//  Created by Manisha on 10/03/26.
//

import SwiftUI

struct ObservationCard: Codable, Identifiable {
    let id = UUID()
    let uuid: String?
    let enterObservationDescription: String?
    let pendingAt: String?
    let selectPriority: String?
    
    let activeButtonActions: [String]?
}
