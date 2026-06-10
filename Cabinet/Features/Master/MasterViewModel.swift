//
//  MasterViewModel.swift
//  Cabinet
//
//  Created by Eduardo Flores on 09/06/26.
//


import SwiftUI

struct MasterViewModel {
	var isEditing = false
	var showingAdd = false
	var showingSettings = false
	var showDrawerDeleteConfirmation = false
	var editingDrawer: Drawer? = nil
	var drawerToDelete: Drawer? = nil
	var selectedItems: Set<UUID> = []
	var searchText: String = ""
	var selectedDestination: NavigationDestination? = .filter(
		.all
	)
}
