//
//  Drawer+SampleData.swift
//  Cabinet
//
//  Created by Eduardo Flores on 11/06/26.
//

import Foundation

extension Drawer {
	static var sampleData: [Drawer] {
		[
			Drawer(
				id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
				name: "Development",
				icon: "hammer.fill",
				purpose: "API keys, tokens, and credentials for development tools"
			),
			Drawer(
				id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
				name: "Databases",
				icon: "cylinder.fill",
				purpose: "Connection strings and database credentials"
			),
			Drawer(
				id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
				name: "Social",
				icon: "person.2.fill",
				purpose: "Logins and tokens for social media platforms"
			),
			Drawer(
				id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
				name: "Wi-Fi",
				icon: "wifi",
				purpose: "Network names and passwords"
			),
			Drawer(
				id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
				name: "Work",
				icon: "briefcase.fill",
				purpose: "Work-related credentials and access keys"
			),
			Drawer(
				id: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!,
				name: "Finance",
				icon: "creditcard.fill",
				purpose: "Banking and payment credentials"
			),
			Drawer(
				id: UUID(uuidString: "00000000-0000-0000-0000-000000000007")!,
				name: "Design",
				icon: "paintbrush.fill",
				purpose: "Tokens and credentials for design tools"
			),
			Drawer(
				id: UUID(uuidString: "00000000-0000-0000-0000-000000000008")!,
				name: "Server",
				icon: "server.rack",
				purpose: "SSH keys, passphrases, and server credentials"
			)
		]
	}
}
