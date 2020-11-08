// Copyright 2020 Tokamak contributors
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
//  Created by Max Desiatov on 11/04/2020.
//

import JavaScriptKit
import TokamakCore
import TokamakStaticHTML

extension EnvironmentValues {
  /// Returns default settings for the DOM environment
  static var defaultEnvironment: Self {
    var environment = EnvironmentValues()
    environment[_ToggleStyleKey] = _AnyToggleStyle(DefaultToggleStyle())
    environment[_ColorSchemeKey] = .init(matchMediaDarkScheme: matchMediaDarkScheme)
    environment._defaultAppStorage = LocalStorage.standard
    _DefaultSceneStorageProvider.default = SessionStorage.standard

    return environment
  }
}

/** `SpacerContainer` is part of TokamakDOM, as not all renderers will handle flexible
 sizing the way browsers do. Their parent element could already know that if a child is
 requesting full width, then it needs to expand.
 */
private extension AnyView {
  var axes: [SpacerContainerAxis] {
    var axes = [SpacerContainerAxis]()
    if let spacerContainer = mapAnyView(self, transform: { (v: SpacerContainer) in v }) {
      if spacerContainer.hasSpacer {
        axes.append(spacerContainer.axis)
      }
      if spacerContainer.fillCrossAxis {
        axes.append(spacerContainer.axis == .horizontal ? .vertical : .horizontal)
      }
    }
    return axes
  }

  var fillAxes: [SpacerContainerAxis] {
    children.flatMap(\.fillAxes) + axes
  }
}

let global = JSObject.global
let window = global.window.object!
let matchMediaDarkScheme = window.matchMedia!("(prefers-color-scheme: dark)").object!
let log = global.console.object!.log.function!
let document = global.document.object!
let body = document.body.object!
let head = document.head.object!

func appendRootStyle(_ rootNode: JSObject) {
  rootNode.style = .string(rootNodeStyles)
  let rootStyle = document.createElement!("style").object!
  rootStyle.innerHTML = .string(tokamakStyles)
  _ = head.appendChild!(rootStyle)
}

final class DOMRenderer: Renderer {
  private(set) var reconciler: StackReconciler<DOMRenderer>?

  private let rootRef: JSObject

  private let scheduler: JSScheduler

  init<A: App>(_ app: A, _ ref: JSObject, _ rootEnvironment: EnvironmentValues? = nil) {
    rootRef = ref
    appendRootStyle(ref)

    let scheduler = JSScheduler()
    self.scheduler = scheduler
    reconciler = StackReconciler(
      app: app,
      target: DOMNode(ref),
      environment: .defaultEnvironment,
      renderer: self
    ) { scheduler.schedule(options: nil, $0) }
  }

  public func mountTarget(to parent: DOMNode, with host: MountedHost) -> DOMNode? {
    guard let anyHTML = mapAnyView(
      host.view,
      transform: { (html: AnyHTML) in html }
    ) else {
      // handle cases like `TupleView`
      if mapAnyView(host.view, transform: { (view: ParentView) in view }) != nil {
        return parent
      }

      return nil
    }

    _ = parent.ref.insertAdjacentHTML!("beforeend", JSValue(stringLiteral: anyHTML.outerHTML))

    guard
      let children = parent.ref.childNodes.object,
      let length = children.length.number,
      length > 0,
      let lastChild = children[Int(length) - 1].object
    else { return nil }

    let fillAxes = host.view.fillAxes
    if fillAxes.contains(.horizontal) {
      lastChild.style.object!.width = "100%"
    }
    if fillAxes.contains(.vertical) {
      lastChild.style.object!.height = "100%"
    }

    if let dynamicHTML = anyHTML as? AnyDynamicHTML {
      return DOMNode(host.view, lastChild, dynamicHTML.listeners)
    } else {
      return DOMNode(host.view, lastChild, [:])
    }
  }

  func update(target: DOMNode, with host: MountedHost) {
    guard let html = mapAnyView(host.view, transform: { (html: AnyHTML) in html })
    else { return }

    html.update(dom: target)
  }

  func unmount(
    target: DOMNode,
    from parent: DOMNode,
    with host: MountedHost,
    completion: @escaping () -> ()
  ) {
    defer { completion() }

    guard mapAnyView(host.view, transform: { (html: AnyHTML) in html }) != nil
    else { return }

    _ = parent.ref.removeChild!(target.ref)
  }
}
