//
//  LayoutType.swift
//  Cabinet
//
//  Created by Eduardo Flores on 12/06/26.
//

import Foundation

enum LayoutType: String, CaseIterable, Identifiable {
	case list
	case grid

	var id: Self { self }

	var title: String {
		switch self {
		case .list:
			return "List"
		case .grid:
			return "Grid"
		}
	}

	var symbolName: String {
		switch self {
		case .list:
			return "list.bullet"
		case .grid:
			return "square.grid.2x2"
		}
	}

	var toggleTarget: LayoutType {
		switch self {
		case .list:
			return .grid
		case .grid:
			return .list
		}
	}

	var toggleTitle: String {
		toggleTarget.title
	}

	var toggleSystemImage: String {
		toggleTarget.symbolName
	}
}
