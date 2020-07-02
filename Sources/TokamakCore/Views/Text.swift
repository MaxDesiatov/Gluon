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
//  Created by Max Desiatov on 08/04/2020.
//

public struct Text: View {
  let content: String
  let modifiers: [_Modifier]

  @Environment(\.font) var font: Font?

  public enum _Modifier: Equatable {
    case color(Color?)
    case font(Font?)
    case italic
    case weight(Font.Weight?)
    case kerning(CGFloat)
    case tracking(CGFloat)
    case baseline(CGFloat)
    case rounded
    case strikethrough(Bool, Color?) // Note: Not in SwiftUI
    case underline(Bool, Color?) // Note: Not in SwiftUI
  }

  init(content: String, modifiers: [_Modifier] = []) {
    self.content = content
    self.modifiers = modifiers
  }

  public init(verbatim content: String) {
    self.init(content: content)
  }

  public init<S>(_ content: S) where S: StringProtocol {
    self.init(content: String(content))
  }

  public var body: Never {
    neverBody("Text")
  }
}

/// This is a helper class that works around absence of "package private" access control in Swift
public struct _TextProxy {
  public let subject: Text

  public init(_ subject: Text) { self.subject = subject }

  public var content: String { subject.content }
  public var modifiers: [Text._Modifier] {
    [
      .font(subject.font),
    ] + subject.modifiers
  }
}

public extension Text {
  func foregroundColor(_ color: Color?) -> Text {
    .init(content: content, modifiers: modifiers + [.color(color)])
  }

  func font(_ font: Font?) -> Text {
    .init(content: content, modifiers: modifiers + [.font(font)])
  }

  func fontWeight(_ weight: Font.Weight?) -> Text {
    .init(content: content, modifiers: modifiers + [.weight(weight)])
  }

  func bold() -> Text {
    .init(content: content, modifiers: modifiers + [.weight(.bold)])
  }

  func italic() -> Text {
    .init(content: content, modifiers: modifiers + [.italic])
  }

  func strikethrough(_ active: Bool = true, color: Color? = nil) -> Text {
    .init(content: content, modifiers: modifiers + [.strikethrough(active, color)])
  }

  func underline(_ active: Bool = true, color: Color? = nil) -> Text {
    .init(content: content, modifiers: modifiers + [.underline(active, color)])
  }

  func kerning(_ kerning: CGFloat) -> Text {
    .init(content: content, modifiers: modifiers + [.kerning(kerning)])
  }

  func tracking(_ tracking: CGFloat) -> Text {
    .init(content: content, modifiers: modifiers + [.tracking(tracking)])
  }

  func baselineOffset(_ baselineOffset: CGFloat) -> Text {
    .init(content: content, modifiers: modifiers + [.baseline(baselineOffset)])
  }
}
