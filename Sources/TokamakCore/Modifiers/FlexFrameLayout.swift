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

public struct _FlexFrameLayout: ViewModifier {
  public let minWidth: CGFloat?
  public let idealWidth: CGFloat?
  public let maxWidth: CGFloat?
  public let minHeight: CGFloat?
  public let idealHeight: CGFloat?
  public let maxHeight: CGFloat?
  public let alignment: Alignment

  init(minWidth: CGFloat? = nil,
       idealWidth: CGFloat? = nil,
       maxWidth: CGFloat? = nil,
       minHeight: CGFloat? = nil,
       idealHeight: CGFloat? = nil,
       maxHeight: CGFloat? = nil,
       alignment: Alignment) {
    self.minWidth = minWidth
    self.idealWidth = idealWidth
    self.maxWidth = maxWidth
    self.minHeight = minHeight
    self.idealHeight = idealHeight
    self.maxHeight = maxHeight
    self.alignment = alignment
  }

  public func body(content: Content) -> some View {
    content
  }
}

extension View {
  public func frame(minWidth: CGFloat? = nil,
                    idealWidth: CGFloat? = nil,
                    maxWidth: CGFloat? = nil,
                    minHeight: CGFloat? = nil,
                    idealHeight: CGFloat? = nil,
                    maxHeight: CGFloat? = nil,
                    alignment: Alignment = .center) -> some View {
    func areInNondecreasingOrder(
      _ min: CGFloat?, _ ideal: CGFloat?, _ max: CGFloat?
    ) -> Bool {
      let min = min ?? -.infinity
      let ideal = ideal ?? min
      let max = max ?? ideal
      return min <= ideal && ideal <= max
    }

    if !areInNondecreasingOrder(minWidth, idealWidth, maxWidth)
      || !areInNondecreasingOrder(minHeight, idealHeight, maxHeight) {
      fatalError("Contradictory frame constraints specified.")
    }

    return modifier(
      _FlexFrameLayout(
        minWidth: minWidth,
        idealWidth: idealWidth, maxWidth: maxWidth,
        minHeight: minHeight,
        idealHeight: idealHeight, maxHeight: maxHeight,
        alignment: alignment
      ))
  }
}
