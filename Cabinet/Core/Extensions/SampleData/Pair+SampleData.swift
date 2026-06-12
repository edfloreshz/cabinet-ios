//
//  Pair+SampleData.swift
//  Cabinet
//
//  Created by Eduardo Flores on 11/06/26.
//

import Foundation

extension Pair {
	static var sampleData: [Pair] {
		let development = Drawer.sampleData[0]
		let databases = Drawer.sampleData[1]
		let social = Drawer.sampleData[2]
		let wifi = Drawer.sampleData[3]
		let work = Drawer.sampleData[4]
		let finance = Drawer.sampleData[5]
		let design = Drawer.sampleData[6]
		let server = Drawer.sampleData[7]

		return [
			Pair(
				key: "GitHub Token",
				value: "ghp_1234567890abcdefghijklmnopqrstuvwxyz",
				isFavorite: true,
				drawers: [development.id],
				lastUsedDate: Date()
			),
			Pair(
				key: "Database URL",
				value: "postgresql://user:password@localhost:5432/mydb",
				drawers: [databases.id],
				lastUsedDate: Date()
			),
			Pair(
				key: "API Key",
				value: "sk-proj-abc123def456ghi789jkl012mno345pqr678",
				isHidden: true,
				drawers: [development.id],
				lastUsedDate: Date()
			),
			Pair(
				key: "SSH Passphrase",
				value: "correct-horse-battery-staple",
				isHidden: true,
				drawers: [server.id],
				lastUsedDate: Date()
			),
			Pair(
				key: "App Store Connect",
				value: "eduardo@example.com",
				drawers: [work.id],
				lastUsedDate: Date()
			),
			Pair(
				key: "Wi-Fi Password",
				value: "MySecureNetwork2026!",
				isHidden: true,
				drawers: [wifi.id],
				lastUsedDate: Date()
			),
			Pair(
				key: "Figma Token",
				value: "figd_abcdefghijklmnopqrstuvwxyz123456",
				drawers: [design.id],
				lastUsedDate: Date()
			),
			Pair(
				key: "2FA Backup Code",
				value: "1234-5678-9012-3456",
				isHidden: true,
				drawers: [work.id, finance.id],
				lastUsedDate: Date()
			),
			Pair(
				key: "Twitter API Key",
				value: "tw-abc123def456ghi789jkl",
				isHidden: true,
				drawers: [social.id, development.id],
				lastUsedDate: Date()
			),
			Pair(
				key: "Postgres Password",
				value: "superSecretDBPass!99",
				isHidden: true,
				drawers: [databases.id],
				lastUsedDate: Date()
			)
		]
	}
}
