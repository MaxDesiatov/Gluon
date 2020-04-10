//
//  StackReconciler.swift
//  Tokamak
//
//  Created by Max Desiatov on 28/11/2018.
//

import Dispatch

public final class StackReconciler<R: Renderer> {
  private var queuedRerenders = Set<MountedCompositeComponent<R>>()

  public let rootTarget: R.TargetType
  private let rootComponent: MountedComponent<R>
  private(set) weak var renderer: R?

  public init<V: View>(node: V, target: R.TargetType, renderer: R) {
    self.renderer = renderer
    rootTarget = target

    rootComponent = node.makeMountedComponent(target)

    rootComponent.mount(with: self)
  }

  func queue(updater: (inout Any) -> (),
             for component: MountedCompositeComponent<R>,
             id: Int) {
    let scheduleReconcile = queuedRerenders.isEmpty

    updater(&component.state[id])
    queuedRerenders.insert(component)

    guard scheduleReconcile else { return }

    DispatchQueue.main.async {
      self.updateStateAndReconcile()
    }
  }

  private func updateStateAndReconcile() {
    for component in queuedRerenders {
      component.update(with: self)
    }

    queuedRerenders.removeAll()
  }

  func render(component: MountedCompositeComponent<R>) -> some View {
    // Avoiding an indirect reference cycle here: this closure can be
    // owned by callbacks owned by node's target, which is strongly referenced
    // by the reconciler.
    let hooks = Hooks(
      component: component
    ) { [weak self, weak component] id, updater in
      guard let component = component else { return }
      self?.queue(updater: updater, for: component, id: id)
    }

    let states = Mirror(reflecting: component.node.view).children
      .compactMap { $0.value as? ValueStorage }

    for (i, state) in states.enumerated() {
      if component.state.count == i {
        component.state.append(state.anyInitialValue)
      }

//        state.getter = { component.state[i] }
//        state.setter = { component.state[i] = $0 }
    }

    let result = component.node.bodyClosure()

    // clean up `component` reference to enable assertions when hooks are called
    // outside of `render`
    hooks.component = nil

    return result
  }
}
