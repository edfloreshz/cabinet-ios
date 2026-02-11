//
//  CabinetApp.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

import SwiftData
import SwiftUI

@main
struct CabinetApp: App {
	var body: some Scene {
		WindowGroup {
			ContentView()
				.modelContainer(for: [Pair.self, Category.self])
				.toast()
		}
	}
}
