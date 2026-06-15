//
//  MasterView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

import SwiftData
import SwiftUI

struct MasterView: View {
	@State var selectedDestination: Destination? = .filter(.all)

	var body: some View {
		NavigationSplitView {
			SidebarView(selectedDestination: $selectedDestination)
		} detail: {
			ContentView(selectedDestination: $selectedDestination)
		}
	}
}

#Preview {
	MasterView()
		.modelContainer(PreviewData.shared.modelContainer)
}
