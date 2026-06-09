//
//  ClipboardService.swift
//  Cabinet
//
//  Created by Eduardo Flores on 09/06/26.
//

import UIKit

class ClipboardService {
	static let shared = ClipboardService()
	
	func copy(text: String) {
		#if canImport(UIKit)
			UIPasteboard.general.string = text
		#elseif canImport(AppKit)
			let pasteBoard = NSPasteboard.general
			pasteBoard.clearContents()
			pasteBoard.setString(text, forType: .string)
		#endif
	}
}
