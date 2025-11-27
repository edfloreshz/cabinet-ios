//
//  KVRow.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

import SwiftUI

struct ItemRowView: View {
    let pair: Pair

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(pair.key)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)
                Text(pair.value)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            Spacer(minLength: 8)
        }
        .contentShape(Rectangle())
    }
}
