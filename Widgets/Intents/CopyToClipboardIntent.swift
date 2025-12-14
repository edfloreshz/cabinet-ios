//
//  CopyToClipboardIntent.swift
//  Cabinet
//
//  Created by Eduardo Flores on 14/12/25.
//

import AppIntents
import UIKit

struct CopyToClipboardIntent: AppIntent {
    static var title: LocalizedStringResource = "Copy to Clipboard"
    
    @Parameter(title: "Value")
    var value: String
    
    init() {}
    
    init(value: String) {
        self.value = value
    }
    
    func perform() async throws -> some IntentResult {
        print("Hello, World!")
    #if canImport(UIKit)
        UIPasteboard.general.string = value
    #elseif canImport(AppKit)
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(value, forType: .string)
    #endif
        
        return .result()
    }
}
