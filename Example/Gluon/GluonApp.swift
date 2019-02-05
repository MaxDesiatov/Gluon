//
//  GluonApp.swift
//  Gluon_Example
//
//  Created by Max Desiatov on 31/12/2018.
//  Copyright © 2018 Max Desiatov. All rights reserved.
//

import Gluon

struct StackModal: PureLeafComponent {
  struct Props: Equatable {
    let isPresented: State<Bool>
  }

  static func render(props: Props) -> AnyNode {
    return props.isPresented.value ?
      ModalPresenter.node(
        StackPresenter<NavRouter>.node(
          .init(
            initial: .first,
            routerProps: .init(
              onPress: Handler { props.isPresented.set(false) }
            )
          )
        )
      ) : Null.node()
  }
}

struct SimpleModal: LeafComponent {
  struct Props: Equatable {
    let isPresented: State<Bool>
  }

  private static let colors: [(Color, String)] = [
    (.white, "white"),
    (.red, "red"),
    (.green, "green"),
    (.blue, "blue"),
  ]

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let backgroundColor = hooks.state(0)

    return props.isPresented.value ? ModalPresenter.node(
      View.node(.init(Style(backgroundColor: colors[backgroundColor.value].0)),
                StackView.node(.init(
                  axis: .vertical,
                  distribution: .fillEqually,
                  Style(Edges.equal(to: .parent))
                ), [
                  Button.node(.init(
                    onPress: Handler { props.isPresented.set(false) }
                  ), "Close Modal"),
                  SegmentedControl.node(
                    .init(value: backgroundColor.value,
                          valueHandler: Handler(backgroundColor.set)),
                    colors.map { $0.1 }
                  ),
      ]))
    ) : Null.node()
  }
}

struct ListProvider: SimpleCellProvider {
  typealias Props = Null
  typealias Model = [[Int]]

  static func cell(props _: Null, item: Int, path _: CellPath) -> AnyNode {
    return Label.node(.init(Style(Edges.equal(to: .parent))), "\(item)")
  }
}

struct TableModal: PureLeafComponent {
  struct Props: Equatable {
    let isPresented: State<Bool>
  }

  static func render(props: Props) -> AnyNode {
    let list = ListView<ListProvider>.node(.init(singleSection: [1, 2, 3]))
    return props.isPresented.value ? ModalPresenter.node(list) : Null.node()
  }
}

struct ConstrainModal: LeafComponent {
  struct Props: Equatable {
    let isPresented: State<Bool>
  }

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let left = hooks.state(0.5 as Float)

    return props.isPresented.value ? ModalPresenter.node(
      View.node(
        .init(Style(backgroundColor: .white)),
        StackView.node(.init(
          axis: .vertical,
          distribution: .fillEqually,
          Style(Edges.equal(to: .parent))
        ), [
          Button.node(.init(
            onPress: Handler { props.isPresented.set(false) }
          ), "Close Modal"),
          Slider.node(.init(
            value: left.value,
            valueHandler: Handler(left.set),
            Style(Width.equal(to: .parent))
          )),

          View.node(
            .init(Style(backgroundColor: .red)),
            Label.node(.init(
              alignment: .center,
              textColor: .white,
              Style(Left.equal(to: .parent, constant: Double(left.value) * 200))
            ), "\(left.value)")
          ),
        ])
      )
    ) : Null.node()
  }
}

struct DatePickerModal: LeafComponent {
  struct Props: Equatable {
    let isPresented: State<Bool>
  }

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let currentDateTime = Date()
    let date = hooks.state(currentDateTime)
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    let formattedDate = dateFormatter.string(from: date.value)
    return props.isPresented.value ? ModalPresenter.node(
      View.node(
        .init(Style(backgroundColor: .white)),
        StackView.node(.init(
          axis: .vertical,
          distribution: .fillEqually,
          Style(Edges.equal(to: .parent))
        ), [
          Button.node(.init(
            onPress: Handler { props.isPresented.set(false) }
          ), "Close Modal"),
          Label.node(
            .init(alignment: .center),
            "\(formattedDate)"
          ),
          DatePicker.node(
            .init(
              value: date.value,
              valueHandler: Handler(date.set),
              Style(Width.equal(to: .parent))
            )
          ),
          DatePicker.node(
            .init(
              isAnimated: false,
              value: date.value,
              valueHandler: Handler(date.set),
              Style(Width.equal(to: .parent))
            )
          ),
        ])
      )
    ) : Null.node()
  }
}

struct Counter: LeafComponent {
  struct Props: Equatable {
    let initial: Int
  }

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let count = hooks.state(props.initial)
    let sliding = hooks.state(0.5 as Float)
    let isStackModalPresented = hooks.state(false)
    let isAnimationModalPresented = hooks.state(false)
    let isTableModalPresented = hooks.state(false)
    let isConstrainModalPresented = hooks.state(false)
    let isDatePickerModalPresented = hooks.state(false)
    let switchState = hooks.state(true)
    let stepperState = hooks.state(0.0)
    let isEnabled = hooks.state(true)

    let children = [
      StackView.node(
        .init(
          alignment: .center,
          axis: .horizontal,
          spacing: 10.0
        ), [
          Switch.node(
            .init(
              value: isEnabled.value,
              valueHandler: Handler(isEnabled.set)
            )
          ),

          Label.node(
            .init(alignment: .center),
            "isEnabled \(isEnabled.value)"
          ),
        ]
      ),

      Button.node(
        .init(
          isEnabled: isEnabled.value,
          onPress: Handler { isStackModalPresented.set(true) }
        ),
        "Present Stack Modal"
      ),

      Button.node(
        .init(
          isEnabled: isEnabled.value,
          onPress: Handler { isAnimationModalPresented.set(true) }
        ),
        "Present Simple Modal"
      ),

      Button.node(
        .init(
          isEnabled: isEnabled.value,
          onPress: Handler { isTableModalPresented.set(true) }
        ),
        "Present Table Modal"
      ),

      Button.node(
        .init(
          isEnabled: isEnabled.value,
          onPress: Handler { isConstrainModalPresented.set(true) }
        ),
        "Present Constrain Modal"
      ),

      Button.node(
        .init(
          isEnabled: isEnabled.value,
          onPress: Handler { isDatePickerModalPresented.set(true) }
        ),
        "Present DatePicker Modal"
      ),

      StackModal.node(.init(isPresented: isStackModalPresented)),

      SimpleModal.node(.init(isPresented: isAnimationModalPresented)),

      TableModal.node(.init(isPresented: isTableModalPresented)),

      ConstrainModal.node(.init(isPresented: isConstrainModalPresented)),

      DatePickerModal.node(.init(isPresented: isDatePickerModalPresented)),
    ] + (count.value < 15 ? [
      StackView.node(
        .init(
          alignment: .center,
          axis: .horizontal,
          spacing: 10.0
        ), [
          Button.node(
            .init(
              isEnabled: isEnabled.value,
              onPress: Handler { count.set { $0 + 1 } }
            ),
            "Increment"
          ),

          Label.node(.init(alignment: .center), "\(count.value)"),
        ]
      ),

      Slider.node(.init(
        isEnabled: isEnabled.value,
        value: sliding.value,
        valueHandler: Handler(sliding.set),
        Style(Width.equal(to: .parent))
      )),

      Label.node(.init(alignment: .center), "\(sliding.value)"),

      StackView.node(
        .init(
          alignment: .center,
          axis: .horizontal,
          spacing: 10.0
        ), [
          Switch.node(
            .init(
              isEnabled: isEnabled.value,
              value: switchState.value,
              valueHandler: Handler(switchState.set)
            )
          ),

          Label.node(.init(alignment: .center), "\(switchState.value)"),
        ]
      ),

      StackView.node(
        .init(
          alignment: .center,
          axis: .horizontal,
          spacing: 10.0
        ), [
          Stepper.node(
            .init(
              isEnabled: isEnabled.value,
              value: stepperState.value,
              valueHandler: Handler(stepperState.set)
            )
          ),

          Label.node(.init(alignment: .center), "\(stepperState.value)"),
        ]
      ),
    ] : [])

    return StackView.node(
      .init(
        alignment: .center,
        axis: .vertical,
        distribution: .fillEqually,
        Style(Edges.equal(to: .parent))
      ),
      children
    )
  }
}

struct App: PureLeafComponent {
  typealias Props = Null

  static func render(props _: Props) -> AnyNode {
    return Counter.node(.init(initial: 1))
  }
}
