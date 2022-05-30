// Copyright 2022 Tokamak contributors
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
//  Created by Carson Katri on 5/28/22.
//

import Foundation

/// A `LayoutComputer` for the root element of a `FiberRenderer`.
struct RootLayoutComputer: LayoutComputer {
  let sceneSize: CGSize

  init(sceneSize: CGSize) {
    self.sceneSize = sceneSize
  }

  func proposeSize<V>(for child: V, at index: Int, in context: LayoutContext) -> CGSize
    where V: View
  {
    sceneSize
  }

  func position(_ child: LayoutContext.Child, in context: LayoutContext) -> CGPoint {
    .init(
      x: sceneSize.width / 2 - child.dimensions[HorizontalAlignment.center],
      y: sceneSize.height / 2 - child.dimensions[VerticalAlignment.center]
    )
  }

  func requestSize(in context: LayoutContext) -> CGSize {
    sceneSize
  }
}
