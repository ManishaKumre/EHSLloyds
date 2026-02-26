//
//  IncidentViewModel.swift
//  Lloyds
//
//  Created by Manisha on 29/01/26.
//

import Combine
import Foundation

class IncidentViewModel: ObservableObject {

    @Published var incidents: [Permit] = []
    @Published var isLoading = false

    private var cancellables = Set<AnyCancellable>()

    func fetchIncidents(start: Date, end: Date) {
        isLoading = true

        APIService.shared
            .fetchIncidentPermits(
                startDate: start,
                endDate: end
            )
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    self.isLoading = false
                    if case .failure(let error) = completion {
                        print("❌ Incident error:", error.localizedDescription)
                    }
                },
                receiveValue: { permits in
                    self.incidents = permits
                }
            )
            .store(in: &cancellables)
    }
}
