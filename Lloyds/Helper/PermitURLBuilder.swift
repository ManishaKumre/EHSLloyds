//
//  PermitURLBuilder.swift
//  Lloyds
//
//  Created by Manisha on 23/12/25.
//

import Foundation

// Scope: All users list (v1) vs current user (v2)
enum PermitScope { case all, me }

// State: Active (status=null) vs Completed (status=DONE)
enum PermitState { case active, completed }

struct PermitURLBuilder {
    static func makeURL(scope: PermitScope,
                        state: PermitState,
                        startDate: String,
                        endDate: String,
                        offset: Int = 0,
                        plantRequired: Bool = false) -> URL? {
        
        var comps = URLComponents(string: scope == .all
                                  ? APIEndpoints.permitsV1
                                  : APIEndpoints.permitsForMe)
        
        var items: [URLQueryItem] = [
            URLQueryItem(name: "status", value: state == .active ? "null" : "DONE"),
            URLQueryItem(name: "startDate", value: startDate),
            URLQueryItem(name: "endDate", value: endDate),
            URLQueryItem(name: "plantRequired", value: String(plantRequired))
            
        ]
        
        // v1 (All) me offset chahiye, v2 (Me) me nahi
        if scope == .all {
            items.append(URLQueryItem(name: "offset", value: String(offset)))
        }
        
        comps?.queryItems = items
        return comps?.url
    }
}
