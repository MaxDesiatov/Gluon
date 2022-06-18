// Copyright 2022 Tokamak contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Created by Carson Katri on 2/7/22.
//

import Foundation

/// Data passed to `_makeView` to create the `ViewOutputs` used in reconciling/rendering.
public struct ViewInputs<V> {
  public let content: V
  @_spi(TokamakCore)
  public let environment: EnvironmentBox
}

/// Data used to reconcile and render a `View` and its children.
public struct ViewOutputs {
  /// A container for the current `EnvironmentValues`.
  /// This is stored as a reference to avoid copying the environment when unnecessary.
  let environment: EnvironmentBox
  let preferences: _PreferenceStore
}

@_spi(TokamakCore)
public final class EnvironmentBox {
  public let environment: EnvironmentValues

  public init(_ environment: EnvironmentValues) {
    self.environment = environment
  }
}

public extension ViewOutputs {
  init<V>(
    inputs: ViewInputs<V>,
    environment: EnvironmentValues? = nil,
    preferences: _PreferenceStore? = nil
  ) {
    // Only replace the `EnvironmentBox` when we change the environment.
    // Otherwise the same box can be reused.
    self.environment = environment.map(EnvironmentBox.init) ?? inputs.environment
    self.preferences = preferences ?? .init()
  }
}

public extension View {
  // By default, we simply pass the inputs through without modifications
  // or layout considerations.
  static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
    .init(inputs: inputs)
  }

  // By default, specify that we don't know how many children will exist.
  // This will prevent any `reserveCapacity` calls.
  static func _viewChildrenCount(_ inputs: ViewInputs<Self>) -> Int? {
    nil
  }
}

public extension ModifiedContent where Content: View, Modifier: ViewModifier {
  static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
    Modifier._makeView(.init(content: inputs.content.modifier, environment: inputs.environment))
  }

  func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    modifier._visitChildren(visitor, content: .init(modifier: modifier, view: content))
  }
}
