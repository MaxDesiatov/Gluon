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
//  Created by Carson Katri on 2/15/22.
//

import Foundation

@_spi(TokamakCore)
public extension FiberReconciler {
  /// A manager for a single `View`.
  ///
  /// There are always 2 `Fiber`s for every `View` in the tree,
  /// a current `Fiber`, and a work in progress `Fiber`.
  /// They point to each other using the `alternate` property.
  ///
  /// The current `Fiber` represents the `View` as it is currently rendered on the screen.
  /// The work in progress `Fiber` (the `alternate` of current),
  /// is used in the reconciler to compute the new tree.
  ///
  /// When reconciling, the tree is recomputed from
  /// the root of the state change on the work in progress `Fiber`.
  /// Each node in the fiber tree is updated to apply any changes,
  /// and a list of mutations needed to get the rendered output to match is created.
  ///
  /// After the entire tree has been traversed, the current and work in progress trees are swapped,
  /// making the updated tree the current one,
  /// and leaving the previous current tree available to apply future changes on.
  final class Fiber {
    weak var reconciler: FiberReconciler<Renderer>?

    /// The underlying value behind this `Fiber`. Either a `Scene` or `View` instance.
    ///
    /// Stored as an IUO because it uses `bindProperties` to create the underlying instance,
    /// and captures a weak reference to `self` in the visitor function,
    /// which requires all stored properties be set before capturing.
    @_spi(TokamakCore)
    public var content: Content!
    /// Outputs from evaluating `View._makeView`
    ///
    /// Stored as an IUO because creating `ViewOutputs` depends on
    /// the `bindProperties` method, which requires
    /// all stored properties be set before using.
    /// `outputs` is guaranteed to be set in the initializer.
    var outputs: ViewOutputs!
    /// The identity of this `View`
    var id: Identity?
    /// The mounted element, if this is a Renderer primitive.
    var element: Renderer.ElementType?
    /// The index of this element in its elementParent
    var elementIndex: Int?
    /// The first child node.
    @_spi(TokamakCore)
    public var child: Fiber?
    /// This node's right sibling.
    @_spi(TokamakCore)
    public var sibling: Fiber?
    /// An unowned reference to the parent node.
    ///
    /// Parent references are `unowned` (as opposed to `weak`)
    /// because the parent will always exist if a child does.
    /// If the parent is released, the child is released with it.
    unowned var parent: Fiber?
    /// The nearest parent that can be mounted on.
    unowned var elementParent: Fiber?
    /// The cached type information for the underlying `View`.
    var typeInfo: TypeInfo?
    /// Boxes that store `State` data.
    var state: [PropertyInfo: MutableStorage] = [:]

    /// The computed dimensions and origin.
    var geometry: ViewGeometry?

    /// The WIP node if this is current, or the current node if this is WIP.
    weak var alternate: Fiber?

    var createAndBindAlternate: (() -> Fiber?)?

    /// A box holding a value for an `@State` property wrapper.
    /// Will call `onSet` (usually a `Reconciler.reconcile` call) when updated.
    final class MutableStorage {
      private(set) var value: Any
      let onSet: () -> ()

      func setValue(_ newValue: Any, with transaction: Transaction) {
        value = newValue
        onSet()
      }

      init(initialValue: Any, onSet: @escaping () -> ()) {
        value = initialValue
        self.onSet = onSet
      }
    }

    public enum Identity: Hashable {
      case explicit(AnyHashable)
      case structural(index: Int)
    }

    init<V: View>(
      _ view: inout V,
      element: Renderer.ElementType?,
      parent: Fiber?,
      elementParent: Fiber?,
      elementIndex: Int?,
      reconciler: FiberReconciler<Renderer>?
    ) {
      self.reconciler = reconciler
      child = nil
      sibling = nil
      self.parent = parent
      self.elementParent = elementParent
      typeInfo = TokamakCore.typeInfo(of: V.self)

      let environment = parent?.outputs.environment ?? .init(.init())
      state = bindProperties(to: &view, typeInfo, environment.environment)
      outputs = V._makeView(
        .init(
          content: view,
          environment: environment
        )
      )

      content = content(for: view)

      if let element = element {
        self.element = element
      } else if Renderer.isPrimitive(view) {
        self.element = .init(
          from: .init(from: view, useDynamicLayout: reconciler?.renderer.useDynamicLayout ?? false)
        )
      }

      // Only specify an `elementIndex` if we have an element.
      if self.element != nil {
        self.elementIndex = elementIndex
      }

      let alternateView = view
      createAndBindAlternate = { [weak self] in
        guard let self = self else { return nil }
        // Create the alternate lazily
        let alternate = Fiber(
          bound: alternateView,
          alternate: self,
          outputs: self.outputs,
          typeInfo: self.typeInfo,
          element: self.element,
          parent: self.parent?.alternate,
          elementParent: self.elementParent?.alternate,
          reconciler: reconciler
        )
        self.alternate = alternate
        if self.parent?.child === self {
          self.parent?.alternate?.child = alternate // Link it with our parent's alternate.
        } else {
          // Find our left sibling.
          var node = self.parent?.child
          while node?.sibling !== self {
            guard node?.sibling != nil else { return alternate }
            node = node?.sibling
          }
          if node?.sibling === self {
            node?.alternate?.sibling = alternate // Link it with our left sibling's alternate.
          }
        }
        return alternate
      }
    }

    init<V: View>(
      bound view: V,
      alternate: Fiber,
      outputs: ViewOutputs,
      typeInfo: TypeInfo?,
      element: Renderer.ElementType?,
      parent: FiberReconciler<Renderer>.Fiber?,
      elementParent: Fiber?,
      reconciler: FiberReconciler<Renderer>?
    ) {
      self.alternate = alternate
      self.reconciler = reconciler
      self.element = element
      child = nil
      sibling = nil
      self.parent = parent
      self.elementParent = elementParent
      self.typeInfo = typeInfo
      self.outputs = outputs
      content = content(for: view)
    }

    private func bindProperties<T>(
      to content: inout T,
      _ typeInfo: TypeInfo?,
      _ environment: EnvironmentValues
    ) -> [PropertyInfo: MutableStorage] {
      guard let typeInfo = typeInfo else { return [:] }

      var state: [PropertyInfo: MutableStorage] = [:]
      for property in typeInfo.properties where property.type is DynamicProperty.Type {
        var value = property.get(from: content)
        if var storage = value as? WritableValueStorage {
          let box = MutableStorage(initialValue: storage.anyInitialValue, onSet: { [weak self] in
            guard let self = self else { return }
            self.reconciler?.reconcile(from: self)
          })
          state[property] = box
          storage.getter = { box.value }
          storage.setter = { box.setValue($0, with: $1) }
          value = storage
        } else if var environmentReader = value as? EnvironmentReader {
          environmentReader.setContent(from: environment)
          value = environmentReader
        }
        property.set(value: value, on: &content)
      }
      if var environmentReader = content as? EnvironmentReader {
        environmentReader.setContent(from: environment)
        // swiftlint:disable:next force_cast
        content = environmentReader as! T
      }
      return state
    }

    func update<V: View>(
      with view: inout V,
      elementIndex: Int?
    ) -> Renderer.ElementType.Content? {
      typeInfo = TokamakCore.typeInfo(of: V.self)

      self.elementIndex = elementIndex

      let environment = parent?.outputs.environment ?? .init(.init())
      state = bindProperties(to: &view, typeInfo, environment.environment)
      content = content(for: view)
      outputs = V._makeView(.init(
        content: view,
        environment: environment
      ))

      if Renderer.isPrimitive(view) {
        return .init(from: view, useDynamicLayout: reconciler?.renderer.useDynamicLayout ?? false)
      } else {
        return nil
      }
    }

    init<A: App>(
      _ app: inout A,
      rootElement: Renderer.ElementType,
      rootEnvironment: EnvironmentValues,
      reconciler: FiberReconciler<Renderer>
    ) {
      self.reconciler = reconciler
      child = nil
      sibling = nil
      // `App`s are always the root, so they can have no parent.
      parent = nil
      elementParent = nil
      element = rootElement
      typeInfo = TokamakCore.typeInfo(of: A.self)

      state = bindProperties(to: &app, typeInfo, rootEnvironment)
      outputs = .init(
        inputs: .init(content: app, environment: .init(rootEnvironment)),
        layoutComputer: RootLayoutComputer.init
      )

      content = content(for: app)

      let alternateApp = app
      createAndBindAlternate = { [weak self] in
        guard let self = self else { return nil }
        // Create the alternate lazily
        let alternate = Fiber(
          bound: alternateApp,
          alternate: self,
          outputs: self.outputs,
          typeInfo: self.typeInfo,
          element: self.element,
          reconciler: reconciler
        )
        self.alternate = alternate
        return alternate
      }
    }

    init<A: App>(
      bound app: A,
      alternate: Fiber,
      outputs: SceneOutputs,
      typeInfo: TypeInfo?,
      element: Renderer.ElementType?,
      reconciler: FiberReconciler<Renderer>?
    ) {
      self.alternate = alternate
      self.reconciler = reconciler
      self.element = element
      child = nil
      sibling = nil
      parent = nil
      elementParent = nil
      self.typeInfo = typeInfo
      self.outputs = outputs
      content = content(for: app)
    }

    init<S: Scene>(
      _ scene: inout S,
      element: Renderer.ElementType?,
      parent: Fiber?,
      elementParent: Fiber?,
      environment: EnvironmentBox?,
      reconciler: FiberReconciler<Renderer>?
    ) {
      self.reconciler = reconciler
      child = nil
      sibling = nil
      self.parent = parent
      self.elementParent = elementParent
      self.element = element
      typeInfo = TokamakCore.typeInfo(of: S.self)

      let environment = environment ?? parent?.outputs.environment ?? .init(.init())
      state = bindProperties(to: &scene, typeInfo, environment.environment)
      outputs = S._makeScene(
        .init(
          content: scene,
          environment: environment
        )
      )

      content = content(for: scene)

      let alternateScene = scene
      createAndBindAlternate = { [weak self] in
        guard let self = self else { return nil }
        // Create the alternate lazily
        let alternate = Fiber(
          bound: alternateScene,
          alternate: self,
          outputs: self.outputs,
          typeInfo: self.typeInfo,
          element: self.element,
          parent: self.parent?.alternate,
          elementParent: self.elementParent?.alternate,
          reconciler: reconciler
        )
        self.alternate = alternate
        if self.parent?.child === self {
          self.parent?.alternate?.child = alternate // Link it with our parent's alternate.
        } else {
          // Find our left sibling.
          var node = self.parent?.child
          while node?.sibling !== self {
            guard node?.sibling != nil else { return alternate }
            node = node?.sibling
          }
          if node?.sibling === self {
            node?.alternate?.sibling = alternate // Link it with our left sibling's alternate.
          }
        }
        return alternate
      }
    }

    init<S: Scene>(
      bound scene: S,
      alternate: Fiber,
      outputs: SceneOutputs,
      typeInfo: TypeInfo?,
      element: Renderer.ElementType?,
      parent: FiberReconciler<Renderer>.Fiber?,
      elementParent: Fiber?,
      reconciler: FiberReconciler<Renderer>?
    ) {
      self.alternate = alternate
      self.reconciler = reconciler
      self.element = element
      child = nil
      sibling = nil
      self.parent = parent
      self.elementParent = elementParent
      self.typeInfo = typeInfo
      self.outputs = outputs
      content = content(for: scene)
    }

    func update<S: Scene>(
      with scene: inout S
    ) -> Renderer.ElementType.Content? {
      typeInfo = TokamakCore.typeInfo(of: S.self)

      let environment = parent?.outputs.environment ?? .init(.init())
      state = bindProperties(to: &scene, typeInfo, environment.environment)
      content = content(for: scene)
      outputs = S._makeScene(.init(
        content: scene,
        environment: environment
      ))

      return nil
    }
  }
}
