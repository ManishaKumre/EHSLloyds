//
//  UIDatePickerViewController.swift
//  Lloyds
//
//  Created by Manisha on 05/01/26.
//

import UIKit

class UIDatePickerViewController: UIViewController {

    let picker = UIDatePicker()
    var onDone: ((Date) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        // ✅ Date + Time together
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels

        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)

        picker.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(picker)
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            picker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            picker.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            doneButton.topAnchor.constraint(equalTo: picker.bottomAnchor, constant: 20),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc func doneTapped() {
        onDone?(picker.date)
        dismiss(animated: true)
    }
}
