// Copyright 2019-2020 Tokamak contributors
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
//  Created by Jed Fox on 07/01/2020.
//

import TokamakShim

func title<V>(_ view: V, title: String) -> AnyView where V: View {
  if #available(OSX 10.16, iOS 14.0, *) {
    return AnyView(view.navigationTitle(title))
  } else {
    #if !os(macOS)
    return AnyView(view.navigationBarTitle(title))
    #else
    return AnyView(view)
    #endif
  }
}

struct NavItem: View {
  let id: String
  let destination: AnyView?

  init<V>(_ id: String, destination: V) where V: View {
    self.id = id
    self.destination = title(destination.frame(minWidth: 300), title: id)
  }

  init(unavailable id: String) {
    self.id = id
    destination = nil
  }

  @ViewBuilder var body: some View {
    if let dest = destination {
      NavigationLink(id, destination: HStack {
        Spacer(minLength: 0)
        dest
        Spacer(minLength: 0)
      })
    } else {
      #if os(WASI)
      Text(id)
      #elseif os(macOS)
      Text(id).opacity(0.5)
      #else
      HStack {
        Text(id)
        Spacer()
        Text("unavailable").opacity(0.5)
      }
      #endif
    }
  }
}

struct TokamakDemoView: View {
  var body: some View {
    NavigationView { () -> AnyView in
      let list = title(
        List {
          Section(header: Text("Buttons")) {
            NavItem(
              "Counter",
              destination:
              Counter(count: Count(value: 5), limit: 15)
                .padding()
                .background(Color(red: 0.9, green: 0.9, blue: 0.9, opacity: 1.0))
                .border(Color.red, width: 3)
            )
            NavItem("ButtonStyle", destination: ButtonStyleDemo())
          }
          Section(header: Text("Containers")) {
            NavItem("ForEach", destination: ForEachDemo())
            if #available(iOS 14.0, *) {
              #if os(macOS)
              NavItem("List", destination: ListDemo())
              #else
              NavItem("List", destination: ListDemo().listStyle(InsetGroupedListStyle()))
              #endif
            } else {
              NavItem("List", destination: ListDemo())
            }
            if #available(iOS 14.0, *) {
              NavItem("Sidebar", destination: SidebarListDemo().listStyle(SidebarListStyle()))
            } else {
              NavItem(unavailable: "Sidebar")
            }
            if #available(OSX 10.16, iOS 14.0, *) {
              NavItem("OutlineGroup", destination: OutlineGroupDemo())
            } else {
              NavItem(unavailable: "OutlineGroup")
            }
          }
          Section(header: Text("Layout")) {
            if #available(OSX 10.16, iOS 14.0, *) {
              NavItem("Grid", destination: GridDemo())
            } else {
              NavItem(unavailable: "Grid")
            }
            NavItem("Spacer", destination: SpacerDemo())
            NavItem("ZStack", destination: ZStack {
              Text("I'm on bottom")
              Text("I'm forced to the top")
                .zIndex(1)
              Text("I'm on top")
            }.padding(20))
          }
          Section(header: Text("Selectors")) {
            NavItem("Picker", destination: PickerDemo())
            NavItem("Toggle", destination: ToggleDemo())
          }
          Section(header: Text("Text")) {
            NavItem("Text", destination: TextDemo())
            NavItem("TextField", destination: TextFieldDemo())
          }
          Section(header: Text("Misc")) {
            NavItem("Path", destination: PathDemo())
            NavItem("Environment", destination: EnvironmentDemo().font(.system(size: 8)))
            NavItem("Color", destination: ColorDemo())
            if #available(OSX 11.0, iOS 14.0, *) {
              NavItem("AppStorage", destination: AppStorageDemo())
            } else {
              NavItem(unavailable: "AppStorage")
            }
            if #available(OSX 11.0, iOS 14.0, *) {
              NavItem("Redaction", destination: RedactionDemo())
            } else {
              NavItem(unavailable: "Redaction")
            }
          }
          #if os(WASI)
          Section(header: Text("TokamakDOM")) {
            NavItem("DOM reference", destination: DOMRefDemo())
          }
          #endif
        }
        .frame(minHeight: 300),
        title: "Demos"
      )
      if #available(iOS 14.0, *) {
        return AnyView(list.listStyle(SidebarListStyle()))
      } else {
        return AnyView(list)
      }
    }
    .environmentObject(TestEnvironment())
  }
}
