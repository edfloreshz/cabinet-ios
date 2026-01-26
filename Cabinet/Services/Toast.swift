//
//  Toast.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/01/26.
//

import SwiftUI
import Observation

struct Toast: Equatable {
	let message: String
	let type: ToastType
	let duration: TimeInterval
	
	enum ToastType {
		case success
		case error
		case info
		case warning
		
		var icon: String {
			switch self {
			case .success: return "checkmark.circle.fill"
			case .error: return "xmark.circle.fill"
			case .info: return "info.circle.fill"
			case .warning: return "exclamationmark.triangle.fill"
			}
		}
		
		var color: Color {
			switch self {
			case .success: return .green
			case .error: return .red
			case .info: return .blue
			case .warning: return .orange
			}
		}
	}
	
	init(message: String, type: ToastType = .info, duration: TimeInterval = 3.0) {
		self.message = message
		self.type = type
		self.duration = duration
	}
}

@Observable
@MainActor
class ToastManager {
	static let shared = ToastManager()
	
	var toast: Toast?
	
	private init() {}
	
	func show(_ message: String, type: Toast.ToastType = .info, duration: TimeInterval = 1.2) {
		withAnimation(.spring(duration: 0.25)) {
			toast = Toast(message: message, type: type, duration: duration)
		}
		
		Task {
			try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
			if toast?.message == message {
				withAnimation(.easeOut(duration: 0.2)) {
					toast = nil
				}
			}
		}
	}
	
	func dismiss() {
		withAnimation(.easeOut(duration: 0.2)) {
			toast = nil
		}
	}
}

struct ToastView: View {
	let toast: Toast
	
	var body: some View {
		Label(toast.message, systemImage: toast.type.icon)
			.foregroundStyle(toast.type.color)
			.transition(.move(edge: .bottom).combined(with: .opacity))
			.padding()
			.glassEffect()
	}
}

struct ToastModifier: ViewModifier {
	@State private var toastManager = ToastManager.shared
	
	func body(content: Content) -> some View {
		content
			.overlay(alignment: .bottom) {
				if let toast = toastManager.toast {
					ToastView(toast: toast)
						.padding(.bottom, 55)
						.padding(.leading, 20)
						.padding(.trailing, 20)
						.transition(.move(edge: .bottom).combined(with: .opacity))
				}
			}
	}
}

extension View {
	func toast() -> some View {
		modifier(ToastModifier())
	}
}
