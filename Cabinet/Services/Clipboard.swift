//
//  Clipboard.swift
//  Cabinet
//
//  Created by Eduardo Flores on 25/01/26.
//
#if canImport(UIKit)
	import UIKit
#else
	import AppKit
#endif

class Clipboard {
	static func copy(_ string: String) {
		#if canImport(UIKit)
			UIPasteboard.general.string = string
		#elseif canImport(AppKit)
			let pb = NSPasteboard.general
			pb.clearContents()
			pb.setString(string, forType: .string)
		#endif
	}
}
