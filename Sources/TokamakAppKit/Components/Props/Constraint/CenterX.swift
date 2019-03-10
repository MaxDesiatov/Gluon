//
//  CenterX.swift
//  TokamakAppKit
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import AppKit
import Tokamak

extension CenterX: XAxisConstraint {
  var firstAnchor: KeyPath<Constrainable, NSLayoutXAxisAnchor> {
    return \.centerXAnchor
  }

  var secondAnchor: KeyPath<Constrainable, NSLayoutXAxisAnchor> {
    return \.centerXAnchor
  }
}
