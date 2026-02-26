//
//  DateTimePickerSheet.swift
//  Lloyds
//
//  Created by Manisha on 03/01/26.
//

import SwiftUI

//struct DateTimePickerSheet: View {
//
//    @Environment(\.dismiss) private var dismiss
//    @Binding var selectedDate: Date
//
//    var body: some View {
//        VStack(spacing: 16) {
//
//            DatePicker(
//                "",
//                selection: $selectedDate,
//                in: ...Date(), // 🚫 future date disabled
//                displayedComponents: [.date, .hourAndMinute]
//            )
//            .datePickerStyle(.graphical)
//
//            Button("Done") {
//                dismiss()
//            }
//            .frame(maxWidth: .infinity)
//            .padding()
//            .background(Color.blue)
//            .foregroundColor(.white)
//            .cornerRadius(10)
//        }
//        .padding()
//    }
//}

import SwiftUI



struct DateTimePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date

    // 🔥 SEPARATE STATES
    @State private var selectedOnlyDate: Date = Date()
    @State private var selectedOnlyTime: Date = Date()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {

                    // 📅 DATE PICKER (Calendar)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Select Date")
                            .font(.headline)

                        DatePicker(
                            "",
                            selection: $selectedOnlyDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                    }
                    .padding(.horizontal)

                    Divider()

                    // 🕐 TIME PICKER (Wheel)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Select Time")
                            .font(.headline)

                        DatePicker(
                            "",
                            selection: $selectedOnlyTime,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(height: 140)
                    }
                    .padding(.horizontal)

                    // 🔍 PREVIEW
                    Text(formatPreview(finalMergedDate))
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)

                    // ✅ DONE
                    Button("Done") {
                        selectedDate = finalMergedDate
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Select Date & Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .onAppear {
            // 👇 Split existing date
            selectedOnlyDate = selectedDate
            selectedOnlyTime = selectedDate
        }
    }

    // 🧠 Merge Date + Time safely
    var finalMergedDate: Date {
        let calendar = Calendar.current

        let date = calendar.dateComponents([.year, .month, .day], from: selectedOnlyDate)
        let time = calendar.dateComponents([.hour, .minute], from: selectedOnlyTime)

        var merged = DateComponents()
        merged.year = date.year
        merged.month = date.month
        merged.day = date.day
        merged.hour = time.hour
        merged.minute = time.minute

        return calendar.date(from: merged) ?? Date()
    }

    func formatPreview(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy, hh:mm a"
        return formatter.string(from: date)
    }
}
