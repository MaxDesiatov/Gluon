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
//  Created by Carson Katri on 6/29/20.
//

public struct _BackgroundModifier<Background>: ViewModifier where Background: View {
  public var background: Background
  public var alignment: Alignment

  public init(background: Background, alignment: Alignment = .center) {
    self.background = background
    self.alignment = alignment
  }

  public func body(content: Content) -> some View {
    content
  }
}

extension _BackgroundModifier: Equatable where Background: Equatable {}

extension View {
  public func background<Background>(_ background: Background, alignment: Alignment = .center) -> some View where Background: View {
    modifier(_BackgroundModifier(background: background, alignment: alignment))
  }
}

public struct _OverlayModifier<Overlay>: ViewModifier where Overlay: View {
  public var overlay: Overlay
  public var alignment: Alignment

  public init(overlay: Overlay, alignment: Alignment = .center) {
    self.overlay = overlay
    self.alignment = alignment
  }

  public func body(content: Content) -> some View {
    ZStack(alignment: alignment) {
      content
      overlay
    }
  }
}

extension _OverlayModifier: Equatable where Overlay: Equatable {}

extension View {
  public func overlay<Overlay>(_ overlay: Overlay,
                               alignment: Alignment = .center) -> some View where Overlay: View {
    modifier(_OverlayModifier(overlay: overlay, alignment: alignment))
  }

  public func border<S>(_ content: S, width: CGFloat = 1) -> some View where S: ShapeStyle {
    overlay(Rectangle().strokeBorder(content, lineWidth: width))
  }
}
