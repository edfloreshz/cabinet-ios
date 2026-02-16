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
			MasterView()
				.modelContainer(for: [Pair.self, Drawer.self])
				.toast()
		}
	}
}
