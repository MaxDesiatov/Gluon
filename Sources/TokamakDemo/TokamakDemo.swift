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
    self.destination = title(destination, title: id)
  }

  init(unavailable id: String) {
    self.id = id
    destination = nil
  }

  @ViewBuilder
  var body: some View {
    if let dest = destination {
      NavigationLink(id, destination: dest)
    } else {
      #if os(WASI)
      Text(id)
      #elseif os(macOS)
      Text(id).opacity(0.5)
      #elseif os(Linux)
      HStack {
        Text(id)
        Spacer()
        Text("unavailable")
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
          Image("logo-header.png", label: Text("Tokamak Demo"))
            .frame(height: 50)
            .padding(.bottom, 20)
          Section(header: Text("Buttons")) {
            NavItem(
              "Counter",
              destination:
              Counter(count: Count(value: 5), limit: 15)
                .padding()
                .background(Color(red: 0.9, green: 0.9, blue: 0.9, opacity: 1.0))
                .border(Color.red, width: 3)
                .foregroundColor(.black)
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
          Section(header: Text("Drawing")) {
            if #available(macOS 12.0, iOS 15.0, *) {
              NavItem("Canvas", destination: CanvasDemo())
            }
            NavItem("Color", destination: ColorDemo())
            NavItem("Path", destination: PathDemo())
            if #available(macOS 12.0, iOS 15.0, *) {
              NavItem("Shape Styles", destination: ShapeStyleDemo())
            }
          }
          Section(header: Text("Layout")) {
            NavItem("HStack/VStack", destination: StackDemo())
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
            NavItem("GeometryReader", destination: GeometryReaderDemo())
          }
          Section(header: Text("Modifiers")) {
            NavItem("Shadow", destination: ShadowDemo())
            #if os(WASI) && compiler(>=5.5) && (canImport(Concurrency) || canImport(_Concurrency))
            NavItem("Task", destination: TaskDemo())
            #endif
          }
          Section(header: Text("Selectors")) {
            NavItem("DatePicker", destination: DatePickerDemo())
            NavItem("Picker", destination: PickerDemo())
            NavItem("Slider", destination: SliderDemo())
            NavItem("Toggle", destination: ToggleDemo())
          }
          Section(header: Text("Text")) {
            NavItem("Text", destination: TextDemo())
            NavItem("TextField", destination: TextFieldDemo())
            NavItem("TextEditor", destination: TextEditorDemo())
          }
          Section(header: Text("Misc")) {
            NavItem("Animation", destination: AnimationDemo())
            NavItem("Transitions", destination: TransitionDemo())
            NavItem("ProgressView", destination: ProgressViewDemo())
            NavItem("Environment", destination: EnvironmentDemo().font(.system(size: 8)))
            if #available(macOS 11.0, iOS 14.0, *) {
              NavItem("Preferences", destination: PreferenceKeyDemo())
            }
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
            NavItem("URL hash changes", destination: URLHashDemo())
          }
          #endif
          Section(header: Text("New Features")) {
            NavItem("New Feature", destination: NewFeatureDemo())
          }
        }
        .frame(minHeight: 300),
        title: "Demos"
      )
      if #available(iOS 14.0, *) {
        return AnyView(
          list
            .listStyle(SidebarListStyle())
            .navigationTitle("Tokamak")
            .toolbar {
              ToolbarItem(placement: .cancellationAction) {
                Button("Cancellation Action") {}
              }
              ToolbarItem(placement: .confirmationAction) {
                Button("Confirmation Action") {}
              }
              ToolbarItem(placement: .destructiveAction) {
                Button("Destructive Action") {}
              }
              ToolbarItem(placement: .navigation) {
                Text("Some nav-text")
                  .italic()
              }
              ToolbarItem(placement: .status) {
                Text("Status: Live")
                  .bold()
                  .foregroundColor(.green)
              }
            }
        )
      } else {
        return AnyView(list)
      }
    }
    .environmentObject(TestEnvironment())
  }
}
