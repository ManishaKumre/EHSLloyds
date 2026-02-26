//
//  PermitDetailView.swift
//  Lloyds
//
//  Created by Manisha on 03/03/26.
//

import SwiftUI
import Combine


//struct PermitDetailView: View {
//    let responseData: [String: Any] 
//    
//    var body: some View {
//        List {
//            if let sections = responseData["sections"] as? [[String: Any]] {
//                ForEach(0..<sections.count, id: \.self) { index in
//                    let section = sections[index]
//                    let title = section["title"] as? String ?? ""
//                    let fields = section["fields"] as? [[String: Any]] ?? []
//                    
//                    if !title.isEmpty {
//                        SectionView(title: title, fields: fields, isExpanded: section["expanded"] as? Bool ?? false)
//                    }
//                }
//            }
//        }
//        .listStyle(InsetGroupedListStyle())
//        .navigationTitle("Campaign Details")
//    }
//}
