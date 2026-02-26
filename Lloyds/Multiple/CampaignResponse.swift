//
//  CampaignResponse.swift
//  Lloyds
//
//  Created by Manisha on 28/12/25.
//

import SwiftUI

struct CampaignResponse: Codable {
    let sections: [CampaignSection]
    let errorMessage: String?
}
