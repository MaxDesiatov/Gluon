//
//  ListView.swift
//  Gluon
//
//  Created by Max Desiatov on 26/01/2019.
//

import Gluon
import UIKit

extension ListView: UIViewComponent {
  static func box(
    for view: Target,
    _ viewController: UIViewController,
    _ component: UIKitRenderer.Component
  ) -> ViewBox<GluonTableView> {
    guard let props = component.node.props.value as? Props else {
      fatalError("incorrect props type stored in ListView node")
    }

    return TableViewBox<T>(view, viewController, component, props)
  }

  static func update(view box: ViewBox<GluonTableView>,
                     _ props: ListView.Props,
                     _ children: Null) {
    guard let box = box as? TableViewBox<T> else {
      boxAssertionFailure("box")
      return
    }

    box.dataSource.props = props
  }
}
