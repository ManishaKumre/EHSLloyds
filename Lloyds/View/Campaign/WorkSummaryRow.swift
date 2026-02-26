//
//  WorkSummaryRow.swift
//  Lloyds
//
//  Created by Manisha on 21/01/26.
//

import SwiftUI

struct WorkSummaryRow: View {

    let field: PermitField

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            VStack(alignment: .leading, spacing: 4) {
                Text(field.name ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text(field.description ?? "-")
                    .font(.body)
                    .foregroundColor(.primary)
            }

            Spacer()
        }
    }
}

