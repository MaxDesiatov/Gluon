// Copyright 2021 Tokamak contributors
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
//  Created by Max Desiatov on 13/06/2021.
//

// SnapshotTesting with image snapshots are only supported on iOS.
#if os(macOS)
import SnapshotTesting
import TokamakStaticHTML
import XCTest

// Needed for `NSImage`, but would be great to make this truly cross-platform.
import class AppKit.NSImage

public extension Snapshotting where Value: View, Format == NSImage {
  static var image: Snapshotting { .image() }

  /// A snapshot strategy for comparing Tokamak Views based on pixel equality.
  static func image(precision: Float = 1, size: CGSize? = nil) -> Snapshotting {
    SimplySnapshotting.image(precision: precision).asyncPullback { view in
      Async { callback in
        let html = Data(StaticHTMLRenderer(view).render().utf8)
        let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let renderedPath = cwd.appendingPathComponent("rendered.html")

        // swiftlint:disable:next force_try
        try! html.write(to: renderedPath)
        let browser = Process()
        browser
          .launchPath = "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"

        var arguments = ["--headless", "--disable-gpu", "--screenshot", renderedPath.path]
        if let size = size {
          arguments.append("--window-size=\(Int(size.width)),\(Int(size.height))")
        }

        browser.arguments = arguments
        browser.terminationHandler = { _ in
          callback(NSImage(
            contentsOfFile: cwd.appendingPathComponent("screenshot.png")
              .path
          )!)
        }
        browser.launch()
      }
    }
  }
}

struct HStackTest: View {
  var body: some View {
    VStack {
      Text("Adaptive LazyVGrid")
      LazyVGrid(columns: [
        GridItem(.adaptive(minimum: 50)),
      ]) {
        ForEach(0..<10) {
          Text("\($0 + 1)")
            .padding()
            .background(Color.red)
        }
      }
    }.frame(width: 300, height: 100)
  }
}

final class SnapshotTests: XCTestCase {
  func testVGrid() {
    assertSnapshot(matching: HStackTest(), as: .image(size: .init(width: 300, height: 100)))
  }
}

#endif
