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

import TokamakCore

private extension DOMViewModifier {
  func unwrapToStyle<T>(
    _ key: KeyPath<Self, T?>,
    property: String? = nil,
    defaultValue: String = ""
  ) -> String {
    if let val = self[keyPath: key] {
      if let property = property {
        return "\(property): \(val)px;"
      } else {
        return "\(val)px;"
      }
    } else {
      return defaultValue
    }
  }
}

extension _FrameLayout: DOMViewModifier {
  public var attributes: [HTMLAttribute: String] {
    ["style": """
    \(unwrapToStyle(\.width, property: "width"))
    \(unwrapToStyle(\.height, property: "height"))
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    flex-grow: 0;
    flex-shrink: 0;
    """]
  }
}

extension _FlexFrameLayout: DOMViewModifier {
  public var attributes: [HTMLAttribute: String] {
    ["style": """
    \(unwrapToStyle(\.minWidth, property: "min-width"))
    width: \(unwrapToStyle(\.idealWidth, defaultValue: fillWidth ? "100%" : "auto"));
    \(unwrapToStyle(\.maxWidth, property: "max-width"))
    \(unwrapToStyle(\.minHeight, property: "min-height"))
    height: \(unwrapToStyle(\.idealHeight, defaultValue: fillHeight ? "100%" : "auto"));
    \(unwrapToStyle(\.maxHeight, property: "max-height"))
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    flex-grow: 0;
    flex-shrink: 0;
    """]
  }
}

private extension Edge {
  var cssValue: String {
    switch self {
    case .top: return "top"
    case .trailing: return "right"
    case .bottom: return "bottom"
    case .leading: return "left"
    }
  }
}

private extension EdgeInsets {
  func inset(for edge: Edge) -> CGFloat {
    switch edge {
    case .top: return top
    case .trailing: return trailing
    case .bottom: return bottom
    case .leading: return leading
    }
  }
}

extension _PaddingLayout: DOMViewModifier {
  public var isOrderDependent: Bool { true }
  public var attributes: [HTMLAttribute: String] {
    var padding = [(String, CGFloat)]()
    let insets = self.insets ?? .init(_all: 10)
    for edge in Edge.allCases {
      if edges.contains(.init(edge)) {
        padding.append((edge.cssValue, insets.inset(for: edge)))
      }
    }
    return ["style": padding
      .map { "padding-\($0.0): \($0.1)px;" }
      .joined(separator: " ")]
  }
}

extension _ShadowLayout: DOMViewModifier {
  public var attributes: [HTMLAttribute: String] {
    ["style": "box-shadow: \(x)px \(y)px \(radius)px 0px \(color.cssValue(.defaultEnvironment));"]
  }

  public var isOrderDependent: Bool { true }
}
