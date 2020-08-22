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
//  Created by Carson Katri on 06/28/2020.
//

public protocol Shape: View {
  func path(in rect: CGRect) -> Path
}

public protocol ShapeStyle {}

extension ShapeStyle where Self: View, Self.Body == _ShapeView<Rectangle, Self> {
  public var body: some View {
    _ShapeView(shape: Rectangle(), style: self)
  }
}

public protocol InsettableShape: Shape {
  associatedtype InsetShape: InsettableShape
  func inset(by amount: CGFloat) -> InsetShape
}

public struct ForegroundStyle: ShapeStyle {
  public init() {}
}

public struct FillStyle: Equatable, ShapeStyle {
  public var isEOFilled: Bool
  public var isAntialiased: Bool

  public init(eoFill: Bool = false, antialiased: Bool = true) {
    isEOFilled = eoFill
    isAntialiased = antialiased
  }
}

public struct _ShapeView<Content, Style>: View where Content: Shape, Style: ShapeStyle {
  @Environment(\.self) public var environment
  @Environment(\.foregroundColor) public var foregroundColor
  public var shape: Content
  public var style: Style
  public var fillStyle: FillStyle

  public init(shape: Content, style: Style, fillStyle: FillStyle = FillStyle()) {
    self.shape = shape
    self.style = style
    self.fillStyle = fillStyle
  }

  public var body: Never {
    neverBody("_ShapeView")
  }
}

extension Shape {
  public func trim(from startFraction: CGFloat = 0, to endFraction: CGFloat = 1) -> some Shape {
    _TrimmedShape(shape: self, startFraction: startFraction, endFraction: endFraction)
  }
}

extension Shape {
  public func offset(_ offset: CGSize) -> OffsetShape<Self> {
    OffsetShape(shape: self, offset: offset)
  }

  public func offset(_ offset: CGPoint) -> OffsetShape<Self> {
    OffsetShape(shape: self, offset: CGSize(width: offset.x, height: offset.y))
  }

  public func offset(x: CGFloat = 0, y: CGFloat = 0) -> OffsetShape<Self> {
    OffsetShape(shape: self, offset: .init(width: x, height: y))
  }

  public func scale(
    x: CGFloat = 1,
    y: CGFloat = 1,
    anchor: UnitPoint = .center
  ) -> ScaledShape<Self> {
    ScaledShape(
      shape: self,
      scale: CGSize(width: x, height: y),
      anchor: anchor
    )
  }

  public func scale(_ scale: CGFloat, anchor: UnitPoint = .center) -> ScaledShape<Self> {
    self.scale(x: scale, y: scale, anchor: anchor)
  }

  public func rotation(_ angle: Angle, anchor: UnitPoint = .center) -> RotatedShape<Self> {
    RotatedShape(shape: self, angle: angle, anchor: anchor)
  }

  public func transform(_ transform: CGAffineTransform) -> TransformedShape<Self> {
    TransformedShape(shape: self, transform: transform)
  }
}

extension Shape {
  public func size(_ size: CGSize) -> some Shape {
    _SizedShape(shape: self, size: size)
  }

  public func size(width: CGFloat, height: CGFloat) -> some Shape {
    size(.init(width: width, height: height))
  }
}

extension Shape {
  public func stroke(style: StrokeStyle) -> some Shape {
    _StrokedShape(shape: self, style: style)
  }

  public func stroke(lineWidth: CGFloat = 1) -> some Shape {
    stroke(style: StrokeStyle(lineWidth: lineWidth))
  }
}

extension Shape {
  public func fill<S>(
    _ content: S,
    style: FillStyle = FillStyle()
  ) -> some View where S: ShapeStyle {
    _ShapeView(shape: self, style: content, fillStyle: style)
  }

  public func fill(style: FillStyle = FillStyle()) -> some View {
    _ShapeView(shape: self, style: ForegroundStyle(), fillStyle: style)
  }

  public func stroke<S>(_ content: S, style: StrokeStyle) -> some View where S: ShapeStyle {
    stroke(style: style).fill(content)
  }

  public func stroke<S>(_ content: S, lineWidth: CGFloat = 1) -> some View where S: ShapeStyle {
    stroke(content, style: StrokeStyle(lineWidth: lineWidth))
  }
}

extension Shape {
  public var body: some View {
    _ShapeView(shape: self, style: ForegroundStyle())
  }
}
