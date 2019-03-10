//
//  Left.swift
//  TokamakAppKit
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import AppKit
import Tokamak

extension Left: XAxisConstraint {
  var firstAnchor: KeyPath<Constrainable, NSLayoutXAxisAnchor> {
    return \.leftAnchor
  }

  var secondAnchor: KeyPath<Constrainable, NSLayoutXAxisAnchor> {
    return \.leftAnchor
  }
}
