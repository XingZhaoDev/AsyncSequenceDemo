//
//  ExampleViewModel.swift
//  AsyncSequenceDemo
//
//  Created by Xing Zhao on 2022-04-12.
//

import Foundation
import Combine
import UIKit

@MainActor
class ExampleViewModel: ObservableObject {
    @Published var isPortraitFromPublisher = false
    @Published var isPortraitFromSequence = false
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        print("deinit!")
    }
    
    func setup() {
        notificationCenterPublisher()
            .map { $0 == .portrait }
            .handleEvents(receiveOutput: { _ in print("subscription received value")})
            .assign(to: &$isPortraitFromPublisher)
        
        Task { [weak self] in
            guard let sequence = await self?.notificationCenterSequence() else { return }
            for await orientation in sequence {
                self?.isPortraitFromSequence = orientation == .portrait
                if Task.isCancelled { break }
            }
        }.store(in: &cancellables)
    }
    
    func notificationCenterPublisher() -> AnyPublisher<UIDeviceOrientation, Never> {
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .map { _ in UIDevice.current.orientation }
            .eraseToAnyPublisher()
    }
    
    func notificationCenterSequence() async -> AsyncMapSequence<NotificationCenter.Notifications, UIDeviceOrientation> {
        NotificationCenter.default.notifications(named: UIDevice.orientationDidChangeNotification)
            .map { _ in UIDevice.current.orientation }
    }
}

extension Task {
    func store(in cancellable: inout Set<AnyCancellable>) {
        asCancellable().store(in: &cancellable)
    }
    
    func asCancellable() -> AnyCancellable {
        .init{ self.cancel() }
    }
}
