// Copyright 2018-2020 Tokamak contributors
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
//  Created by Max Desiatov on 28/11/2018.
//

import Runtime

public class MountedView<R: Renderer> {
  public internal(set) var view: AnyView

  init(_ view: AnyView) {
    self.view = view
  }

  func mount(with reconciler: StackReconciler<R>) {
    fatalError("implement \(#function) in subclass")
  }

  func unmount(with reconciler: StackReconciler<R>) {
    fatalError("implement \(#function) in subclass")
  }

  func update(with reconciler: StackReconciler<R>) {
    fatalError("implement \(#function) in subclass")
  }
}

extension View {
  func makeMountedView<R: Renderer>(_ parentTarget: R.TargetType,
                                    _ environmentValues: EnvironmentValues)
    -> MountedView<R> {
    // Find Environment changes
    var modifiedEnv = environmentValues
    var injectableView = self
    let any = (injectableView as? AnyView) ?? AnyView(injectableView)
    // swiftlint:disable force_try
    // Extract the view from the AnyView for modification
    var extractedView = any.view
    let viewInfo = try! typeInfo(of: any.type)
    if viewInfo
      .genericTypes
      .filter({ $0 is EnvironmentModifier.Type }).count > 0 {
      // Apply Environment changes:
      if let modifier = try? viewInfo
        .property(named: "modifier")
        .get(from: any.view) as? EnvironmentModifier {
        modifier.modifyEnvironment(&modifiedEnv)
      }
    }

    // Inject @Environment values
    for prop in viewInfo.properties.filter({ $0.type is EnvironmentReader.Type }) {
      // swiftlint:disable force_cast
      var wrapper = try! prop.get(from: any.view) as! EnvironmentReader
      wrapper.setContent(from: modifiedEnv)
      try! prop.set(value: wrapper, on: &extractedView)
      // swiftlint:enable force_cast
    }

    // Set the extractedView back on the AnyView after modification
    let anyViewInfo = try! typeInfo(of: AnyView.self)
    try! anyViewInfo.property(named: "view").set(value: extractedView, on: &injectableView)
    // swiftlint:enable force_try

    // Make MountedView
    let anyView = injectableView as? AnyView ?? AnyView(injectableView)
    if anyView.type == EmptyView.self {
      return MountedNull(anyView)
    } else if anyView.bodyType == Never.self && !(anyView.type is ViewDeferredToRenderer.Type) {
      return MountedHostView(anyView, parentTarget, modifiedEnv)
    } else {
      return MountedCompositeView(anyView, parentTarget, modifiedEnv)
    }
  }
}
