//
//  Untitled.swift
//  Lloyds
//
//  Created by Manisha on 05/01/26.
//

import SwiftUI

//shi hai bilkul bss date
//
//struct WheelDateTimePicker: UIViewRepresentable {
//    @Binding var date: Date
//
//    func makeUIView(context: Context) -> UIDatePicker {
//        let picker = UIDatePicker()
//        picker.datePickerMode = .dateAndTime
//        picker.preferredDatePickerStyle = .wheels
//
//        let now = Date()
//        let maxDate = Calendar.current.date(byAdding: .hour, value: 72, to: now)!
//
//        picker.minimumDate = now
//        picker.maximumDate = maxDate
//
//        picker.addTarget(
//            context.coordinator,
//            action: #selector(Coordinator.dateChanged(_:)),
//            for: .valueChanged
//        )
//        return picker
//    }
//
//    func updateUIView(_ uiView: UIDatePicker, context: Context) {
//        let now = Date()
//        let maxDate = Calendar.current.date(byAdding: .hour, value: 72, to: now)!
//
//        uiView.minimumDate = now
//        uiView.maximumDate = maxDate
//        uiView.date = min(max(date, now), maxDate) 
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject {
//        let parent: WheelDateTimePicker
//        init(_ parent: WheelDateTimePicker) {
//            self.parent = parent
//        }
//
//        @objc func dateChanged(_ sender: UIDatePicker) {
//            parent.date = sender.date
//        }
//    }
//}
//


struct WheelDateTimePicker: UIViewRepresentable {
    @Binding var date: Date

    let minDate: Date?
    let maxDate: Date?
    let lockTimeToNow: Bool   // 👈 NEW

    func makeUIView(context: Context) -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels

        picker.minimumDate = minDate
        picker.maximumDate = maxDate

        picker.addTarget(
            context.coordinator,
            action: #selector(Coordinator.dateChanged(_:)),
            for: .valueChanged
        )
        return picker
    }

    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        uiView.minimumDate = minDate
        uiView.maximumDate = maxDate

        if lockTimeToNow {
            let now = Date()

            // 🔒 time ko current pe lock
            var components = Calendar.current.dateComponents(
                [.year, .month, .day],
                from: uiView.date
            )

            let time = Calendar.current.dateComponents(
                [.hour, .minute],
                from: now
            )

            components.hour = time.hour
            components.minute = time.minute

            uiView.date = Calendar.current.date(from: components) ?? now
        } else {
            uiView.date = date
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        let parent: WheelDateTimePicker
        init(_ parent: WheelDateTimePicker) {
            self.parent = parent
        }

        @objc func dateChanged(_ sender: UIDatePicker) {
            parent.date = sender.date
        }
    }
}





import SwiftUI

//struct DateTimeBottomSheet: View {
//    @Binding var selectedDate: Date
//    @Binding var isPresented: Bool
//
//    var onSet: () -> Void
//    var onClear: () -> Void
//
//    var body: some View {
//        VStack(spacing: 20) {
//
//            Text("Set date and time")
//                .font(.headline)
//
//            WheelDateTimePicker(date: $selectedDate)
//                .frame(height: 200)
//
//            HStack {
//                Button("Clear") {
//                    onClear()
//                    isPresented = false
//                }
//
//                Spacer()
//
//                Button("Cancel") {
//                    isPresented = false
//                }
//
//                Button("Set") {
//                    onSet()
//                    isPresented = false
//                }
//            }
//            .padding(.horizontal)
//        }
//        .padding()
//    }

struct DateTimeBottomSheet: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool

    let minDate: Date?
    let maxDate: Date?
    let lockTimeToNow: Bool

    var onSet: () -> Void
    var onClear: () -> Void

    var body: some View {
        VStack(spacing: 20) {

            Text("Set date and time")
                .font(.headline)

            WheelDateTimePicker(
                date: $selectedDate,
                minDate: minDate,
                maxDate: maxDate,
                lockTimeToNow: lockTimeToNow
            )
            .frame(height: 200)

            HStack {
                Button("Clear") {
                    onClear()
                    isPresented = false
                }

                Spacer()

                Button("Cancel") {
                    isPresented = false
                }

                Button("Set") {
                    onSet()
                    isPresented = false
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
}


