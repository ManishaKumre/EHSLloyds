//
//  Worksummary.swift
//  Lloyds
//
//  Created by Manisha on 21/01/26.
//

import SwiftUI

struct WorkSummaryView: View {

    let section: ViewPermitSection
    @State private var isExpanded = true

    var body: some View {
        VStack(spacing: 12) {

            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(section.title ?? "Work Summary")
                        .font(.headline)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
            }

            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(section.fields ?? [], id: \.name) { field in
                        WorkSummaryRow(field: field)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
