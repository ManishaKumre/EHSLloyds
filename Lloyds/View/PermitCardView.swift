//
//  PermitCardView.swift
//  Lloyds
//
//  Created by Manisha on 24/12/25.
//


import SwiftUI

struct PermitCardView: View {
    let permit: Permit

    
    var cleanTitle: String {
        let title =
            permit.resolvedTitle != "—"
            ? permit.resolvedTitle
            : (permit.title ?? "—")

        if title.contains(" - ") {
            return title.components(separatedBy: " - ").last ?? title
        }
        return title
    }


   


    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // MARK: - PERMIT CODE (Top Line)
           // Text(permit.permitCode ?? permit.uuid ?? "—")
            Text(permit.uuid ?? "—")

                .font(.system(size: 13))
                .foregroundColor(Color(hex: "#6a6a6a"))
                .padding(.top, 4)

            // MARK: - MAIN TITLE (ONLY clean extracted title)
            Text(cleanTitle)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, -2)

            
            // MARK: - EXTRA DETAILS
            if !permit.subAreaName.isEmpty {
                Text(permit.subAreaName)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#505050"))
            }

            HStack(spacing: 12) {

                if !permit.permitType.isEmpty {
                    Label(permit.permitType, systemImage: "doc.text")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }

                if !permit.incidentDateTime.isEmpty {
                    Label(permit.incidentDateTime, systemImage: "calendar")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 2)
            
            
            
            
            // MARK: - STATUS CHIP
            if let status = permit.status {
                Text(status)
                    .font(.system(size: 13, weight: .medium))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color(hex: "#DFF2C2"))
                    .foregroundColor(Color(hex: "#3C7F00"))
                    .clipShape(Capsule())
                    .padding(.top, 2)
            }
            
            
            // MARK: - CREATED BY + DATE (ANDROID STYLE)
//            if let createdBy = permit.createdBy,
//               let createdAt = permit.createdAt {
//
//                HStack {
//                    
//                    // 👤 User Name
//                    HStack(spacing: 4) {
//                        Image(systemName: "person")
//                            .font(.system(size: 12))
//                        Text(createdBy)
//                    }
//
//                    Spacer()
//
//                    // 📅 Date Time
//                    HStack(spacing: 4) {
//                        Image(systemName: "calendar")
//                            .font(.system(size: 12))
//                        Text(createdAt.toDisplayDateTime())
//                    }
//                }
//                .font(.system(size: 12))
//                .foregroundColor(.gray)
//                .padding(.top,234 4)
//            }

            // MARK: - ACTION PENDING ROW
            if let pendingText = permit.deactivateButtonText {

                HStack(spacing: 6) {
                    Image(systemName: "person.circle")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#6a6a6a"))

                    Text(
                        pendingText
                            .replacingOccurrences(of: "Approval Pending from ", with: "Action Pending ")
                    )
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#303030"))
                }
                .padding(.top, 2)
                .padding(.bottom, 4)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(hex: "#0077E4"), lineWidth: 1.4)
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
}





extension Color {

    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(.sRGB, red: r, green: g, blue: b)
    }
}


extension String {
    func toDisplayDateTime() -> String {
        let input = ISO8601DateFormatter()
        let output = DateFormatter()
        output.dateFormat = "yyyy-MM-dd hh:mm a"
        
        if let date = input.date(from: self) {
            return output.string(from: date)
        }
        return self
    }
}
