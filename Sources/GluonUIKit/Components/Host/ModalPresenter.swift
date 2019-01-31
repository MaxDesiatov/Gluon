//
//  ModalPresenter.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 01/01/2019.
//

import Gluon
import UIKit

extension ModalPresenter: UIHostComponent {
  static func mountTarget(to parent: UITarget,
                          component: UIKitRenderer.MountedHost,
                          _: UIKitRenderer) -> UITarget? {
    return ViewControllerBox(parent.viewController, component.node)
  }

  static func update(target: UITarget,
                     node: AnyNode) {}

  static func unmount(target: UITarget) {
    target.viewController.dismiss(animated: true)
  }
}
