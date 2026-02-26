//
//  NavigationState.swift
//  Lloyds
//
//  Created by Manisha on 29/01/26.
//

import SwiftUI
import Combine

class NavigationState: ObservableObject {
    @Published var popToRoot: Bool = false
}
