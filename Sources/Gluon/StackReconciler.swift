//
//  StackReconciler.swift
//  Gluon
//
//  Created by Max Desiatov on 28/11/2018.
//

import Dispatch

public final class StackReconciler<R: Renderer> {
  private var queuedRerenders = Set<MountedCompositeComponent<R>>()

  public let rootTarget: R.TargetType
  private let rootComponent: MountedComponent<R>
  private(set) weak var renderer: R?

  public init(node: AnyNode, target: R.TargetType, renderer: R) {
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

  func render(component: MountedCompositeComponent<R>) -> AnyNode {
    // Avoiding an indirect reference cycle here: this closure can be
    // owned by callbacks owned by node's target, which is strongly referenced
    // by the reconciler.
    let hooks = Hooks(
      component: component
    ) { [weak self, weak component] id, updater in
      guard let component = component else { return }
      self?.queue(updater: updater, for: component, id: id)
    }

    let result = component.type.render(
      props: component.node.props,
      children: component.node.children,
      hooks: hooks
    )

    DispatchQueue.main.async {
      for i in hooks.scheduledEffects {
        component.effectFinalizers[i]?()
        component.effectFinalizers[i] = component.effects[i].1()
      }
    }

    // clean up `component` reference to enable assertions when hooks are called
    // outside of `render`
    hooks.component = nil

    return result
  }
}
