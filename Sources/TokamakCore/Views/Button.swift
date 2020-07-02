// Copyright 2018-2020 Tokamak contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Created by Max Desiatov on 02/12/2018.
//

/// A control that performs an action when triggered.
///
/// Available when `Label` conforms to `View`.
///
/// A button is created using a `Label`; the `action` initializer argument (a method or closure)
/// is to be called on click.
///
///     @State private var counter: Int = 0
///     var body: some View {
///       Button(action: { counter += 1 }) {
///         Text("\(counter)")
///       }
///     }
///
/// When your label is `Text`, you can create the button by directly passing a `String`:
///
///     @State private var counter: Int = 0
///     var body: some View {
///       Button("\(counter)", action: { counter += 1 })
///     }
public struct Button<Label>: View where Label: View {
  let label: Label

  let action: () -> ()

  public init(action: @escaping () -> (), @ViewBuilder label: () -> Label) {
    self.label = label()
    self.action = action
  }

  public var body: Never {
    neverBody("Text")
  }
}

extension Button where Label == Text {
  public init<S>(_ title: S, action: @escaping () -> ()) where S: StringProtocol {
    self.init(action: action) {
      Text(title)
    }
  }
}

extension Button: ParentView {
  public var children: [AnyView] {
    (label as? GroupView)?.children ?? [AnyView(label)]
  }
}

/// This is a helper class that works around absence of "package private" access control in Swift
public struct _ButtonProxy {
  public let subject: Button<Text>

  public init(_ subject: Button<Text>) { self.subject = subject }

  public var label: _TextProxy { _TextProxy(subject.label) }
  public var action: () -> () { subject.action }
}
