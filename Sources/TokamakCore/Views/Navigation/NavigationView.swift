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
//  Created by Jed Fox on 06/30/2020.
//

final class NavigationContext: ObservableObject {
  @Published var destination = NavigationLinkDestination(EmptyView())
}

public struct NavigationView<Content>: View where Content: View {
  let content: Content

  @StateObject var context = NavigationContext()

  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  public var body: Never {
    neverBody("NavigationView")
  }
}

/// This is a helper class that works around absence of "package private" access control in Swift
public struct _NavigationViewProxy<Content: View> {
  public let subject: NavigationView<Content>

  public init(_ subject: NavigationView<Content>) { self.subject = subject }

  public var content: some View {
    subject.content
      .environmentObject(subject.context)
  }

  public var destination: some View {
    subject.context.destination.view
      .environmentObject(subject.context)
  }
}

struct NavigationDestinationKey: EnvironmentKey {
  public static let defaultValue: Binding<AnyView>? = nil
}

extension EnvironmentValues {
  var navigationDestination: Binding<AnyView>? {
    get {
      self[NavigationDestinationKey.self]
    }
    set {
      self[NavigationDestinationKey.self] = newValue
    }
  }
}

public let _navigationDestinationKey = \EnvironmentValues.navigationDestination
