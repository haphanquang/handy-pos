//
//  AppStoreReviewHelper.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/05/02.
//

import Foundation
import SwiftUI
import StoreKit

struct ReviewCounter: ViewModifier {
    @AppStorage("com.soyo.review.screen.counter") private var reviewCounter = 0
    @AppStorage("com.soyo.last.review.date") private var lastReviewDate: Date?
    
    private static let minimumOpenTimePerReview = 5
    private static let timeSpanPerReviewInSeconds: TimeInterval = 3600 * 24 * 45 /// 45 days

    func body(content: Content) -> some View {
        content
            .onAppear {
                reviewCounter += 1
            }
            .onDisappear {
                requestReviewIfNeed()
            }
    }
    
    @MainActor private func requestReviewIfNeed() {
        guard reviewCounter % Self.minimumOpenTimePerReview == 0 else { return }
        
        if let date = lastReviewDate {
            guard date.distance(to: Date()) > Self.timeSpanPerReviewInSeconds else { return }
        }
        
        if let scene = UIApplication.shared.connectedScenes.first(
            where: { $0.activationState == .foregroundActive }
        ) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
            reviewCounter = 0
            lastReviewDate = Date()
        }
    }
}

extension View {
    func reviewCounter() -> some View {
        modifier(ReviewCounter())
    }
}

extension Date: RawRepresentable {
    private static let formatter = ISO8601DateFormatter()
    
    public var rawValue: String {
        Date.formatter.string(from: self)
    }
    
    public init?(rawValue: String) {
        self = Date.formatter.date(from: rawValue) ?? Date()
    }
}
