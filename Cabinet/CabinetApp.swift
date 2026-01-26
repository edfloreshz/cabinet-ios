//
//  CabinetApp.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

import SwiftUI
import SwiftData

@main
struct CabinetApp: App {
	var body: some Scene {
		WindowGroup {
			ContentView()
				.modelContainer(for: Pair.self)
				.toast()
		}
	}
}
