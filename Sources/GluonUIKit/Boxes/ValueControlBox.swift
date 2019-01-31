//
//  ValueControlBox.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 01/01/2019.
//

import Gluon
import UIKit

protocol ValueStorage: class {
  associatedtype Value

  var value: Value { get set }
}

final class ValueControlBox<T: UIControl & Default & ValueStorage>:
  ControlBox<T> {
  private var valueChangedAction: Action?

  var value: T.Value {
    get {
      return view.value
    }
    set {
      view.value = newValue
    }
  }

  func bind(valueChangedHandler: Handler<T.Value>?) {
    if let existing = self.valueChangedAction {
      view.removeTarget(existing, action: actionSelector, for: .valueChanged)
      valueChangedAction = nil
    }

    if let handler = valueChangedHandler {
      // The closure is owned by the `view`, which is owned by `self`.
      let action = Action { [weak self] in
        guard let self = self else { return }
        handler.value(self.view.value)
      }

      view.addTarget(action, action: actionSelector, for: .valueChanged)
      valueChangedAction = action
    }
  }
}
