//
//  SampleData.swift
//  Cabinet
//
//  Created by Eduardo Flores on 28/11/25.
//

import Foundation
import SwiftData

@MainActor
class PreviewData {
	static let shared = PreviewData()
	let modelContainer: ModelContainer
	var context: ModelContext {
		modelContainer.mainContext
	}

	private init() {
		let schema = Schema([
			Pair.self,
			Drawer.self,
		])

		let modelConfiguration = ModelConfiguration(
			schema: schema,
			isStoredInMemoryOnly: true
		)

		do {
			modelContainer = try ModelContainer(
				for: schema,
				configurations: [modelConfiguration]
			)

			let drawers = Drawer.sampleData

			for drawer in drawers {
				context.insert(drawer)
			}

			for pair in Pair.sampleData(drawers: drawers) {
				context.insert(pair)
			}

			try context.save()
		} catch {
			fatalError("Could not create ModelContainer: \(error)")
		}
	}
}
