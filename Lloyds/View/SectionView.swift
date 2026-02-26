//
//  SectionView.swift
//  Lloyds
//
//  Created by Manisha on 28/12/25.
//

import SwiftUI

struct SectionView: View {

    @State var section: CampaignSection

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // 🔹 Section Header
            HStack {
                Text(section.title)
                    .font(.headline)

                Spacer()

                if section.expandable ?? false {
                    Image(systemName: (section.expanded ?? false) ? "chevron.up" : "chevron.down")
                }
            }
            .onTapGesture {
                if section.expandable ?? false {
                    section.expanded = !(section.expanded ?? false)
                }
            }

            // 🔹 Fields
            if section.expanded ?? false {
                ForEach(section.fields) { field in
                    FieldView(field: field)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

