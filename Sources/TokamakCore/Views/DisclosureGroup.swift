// Copyright 2020 Tokamak contributors
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
//  Created by Carson Katri on 7/3/20.
//

public struct DisclosureGroup<Label, Content>: View
  where Label: View, Content: View {
  @State public var isExpanded: Bool = false
  public var isExpandedBinding: Binding<Bool>?

  @Environment(\._outlineGroupStyle) var style: _OutlineGroupStyle

  let label: Label
  let content: () -> Content

  public init(@ViewBuilder content: @escaping () -> Content,
              @ViewBuilder label: () -> Label) {
    self.label = label()
    self.content = content
  }

  public init(isExpanded: Binding<Bool>,
              @ViewBuilder content: @escaping () -> Content,
              @ViewBuilder label: () -> Label) {
    isExpandedBinding = isExpanded
    self.label = label()
    self.content = content
  }

  public var body: Never {
    neverBody("DisclosureGroup")
  }
}

extension DisclosureGroup where Label == Text {
  // FIXME: Implement LocalizedStringKey
//  public init(_ titleKey: LocalizedStringKey,
//              @ViewBuilder content: @escaping () -> Content)
//  public init(_ titleKey: SwiftUI.LocalizedStringKey,
//              isExpanded: SwiftUI.Binding<Swift.Bool>,
//              @SwiftUI.ViewBuilder content: @escaping () -> Content)

  @_disfavoredOverload public init<S>(_ label: S,
                                      @ViewBuilder content: @escaping () -> Content)
    where S: StringProtocol {
    self.init(content: content, label: { Text(label) })
  }

  @_disfavoredOverload public init<S>(_ label: S,
                                      isExpanded: Binding<Bool>,
                                      @ViewBuilder content: @escaping () -> Content)
    where S: StringProtocol {
    self.init(isExpanded: isExpanded, content: content, label: { Text(label) })
  }
}

public struct _DisclosureGroupProxy<Label, Content>
  where Label: View, Content: View {
  public var subject: DisclosureGroup<Label, Content>

  public init(_ subject: DisclosureGroup<Label, Content>) { self.subject = subject }

  public var label: Label { subject.label }
  public var content: () -> Content { subject.content }
  public var style: _OutlineGroupStyle { subject.style }
}
