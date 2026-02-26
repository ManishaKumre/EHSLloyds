//
//  SystemDateTimePicker.swift
//  Lloyds
//
//  Created by Manisha on 05/01/26.
//

import SwiftUI

struct SystemDateTimePicker: UIViewControllerRepresentable {

    @Binding var selectedDate: Date

    func makeUIViewController(context: Context) -> UIDatePickerViewController {
        let vc = UIDatePickerViewController()
        vc.onDone = { date in
            selectedDate = date
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: UIDatePickerViewController, context: Context) {}
}
