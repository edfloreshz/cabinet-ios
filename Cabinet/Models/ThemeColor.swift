//
//  ThemeColor.swift
//  Cabinet
//
//  Created by Eduardo Flores on 10/02/26.
//

import SwiftUI

enum ThemeColor: String, CaseIterable {
	case indigo, blue, purple, pink, red, orange, yellow, green, teal, cyan
	
	var color: Color {
		switch self {
			case .indigo: return .indigo
			case .blue:   return .blue
			case .purple: return .purple
			case .pink:   return .pink
			case .red:    return .red
			case .orange: return .orange
			case .yellow: return .yellow
			case .green:  return .green
			case .teal:   return .teal
			case .cyan:   return .cyan
		}
	}
}
