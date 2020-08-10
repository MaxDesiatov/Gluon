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
//  Created by Carson Katri on 7/31/20.
//

import JavaScriptKit
import TokamakCore
import TokamakStaticHTML

public typealias Listener = (JSObjectRef) -> ()

protocol AnyDynamicHTML: AnyHTML {
  var listeners: [String: Listener] { get }
}

public struct DynamicHTML<Content>: View, AnyDynamicHTML {
  public let tag: String
  public let attributes: [String: String]
  public let listeners: [String: Listener]
  let content: Content

  public var innerHTML: String?

  public var body: Never {
    neverBody("HTML")
  }
}

extension DynamicHTML where Content: StringProtocol {
  public init(
    _ tag: String,
    _ attributes: [String: String] = [:],
    listeners: [String: Listener] = [:],
    content: Content
  ) {
    self.tag = tag
    self.attributes = attributes
    self.listeners = listeners
    self.content = content
    innerHTML = String(content)
  }
}

extension DynamicHTML: ParentView where Content: View {
  public init(
    _ tag: String,
    _ attributes: [String: String] = [:],
    listeners: [String: Listener] = [:],
    @ViewBuilder content: () -> Content
  ) {
    self.tag = tag
    self.attributes = attributes
    self.listeners = listeners
    self.content = content()
    innerHTML = nil
  }

  public var children: [AnyView] {
    [AnyView(content)]
  }
}

extension DynamicHTML where Content == EmptyView {
  public init(
    _ tag: String,
    _ attributes: [String: String] = [:],
    listeners: [String: Listener] = [:]
  ) {
    self = DynamicHTML(tag, attributes, listeners: listeners) { EmptyView() }
  }
}
