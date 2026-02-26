//
//  IncidentsectionView.swift
//  Lloyds
//
//  Created by Manisha on 30/01/26.
//

import SwiftUI

struct IncidentSectionView: View {

    @Binding var section: FormSection

    var body: some View {
        DisclosureGroup(
            isExpanded: $section.expanded
        ) {
            VStack(spacing: 12) {
                ForEach($section.fields) { $field in
                   // IncidentDynamicFieldView(field: $field)
                    IncidentDynamicFieldView(field: $field, allFieldsInSection: $section.fields)
                }
            }
            .padding(.top, 8)
        } label: {
            Text(section.title.uppercased())
                .font(.headline)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}
