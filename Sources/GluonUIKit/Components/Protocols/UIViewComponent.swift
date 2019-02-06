//
//  UIKitViewComponent.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 02/12/2018.
//

import Gluon
import UIKit

protocol UIViewComponent: UIHostComponent, HostComponent {
  associatedtype Target: UIView & Default

  static func update(view box: ViewBox<Target>,
                     _ props: Props,
                     _ children: Children)

  static func box(
    for view: Target,
    _ viewController: UIViewController,
    _ component: UIKitRenderer.MountedHost,
    _ renderer: UIKitRenderer
  ) -> ViewBox<Target>
}

private func applyStyle<T: UIView, P: StyleProps>(_ target: ViewBox<T>,
                                                  _ props: P) {
  guard let style = props.style else {
    return
  }

  let view = target.view

  style.allowsEdgeAntialiasing.flatMap { view.layer.allowsEdgeAntialiasing = $0 }
  style.allowsGroupOpacity.flatMap { view.layer.allowsGroupOpacity = $0 }
  style.alpha.flatMap { view.alpha = CGFloat($0) }
  style.backgroundColor.flatMap { view.backgroundColor = UIColor($0) }
  style.borderColor.flatMap { view.layer.borderColor = UIColor($0).cgColor }
  style.borderWidth.flatMap { view.layer.borderWidth = CGFloat($0) }
  style.clipsToBounds.flatMap { view.clipsToBounds = $0 }
  style.cornerRadius.flatMap { view.layer.cornerRadius = CGFloat($0) }
  style.masksToBounds.flatMap { view.layer.masksToBounds = $0 }
  style.isDoubleSided.flatMap { view.layer.isDoubleSided = $0 }
  style.opacity.flatMap { view.layer.opacity = $0 }
  style.shadowColor.flatMap { view.layer.shadowColor = UIColor($0).cgColor }
  style.shadowOpacity.flatMap { view.layer.shadowOpacity = $0 }
  style.shadowRadius.flatMap { view.layer.shadowRadius = CGFloat($0) }

  switch style.layout {
  case let .frame(frame)?:
    view.frame = CGRect(frame)
  case let .constraints(constraints)?:
    view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.deactivate(target.constraints)
    target.constraints = Array(constraints.compactMap {
      view.constraint($0, next: nil)
    }.joined())
    NSLayoutConstraint.activate(target.constraints)
  case nil:
    ()
  }

  // center has to be updated after `frame`, otherwise `frame` overrides it
  style.center.flatMap { view.center = CGPoint($0) }
  style.isHidden.flatMap { view.isHidden = $0 }
}

extension UIViewComponent where Target == Target.DefaultValue,
  Props: StyleProps {
  static func box(
    for view: Target,
    _ viewController: UIViewController,
    _ component: UIKitRenderer.MountedHost,
    _: UIKitRenderer
  ) -> ViewBox<Target> {
    return ViewBox(view, viewController, component.node)
  }

  static func mountTarget(
    to parent: UITarget,
    component: UIKitRenderer.MountedHost,
    _ renderer: UIKitRenderer
  ) -> UITarget? {
    guard let children = component.node.children.value as? Children else {
      childrenAssertionFailure()
      return nil
    }

    guard let props = component.node.props.value as? Props else {
      propsAssertionFailure()
      return nil
    }

    let target = Target.defaultValue
    let result: ViewBox<Target>

    let parentRequiresViewController = parent.node?.isSubtypeOf(
      ModalPresenter.self, or: StackController.self, or: AnyTabPresenter.self
    ) ?? false

    // UIViewController parent target can't present a bare `ViewBox` target,
    // it needs to be wrapped with `ContainerViewController` first.
    if parentRequiresViewController {
      result = box(
        for: target,
        ContainerViewController(contained: target),
        component,
        renderer
      )
    } else {
      result = box(for: target, parent.viewController, component, renderer)
    }

    switch parent {
    case let box as ViewBox<GluonStackView>:
      box.view.addArrangedSubview(target)
    // no covariance/contravariance in Swift generics require next
    // two cases to be duplicated :(
    case let box as ViewBox<UIView>:
      box.view.addSubview(target)
    case let box as ViewBox<GluonView>:
      box.view.addSubview(target)
    case let box as ViewBox<GluonTableCell>:
      box.view.addSubview(target)
    case let box as ViewControllerBox<GluonNavigationController>
      where parent.node?.isSubtypeOf(StackController.self) ?? false:
      guard let props = parent.node?.props.value
        as? StackController.Props else {
        propsAssertionFailure()
        return nil
      }

      box.containerViewController.pushViewController(
        result.viewController,
        animated: props.pushAnimated
      )
    case let box as ViewControllerBox<UIViewController>
      where parent.node?.isSubtypeOf(ModalPresenter.self) ?? false:
      guard let props = parent.node?.props.value as? ModalPresenter.Props else {
        propsAssertionFailure()
        return nil
      }

      box.viewController.present(result.viewController,
                                 animated: props.presentAnimated,
                                 completion: nil)
    default:
      parentAssertionFailure()
    }

    applyStyle(result, props)
    update(view: result, props, children)

    return result
  }

  static func update(target: UITarget,
                     node: AnyNode) {
    guard let target = target as? ViewBox<Target> else {
      targetAssertionFailure()
      return
    }
    guard let children = node.children.value as? Children else {
      childrenAssertionFailure()
      return
    }
    guard let props = node.props.value as? Props else {
      propsAssertionFailure()
      return
    }

    applyStyle(target, props)

    update(view: target, props, children)
  }

  static func unmount(target: UITarget) {
    switch target {
    case let target as ViewBox<Target>:
      target.view.removeFromSuperview()
    default:
      targetAssertionFailure()
    }
  }
}
