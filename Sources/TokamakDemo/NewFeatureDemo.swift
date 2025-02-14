import TokamakShim

struct NewFeatureDemo: View {
  var body: some View {
    VStack {
      Text("Welcome to the New Feature Demo!")
        .font(.largeTitle)
        .padding()
      Text("This is where you can showcase new features.")
        .padding()
      Button(action: {
        print("Button Pressed!")
      }) {
        Text("Press Me")
          .padding()
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(8)
      }
    }
  }
}

struct NewFeatureDemo_Previews: PreviewProvider {
  static var previews: some View {
    NewFeatureDemo()
  }
}
