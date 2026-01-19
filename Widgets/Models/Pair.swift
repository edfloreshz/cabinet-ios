//
//  KVPair.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

import Foundation
import SwiftData

@Model
final class Pair {
    @Attribute(.unique) var id: UUID
    var key: String
    var value: String
    var isFavorite: Bool
    var isHidden: Bool

    init(id: UUID = UUID(), key: String, value: String, isFavorite: Bool = false, isHidden: Bool = false) {
        self.id = id
        self.key = key
        self.value = value
        self.isFavorite = isFavorite
        self.isHidden = isHidden
    }
    
    static let sampleData = [
        Pair(key: "Bank Account", value: "12390520234", isHidden: true),
        Pair(key: "License Plate", value: "ABC-123-XYZ", isFavorite: true),
        Pair(key: "Computer Name", value: "Steam Machine"),
        Pair(key: "Credit Card", value: "4532 1234 5678 9010", isHidden: true),
    ]
    
    static let recentlyUsedOne = [
        Pair(key: "RFC", value: "DHRF990011Y3D", isFavorite: true),
        Pair(key: "Phone", value: "+52 662 123 4567"),
        Pair(key: "Username", value: "edfloreshz"),
        Pair(key: "Email", value: "eduardo@gmail.com"),
        Pair(key: "Bank Account", value: "12390520234", isHidden: true),
        Pair(key: "License Plate", value: "ABC-123-XYZ", isFavorite: true),
        Pair(key: "Computer Name", value: "Steam Machine"),
        Pair(key: "Credit Card", value: "4532 1234 5678 9010", isHidden: true),
        Pair(key: "Wi-Fi Password", value: "MySecurePass123!", isHidden: true),
        Pair(key: "CURP", value: "DEHE990011HSONRD05", isFavorite: true),
    ]
    
    static let recentlyUsedTwo = [
        Pair(key: "Email", value: "eduardo@gmail.com"),
        Pair(key: "RFC", value: "DHRF990011Y3D", isFavorite: true),
        Pair(key: "Credit Card", value: "4532 1234 5678 9010", isHidden: true),
        Pair(key: "Phone", value: "+52 662 123 4567"),
        Pair(key: "Wi-Fi Password", value: "MySecurePass123!", isHidden: true),
        Pair(key: "Bank Account", value: "12390520234", isHidden: true),
        Pair(key: "License Plate", value: "ABC-123-XYZ", isFavorite: true),
        Pair(key: "CURP", value: "DEHE990011HSONRD05", isFavorite: true),
        Pair(key: "Computer Name", value: "Steam Machine"),
        Pair(key: "Username", value: "edfloreshz"),
    ]
    
    static let recentlyUsedThree = [
        Pair(key: "Email", value: "eduardo@gmail.com"),
        Pair(key: "CURP", value: "DEHE990011HSONRD05", isFavorite: true),
        Pair(key: "Computer Name", value: "Steam Machine"),
        Pair(key: "Bank Account", value: "12390520234", isHidden: true),
        Pair(key: "RFC", value: "DHRF990011Y3D", isFavorite: true),
        Pair(key: "Phone", value: "+52 662 123 4567"),
        Pair(key: "Wi-Fi Password", value: "MySecurePass123!", isHidden: true),
        Pair(key: "License Plate", value: "ABC-123-XYZ", isFavorite: true),
        Pair(key: "Credit Card", value: "4532 1234 5678 9010", isHidden: true),
        Pair(key: "Username", value: "edfloreshz"),
    ]
}
