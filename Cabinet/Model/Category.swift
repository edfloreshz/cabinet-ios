//
//  Category.swift
//  Cabinet
//
//  Created by Eduardo Flores on 15/02/26.
//

import Foundation
import SwiftUI

struct Category: Identifiable {
	let id = UUID()
	let title: String
	let icon: String
	let color: Color
	var count: Int
}
