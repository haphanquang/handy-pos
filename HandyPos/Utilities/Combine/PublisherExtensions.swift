//
//  PublisherExtensions.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/05/02.
//

import Foundation
import Combine

extension Publisher {
    func reset<T, S: Scheduler>(
        after: S.SchedulerTimeType.Stride,
        on scheduler: S
    ) -> AnyPublisher<Output, Failure> where Output == T? {
        let toggled = self.compactMap { $0 }
            .debounce(for: after, scheduler: scheduler)
            .map { _ in T?(nil) }
        return Publishers.Merge(self, toggled).eraseToAnyPublisher()
    }
    
    func autoToggle<S: Scheduler>(
        after: S.SchedulerTimeType.Stride,
        on scheduler: S
    ) -> AnyPublisher<Bool, Failure> where Output == Bool {
        let toggled = self.filter { $0 == true }
            .debounce(for: after, scheduler: scheduler)
            .map { _ in false }
        return Publishers.Merge(self, toggled).eraseToAnyPublisher()
    }
}
