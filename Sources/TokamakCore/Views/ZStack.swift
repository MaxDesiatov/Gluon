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

/// An alignment in both axes.
public struct Alignment: Equatable {
  public var horizontal: HorizontalAlignment
  public var vertical: VerticalAlignment
  
  public init(
    horizontal: HorizontalAlignment,
    vertical: VerticalAlignment
  ) {
    self.horizontal = horizontal
    self.vertical = vertical
  }
  
  public static let topLeading     = Self.init(horizontal: .leading, vertical: .top)
  public static let top            = Self.init(horizontal: .center, vertical: .top)
  public static let topTrailing    = Self.init(horizontal: .trailing, vertical: .top)
  public static let leading        = Self.init(horizontal: .leading, vertical: .center)
  public static let center         = Self.init(horizontal: .center, vertical: .center)
  public static let trailing       = Self.init(horizontal: .trailing, vertical: .center)
  public static let bottomLeading  = Self.init(horizontal: .leading, vertical: .bottom)
  public static let bottom         = Self.init(horizontal: .center, vertical: .bottom)
  public static let bottomTrailing = Self.init(horizontal: .trailing, vertical: .bottom)
}

/// A view that overlays its children, aligning them in both axes.
public struct ZStack<Content>: View where Content: View {
  public let alignment: Alignment
  let spacing: CGFloat?
  public let content: Content

  public init(
    alignment: Alignment = .center,
    spacing: CGFloat? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.alignment = alignment
    self.spacing = spacing
    self.content = content()
  }

  public var body: Never {
    neverBody("ZStack")
  }
}

extension ZStack: ParentView {
  public var children: [AnyView] {
    (content as? GroupView)?.children ?? [AnyView(content)]
  }
}
