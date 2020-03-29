//
//  CoroutineScheduler.swift
//  SwiftCoroutine
//
//  Created by Alex Belozierov on 26.03.2020.
//  Copyright © 2020 Alex Belozierov. All rights reserved.
//

public protocol CoroutineScheduler {
    
    func executeTask(_ task: @escaping () -> Void)
    
}

extension CoroutineScheduler {
    
    // MARK: - coroutine
    
    @inlinable public func coroutine(_ task: @escaping () throws -> Void) {
        CoroutineDispatcher.default.execute(on: self) {
            do { try task() } catch { print(error) }
        }
    }
    
    // MARK: - await
    
    @inlinable public func await<T>(_ task: @escaping () throws -> T) throws -> T {
        try Coroutine.await { callback in
            coroutine { callback(Result(catching: task)) }
        }.get()
    }
    
    // MARK: - future
    
    @inlinable public func coFuture<T>(_ task: @escaping () throws -> T) -> CoFuture<T> {
        let promise = CoPromise<T>()
        coroutine { promise.complete(with: Result(catching: task)) }
        return promise
    }
    
}