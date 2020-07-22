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

import TokamakCore

extension Path: ViewDeferredToRenderer {
  // TODO: Support transformations
  func svgFrom(storage: Storage,
               strokeStyle: StrokeStyle = .init(lineWidth: 0,
                                                lineCap: .butt,
                                                lineJoin: .miter,
                                                miterLimit: 0,
                                                dash: [],
                                                dashPhase: 0)) -> AnyView {
    let stroke = [
      "stroke-width": "\(strokeStyle.lineWidth)",
    ]
    let uniqueKeys = { (first: String, _: String) in first }
    let flexibleWidth: String? = sizing == .flexible ? "100%" : nil
    let flexibleHeight: String? = sizing == .flexible ? "100%" : nil
    let flexibleCenterX: String? = sizing == .flexible ? "50%" : nil
    let flexibleCenterY: String? = sizing == .flexible ? "50%" : nil
    switch storage {
    case .empty:
      return AnyView(EmptyView())
    case let .rect(rect):
      return AnyView(AnyView(HTML("rect", [
        "width": flexibleWidth ?? "\(max(0, rect.size.width))",
        "height": flexibleHeight ?? "\(max(0, rect.size.height))",
        "x": "\(rect.origin.x - (rect.size.width / 2))",
        "y": "\(rect.origin.y - (rect.size.height / 2))",
      ].merging(stroke, uniquingKeysWith: uniqueKeys))))
    case let .ellipse(rect):
      return AnyView(HTML("ellipse", ["cx": flexibleCenterX ?? "\(rect.origin.x)",
                                      "cy": flexibleCenterY ?? "\(rect.origin.y)",
                                      "rx": flexibleCenterX ?? "\(rect.size.width)",
                                      "ry": flexibleCenterY ?? "\(rect.size.height)"]
          .merging(stroke, uniquingKeysWith: uniqueKeys)))
    case let .roundedRect(roundedRect):
      // When cornerRadius is nil we use 50% rx.
      let size = roundedRect.rect.size
      let cornerRadius = { () -> [String: String] in
        if let cornerSize = roundedRect.cornerSize {
          return [
            "rx": "\(cornerSize.width)",
            "ry": """
            \(roundedRect.style == .continuous ?
              cornerSize.width :
              cornerSize.height)
            """,
          ]
        } else {
          // For this to support vertical capsules, we need
          // GeometryReader, to know which axis is larger.
          return ["ry": "50%"]
        }
      }()
      return AnyView(HTML("rect", [
        "width": flexibleWidth ?? "\(size.width)",
        "height": flexibleHeight ?? "\(size.height)",
        "x": "\(roundedRect.rect.origin.x)",
        "y": "\(roundedRect.rect.origin.y)",
      ]
      .merging(cornerRadius, uniquingKeysWith: uniqueKeys)
      .merging(stroke, uniquingKeysWith: uniqueKeys)))
    case let .stroked(stroked):
      return AnyView(stroked.path.svgBody(strokeStyle: stroked.style))
    case let .trimmed(trimmed):
      return trimmed.path.svgFrom(storage: trimmed.path.storage,
                                  strokeStyle: strokeStyle) // TODO: Trim the path
    }
  }

  func svgFrom(elements: [Element],
               strokeStyle: StrokeStyle = .init(lineWidth: 0,
                                                lineCap: .butt,
                                                lineJoin: .miter,
                                                miterLimit: 0,
                                                dash: [],
                                                dashPhase: 0)) -> AnyView {
    var d = [String]()
    for element in elements {
      switch element {
      case let .move(to: pos):
        d.append("M\(pos.x),\(pos.y)")
      case let .line(to: pos):
        d.append("L\(pos.x),\(pos.y)")
      case let .curve(to: pos, control1: c1, control2: c2):
        d.append("C\(c1.x),\(c1.y),\(c2.x),\(c2.y),\(pos.x),\(pos.y)")
      case let .quadCurve(to: pos, control: c1):
        d.append("Q\(c1.x),\(c1.y),\(pos.x),\(pos.y)")
      case .closeSubpath:
        d.append("Z")
      }
    }
    return AnyView(HTML("path", [
      "style": "stroke-width: \(strokeStyle.lineWidth);",
      "d": d.joined(separator: "\n"),
    ]))
  }

  func svgFrom(subpaths: [_SubPath],
               strokeStyle: StrokeStyle = .init(lineWidth: 0,
                                                lineCap: .butt,
                                                lineJoin: .miter,
                                                miterLimit: 0,
                                                dash: [],
                                                dashPhase: 0)) -> AnyView {
    AnyView(ForEach(Array(subpaths.enumerated()), id: \.offset) { _, path in
      path.path.svgBody(strokeStyle: strokeStyle)
    })
  }

  var storageSize: CGSize {
    switch storage {
    case .empty:
      return .zero
    case let .rect(rect), let .ellipse(rect):
      return rect.size
    case let .roundedRect(rect):
      return rect.rect.size
    case let .stroked(path):
      return path.path.size
    case let .trimmed(path):
      return path.path.size
    }
  }

  var elementsSize: CGSize {
    // Curves may clip without an explicit size
    let positions = elements.compactMap { elem -> CGPoint? in
      switch elem {
      case let .move(to: pos): return pos
      case let .line(to: pos): return pos
      case let .curve(to: pos, control1: _, control2: _): return pos
      case let .quadCurve(to: pos, control: _): return pos
      case .closeSubpath: return nil
      }
    }
    let xPos = positions.map(\.x).sorted(by: <)
    let minX = xPos.first ?? 0
    let maxX = xPos.last ?? 0
    let yPos = positions.map(\.y).sorted(by: <)
    let minY = yPos.first ?? 0
    let maxY = yPos.last ?? 0

    return CGSize(width: abs(maxX - min(0, minX)), height: abs(maxY - min(0, minY)))
  }

  var size: CGSize {
    .init(width: max(storageSize.width, elementsSize.width),
          height: max(storageSize.height, elementsSize.height))
  }

  @ViewBuilder
  func svgBody(strokeStyle: StrokeStyle = .init(lineWidth: 0,
                                                lineCap: .butt,
                                                lineJoin: .miter,
                                                miterLimit: 0,
                                                dash: [],
                                                dashPhase: 0)) -> some View {
    svgFrom(storage: storage, strokeStyle: strokeStyle)
    svgFrom(elements: elements, strokeStyle: strokeStyle)
    svgFrom(subpaths: subpaths, strokeStyle: strokeStyle)
  }

  public var deferredBody: AnyView {
    let sizeStyle = sizing == .flexible ?
      """
      width: 100%;
      height: 100%;
      """ :
      """
      width: \(max(0, size.width));
      height: \(max(0, size.height));
      """
    return AnyView(HTML("svg", ["style": """
    \(sizeStyle)
    overflow: visible;
    """]) {
      svgBody()
    })
  }
}
