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
//  Created by Carson Katri on 10/10/20.
//

import Foundation
import TokamakGTK

struct Counter: View {
  @State private var count: Int = 0
  var body: some View {
    VStack {
      Text("\(count)")
        .background(Color(red: 0.5, green: 1, blue: 0.5))
        .border(Color.red, width: 1)
      HStack {
        Button("Decrement") { count -= 1 }
        Button("Increment") { count += 1 }
      }
    }
  }
}

struct PickerDemo: View {
  @State private var chosenValue: Int = 3
  var body: some View {
    VStack {
      Text("Chose \(chosenValue)")
      Picker("Choose", selection: $chosenValue) {
        ForEach(0..<5) {
          Text("\($0)")
        }
      }
    }
  }
}

struct TokamakGTKDemo: App {
  var body: some Scene {
    WindowGroup("Test Scene") {
      VStack {
        Text("SKI")
        Capsule()
        Text("SKA")
          .background(Color.blue)
          .padding(10)
          .background(Color.yellow)
          .padding(10)
          .background(Color.red)
          .padding(10)
          .background(Color.green)
        Text("SKO").border(Color.red)
        HStack {
          Text("A").frame(width: 50, height: 50).border(Color.red)
          Text("B").frame(width: 100, height: 100).border(Color.red)
        }
        .padding(10)
        .background(Color.gray)
        ZStack {
          Rectangle().frame(width: 50, height: 10)
          Rectangle().frame(width: 10, height: 50)
        }

        ZStack(alignment: .topLeading) {
          Rectangle().frame(width: 50, height: 10)
          Rectangle().frame(width: 10, height: 50)
        }
      }
//      List {
//        Image("logo-header.png", bundle: Bundle.module, label: Text("Tokamak Demo"))
//        Counter()
//        PickerDemo()
//        ForEach(1..<100) {
//          Text("Item #\($0)")
//        }
//      }
    }
  }
}

TokamakGTKDemo.main()
