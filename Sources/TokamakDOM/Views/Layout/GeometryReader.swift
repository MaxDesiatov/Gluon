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

import JavaScriptKit
import TokamakCore
import TokamakStaticHTML

private let ResizeObserver = JSObjectRef.global.ResizeObserver

extension GeometryReader: ViewDeferredToRenderer {
  public var deferredBody: AnyView {
    AnyView(_GeometryReader(content: content))
  }
}

struct _GeometryReader<Content: View>: View {
  public let content: (GeometryProxy) -> Content

  @State var ref: JSObjectRef?
  @State var size: CGSize?

  var body: some View {
    HTML("div") {
      if let size = size {
        content(makeProxy(from: size))
      } else {
        EmptyView()
      }
    }
    ._domRef($ref)
  }
}
