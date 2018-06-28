//
//  WeakContainer.swift
//  ModuleArchitectureDemo
//
//  Created by Mladen Despotovic on 27.06.18.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation

public struct WeakContainer<T> {

    private weak var internalValue: AnyObject?
    public var value: T? {
        get {
            return internalValue as? T
        }
        set {
            internalValue = newValue as AnyObject
        }
    }
    
    public init(value: T) {
        self.value = value
    }
}
