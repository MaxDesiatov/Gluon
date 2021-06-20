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
//  Created by Max Desiatov on 07/12/2018.
//

import SnapshotTesting
import TokamakStaticHTML
import XCTest

final class ReconcilerTests: XCTestCase {
  struct Model {
    let text: Text
  }

  private struct OptionalBody: View {
    var model: Model?

    var body: some View {
      if let text = model?.text {
        VStack {
          text

          Spacer()
        }
      }
    }
  }

  func testOptional() {
    let resultingHTML = StaticHTMLRenderer(OptionalBody(model: Model(text: Text("text"))))
      .render(shouldSortAttributes: true)

    assertSnapshot(matching: resultingHTML, as: .lines)
  }

  func testPaddingFusion() {
    let x = Text("text").padding(10)
    let resultingHTML = StaticHTMLRenderer(x.padding(20)).render(shouldSortAttributes: true)

    assertSnapshot(matching: resultingHTML, as: .lines)
  }
}
