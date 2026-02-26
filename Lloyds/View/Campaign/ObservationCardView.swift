//
//  ObservationCardView.swift
//  Lloyds
//
//  Created by Manisha on 21/01/26.
//



import SwiftUI

//
//
struct ObservationCardView: View {

    let observationIndex: Int
    let description: String
    let dependency: String
    let priority: String
    let status: String
    let actionButtonTitle: String
    let showActionButton: Bool
    var onViewDetails: () -> Void
    var onTakeAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack {
                Text("Observation \(observationIndex)")
                    .font(.headline)

                Spacer()

                Text(status)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
                    .cornerRadius(12)
            }

            ObservationFieldView(title: "Observation Description", value: description)
            ObservationFieldView(title: "Dependency", value: dependency)
            ObservationFieldView(title: "Priority", value: priority)

            HStack(spacing: 12) {
                
                Button(action: onViewDetails) {
                    HStack {
                        Image(systemName: "eye")
                        Text("View Details")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(CardButtonStyle(color: .gray))
                if showActionButton {
                    Button(action: onTakeAction) {
                        HStack {
                            Image(systemName: "checkmark.circle")
                            Text(actionButtonTitle)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(CardButtonStyle(color: .blue))
                }}
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

//  Renamed from FieldView → ObservationFieldView
struct ObservationFieldView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            Text(value)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray5))
                .cornerRadius(10)
        }
    }
}
//


struct CardButtonStyle: ButtonStyle {

    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(color.opacity(configuration.isPressed ? 0.7 : 1))
            .foregroundColor(.white)
            .cornerRadius(12)
    }
}


