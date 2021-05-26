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

protocol ModifierContainer {
  var environmentModifier: EnvironmentModifier? { get }
}

/// A value with a modifier applied to it.
public struct ModifiedContent<Content, Modifier> {
  @Environment(\.self) public var environment
  public typealias Body = Never
  public private(set) var content: Content
  public private(set) var modifier: Modifier

  public init(content: Content, modifier: Modifier) {
    self.content = content
    self.modifier = modifier
  }
}

extension ModifiedContent: ModifierContainer {
  var environmentModifier: EnvironmentModifier? { modifier as? EnvironmentModifier }
}

extension ModifiedContent: EnvironmentReader where Modifier: EnvironmentReader {
  mutating func setContent(from values: EnvironmentValues) {
    modifier.setContent(from: values)
  }
}

extension ModifiedContent: View, ParentView where Content: View, Modifier: ViewModifier {
  public var body: Body {
    neverBody("ModifiedContent<View, ViewModifier>")
  }

  public var children: [AnyView] {
    [AnyView(content)]
  }
}

extension ModifiedContent: BuiltinView where Content: View, Modifier: ViewModifier {
  public func size<T>(for proposedSize: ProposedSize, hostView: MountedHostView<T>) -> CGSize {
//    let children = hostView.getChildren()
//    let childSize = content._size(for: proposedSize, hostView: children[0])
//    print("MODIFIEDCONTENT childSize", childSize)
//    return CGSize(width: childSize.width + 50, height: childSize.height + 50)
    modifier.size(for: proposedSize, hostView: hostView, content: content)
  }

  public func layout<T>(size: CGSize, hostView: MountedHostView<T>) {
//    let children = hostView.getChildren()
//    print("MODIFIEDCONTENT layout")
//    content._layout(size: size, hostView: children[0])
    return modifier.layout(size: size, hostView: hostView, content: content)
  }
}

extension ModifiedContent: ViewModifier where Content: ViewModifier, Modifier: ViewModifier {
  public func body(content: _ViewModifier_Content<Self>) -> Never {
    neverBody("ModifiedContent<ViewModifier, ViewModifier>")
  }
}

public extension ViewModifier {
  func concat<T>(_ modifier: T) -> ModifiedContent<Self, T> where T: ViewModifier {
    .init(content: self, modifier: modifier)
  }
}
