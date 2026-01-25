//
//  SampleData.swift
//  Cabinet
//
//  Created by Eduardo Flores on 28/11/25.
//

import Foundation
import SwiftData

@MainActor
class SampleData {
	static let shared = SampleData()
	let modelContainer: ModelContainer
	var context: ModelContext {
		modelContainer.mainContext
	}
	
	private init() {
		let schema = Schema([
			Pair.self,
		])
		
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
		
		do {
			modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
			
			for pair in Pair.sampleData {
				context.insert(pair)
			}
			
			try context.save()
		} catch {
			fatalError("Could not create ModelContainer: \(error)")
		}
	}
}
