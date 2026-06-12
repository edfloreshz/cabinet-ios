//
//  ClipboardService.swift
//  Cabinet
//
//  Created by Eduardo Flores on 09/06/26.
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

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
