//
//  Scroll.swift
//  TokamakDemo
//
//  Created by Matvii Hodovaniuk on 2/28/19.
//  Copyright © 2019 Tokamak. Tokamak is available under the Apache 2.0
//  license. See the LICENSE file for more info.
//

import Tokamak

struct ScrollViewExample: LeafComponent {
  typealias Props = Null

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    return View.node(
      .init(Style(Edges.equal(to: .safeArea))),
      ScrollView.node(
        .init(Style(Edges.equal(to: .parent))),
        StackView.node(
          .init(
            Edges.equal(to: .parent),
            axis: .vertical,
            distribution: .fill
          ),
          (1..<100).map { Label.node(.init(text: "Text \($0)")) }
        )
      )
    )
  }
}
