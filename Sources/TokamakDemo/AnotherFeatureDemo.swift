import TokamakShim

struct AnotherFeatureDemo: View {
  @State private var inputText: String = ""

  var body: some View {
    VStack {
      TextField("Enter some text", text: $inputText)
        .padding()
        .textFieldStyle(RoundedBorderTextFieldStyle())
      Button(action: {
        print("Input Text: \(inputText)")
      }) {
        Text("Submit")
          .padding()
          .background(Color.green)
          .foregroundColor(.white)
          .cornerRadius(8)
      }
    }
    .padding()
  }
}

struct AnotherFeatureDemo_Previews: PreviewProvider {
  static var previews: some View {
    AnotherFeatureDemo()
  }
}
