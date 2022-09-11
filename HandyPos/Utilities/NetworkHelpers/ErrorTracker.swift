/*
 * Copyright (c) Rakuten Payment, Inc. All Rights Reserved.
 *
 * This program is the information asset which are handled
 * as "Strictly Confidential".
 * Permission of use is only admitted in Rakuten Payment, Inc.
 * If you don't have permission, MUST not be published,
 * broadcast, rewritten for broadcast or publication
 * or redistributed directly or indirectly in any medium.
 */

import Foundation
import Combine

/**
 Enables monitoring error of sequence computation.
 */
public final class ErrorTracker {
    private struct ActivityToken<Source: Publisher> {
        let source: Source
        let errorAction: (Source.Failure) -> Void
        
        func asPublisher() -> AnyPublisher<Source.Output, Never> {
            source.handleEvents(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    errorAction(error)
                }
            })
            .catch { _ in Empty(completeImmediately: true) }
            .eraseToAnyPublisher()
        }
    }
    
    @Published
    private var relay: Error?
    private let lock = NSRecursiveLock()
    
    public var errors: AnyPublisher<Error, Never> {
        $relay.compactMap { $0 }.eraseToAnyPublisher()
    }
    
    public init() {}
    
    public func trackErrorOfPublisher<Source: Publisher>(source: Source) -> AnyPublisher<Source.Output, Never> {
        return ActivityToken(source: source) { error in
            self.lock.lock()
            self.relay = error
            self.lock.unlock()
        }.asPublisher()
    }
}

extension Publisher {
    public func trackError(_ errorIndicator: ErrorTracker) -> AnyPublisher<Self.Output, Never> {
        errorIndicator.trackErrorOfPublisher(source: self)
    }
}
