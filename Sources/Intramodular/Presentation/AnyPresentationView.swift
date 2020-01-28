//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A type-erased `View` suitable for presentation purposes.
public struct AnyPresentationView: CustomStringConvertible, View {
    private let base: AnyView
    private let baseType: ObjectIdentifier
    
    private var environment: EnvironmentBuilder
    
    var _name: ViewName? {
        return (body as? opaque_NamedView)?.name
    }
    
    public var description: String {
        if let name = _name {
            return "\(name) (\(base)"
        } else {
            return String(describing: base)
        }
    }
    
    public init<V: View>(_ view: V) {
        if let view = view as? AnyPresentationView {
            self = view
        } else {
            self.base = view.eraseToAnyView()
            self.baseType = .init(type(of: view))
            self.environment = .init()
            
            if let viewName = (view as? opaque_NamedView)?.name {
                self.environment.setViewName(viewName)
            }
        }
    }
    
    public var body: some View {
        base.mergeEnvironmentBuilder(environment)
    }
}

extension AnyPresentationView {
    public func mergeEnvironmentBuilder(_ builder: EnvironmentBuilder) -> AnyPresentationView {
        then {
            $0.environment.merge(builder)
        }
    }
}

// MARK: - API -

extension View {
    public func eraseToAnyPresentationView() -> AnyPresentationView {
        return .init(self)
    }
}