//
//  Pair+SampleData.swift
//  Cabinet
//
//  Created by Eduardo Flores on 11/06/26.
//

import Foundation

extension Pair {
	static func sampleData(drawers: [Drawer]) -> [Pair] {
		guard drawers.count >= 8 else { return [] }

		let development = drawers[0]
		let databases = drawers[1]
		let social = drawers[2]
		let wifi = drawers[3]
		let work = drawers[4]
		let finance = drawers[5]
		let design = drawers[6]
		let server = drawers[7]

		return [
			try! Pair.create(
				key: "GitHub Token",
				value: "ghp_1234567890abcdefghijklmnopqrstuvwxyz",
				isFavorite: true,
				drawers: [development],
				lastUsedDate: Date()
			),
			try! Pair.create(
				key: "Database URL",
				value: "postgresql://user:password@localhost:5432/mydb",
				drawers: [databases],
				lastUsedDate: Date()
			),
			try! Pair.create(
				key: "API Key",
				value: "sk-proj-abc123def456ghi789jkl012mno345pqr678",
				isHidden: true,
				drawers: [development],
				lastUsedDate: Date()
			),
			try! Pair.create(
				key: "SSH Passphrase",
				value: "correct-horse-battery-staple",
				isHidden: true,
				drawers: [server],
				lastUsedDate: Date()
			),
			try! Pair.create(
				key: "App Store Connect",
				value: "eduardo@example.com",
				drawers: [work],
				lastUsedDate: Date()
			),
			try! Pair.create(
				key: "Wi-Fi Password",
				value: "MySecureNetwork2026!",
				isHidden: true,
				drawers: [wifi],
				lastUsedDate: Date()
			),
			try! Pair.create(
				key: "Figma Token",
				value: "figd_abcdefghijklmnopqrstuvwxyz123456",
				drawers: [design],
				lastUsedDate: Date()
			),
			try! Pair.create(
				key: "2FA Backup Code",
				value: "1234-5678-9012-3456",
				isHidden: true,
				drawers: [work, finance],
				lastUsedDate: Date()
			),
			try! Pair.create(
				key: "Twitter API Key",
				value: "tw-abc123def456ghi789jkl",
				isHidden: true,
				drawers: [social, development],
				lastUsedDate: Date()
			),
			try! Pair.create(
				key: "Postgres Password",
				value: "superSecretDBPass!99",
				isHidden: true,
				drawers: [databases],
				lastUsedDate: Date()
			)
		]
	}

	static var sampleData: [Pair] {
		sampleData(drawers: Drawer.sampleData)
	}
}
