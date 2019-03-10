//
//  Width.swift
//  TokamakAppKit
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import AppKit
import Tokamak

extension Width: OwnConstraint {
  var firstAnchor: KeyPath<Constrainable, NSLayoutDimension> {
    return \.widthAnchor
  }

  var secondAnchor: KeyPath<Constrainable, NSLayoutDimension> {
    return \.widthAnchor
  }
}
