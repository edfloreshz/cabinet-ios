//
//  PairGridCardView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 12/06/26.
//

import SwiftData
import SwiftUI

struct PairGridCardView: View {
	@AppStorage("accentColor") private var accent: AppColor = .indigo
	
	let pair: Pair
	let isEditing: Bool
	let isSelected: Bool
	let onTap: () -> Void
	let onEdit: () -> Void
	let onDeleteRequest: () -> Void
	
	private let cardShape = RoundedRectangle(cornerRadius: 35, style: .continuous)
	
	var body: some View {
		let cardBottomPadding = pair.image == nil ? 16.0 : 0
		
		VStack(alignment: .leading, spacing: 6) {
			VStack(alignment: .leading, spacing: 6) {
				header
				
				Text(pair.key)
					.multilineTextAlignment(.leading)
					.font(.system(size: 17, weight: .bold))
					.lineLimit(2)
					.fixedSize(horizontal: false, vertical: true)
					.frame(maxWidth: .infinity, alignment: .leading)
				
				if pair.image == nil {
					Text(pair.isHidden ? maskedValue : pair.value)
						.multilineTextAlignment(.leading)
						.font(.system(size: 12))
						.foregroundStyle(.secondary)
						.fixedSize(horizontal: false, vertical: true)
						.lineLimit(5)
						.frame(maxWidth: .infinity, alignment: .leading)
				}
			}
			.padding(.horizontal, 16)
			.padding(.top, 16)
			.padding(.bottom, cardBottomPadding)
			
			if let imageData = pair.image, let uiImage = UIImage(data: imageData) {
				Section {
					Image(uiImage: uiImage)
						.resizable()
						.scaledToFill()
						.frame(maxWidth: .infinity)
						.frame(height: 220)
						.clipped()
						.listRowInsets(EdgeInsets())
						.frame(maxWidth: .infinity)
						.clipShape(
							UnevenRoundedRectangle(
								topLeadingRadius: 35,
								bottomLeadingRadius: 0,
								bottomTrailingRadius: 0,
								topTrailingRadius: 35
							)
						)
						.padding(.horizontal, 12)
				}
			}
		}
		.background(Color(uiColor: .secondarySystemGroupedBackground))
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.compositingGroup()
		.mask(cardShape)
		.glassEffect(in: cardShape)
		.contentShape(cardShape)
		.onTapGesture(perform: onTap)
		.contextMenu {
			ControlGroup {
				if !pair.isHidden {
					ShareLink(item: pair.value) {
						Label(
							"Share",
							systemImage: "square.and.arrow.up.fill"
						)
					}
				}
				Button {
					pair.isFavorite.toggle()
				} label: {
					Label(
						pair.isFavorite ? "Unpin" : "Pin",
						systemImage: pair.isFavorite
						? "star.slash.fill" : "star.fill"
					)
				}
				Button(action: onEdit) {
					Label("Edit", systemImage: "pencil")
				}
			}
			Button(role: .destructive) {
				onDeleteRequest()
			} label: {
				Label("Delete", systemImage: "trash.fill")
			}
		}
	}
	
	private var header: some View {
		HStack(spacing: 4) {
			if pair.isFavorite {
				Image(systemName: "star.fill")
					.font(.system(size: 11, weight: .medium))
					.foregroundStyle(.secondary)
			}
			if let lastUsedDate = pair.lastUsedDate {
				Text(lastUsedDate.formatted())
					.font(.system(size: 11, weight: .medium))
					.foregroundStyle(.secondary)
			}
			
			Spacer()
			
			if isEditing {
				Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
					.font(.system(size: 18))
					.foregroundStyle(isSelected ? accent.color : .secondary)
			}
		}
	}
	
	private var maskedValue: String {
		String(repeating: "•", count: max(pair.value.count, 8))
	}
}

#Preview {
	PairGridCardView(
		pair: Pair.sampleData.first!,
		isEditing: false,
		isSelected: false,
		onTap: {},
		onEdit: {},
		onDeleteRequest: {}
	)
	.padding()
	.modelContainer(PreviewData.shared.modelContainer)
}
