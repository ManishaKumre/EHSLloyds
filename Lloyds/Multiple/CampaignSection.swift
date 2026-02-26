//
//  CampaignSection.swift
//  Lloyds
//
//  Created by Manisha on 28/12/25.
//

import SwiftUI


struct CampaignSection: Codable, Identifiable {
    var id = UUID()
    let title: String
    let permitStatus: String?
    let subtitle: String?
    var fields: [CampaignField]
    let grids: [String]?
    let tables: [String]?
    let sections: [CampaignSection]?
    let errorMessage: String?
    let twoColumnType: String?
    var expandable: Bool?
    var expanded: Bool?
    var displayTitle: String?  
    
    enum CodingKeys: String, CodingKey {
        case title, permitStatus, subtitle, fields
        case grids, tables, sections, errorMessage
        case twoColumnType, expandable, expanded
      
    }
}





struct CampaignMock {
    static let json = """
    {
        "sections": []
    }
    """
}
