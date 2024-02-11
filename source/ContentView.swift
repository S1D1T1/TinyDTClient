///  A Super Simple client for Draw Things.
/// by SoDoTo


import SwiftUI
import Foundation

@main
struct PictureThisApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
  @State var prompt:String=""
  @ObservedObject var requester = simpleImageRequester.shared

    var body: some View {
        VStack {
          TextField("Prompt:", text: $prompt).onSubmit {
            requester.runPrompt(prompt)
          }

          if let image = requester.image  {
            Image(nsImage:image)
          }
        }
        .padding()
    }
  }

class simpleImageRequester : ObservableObject {
 static var shared = simpleImageRequester()  //  make it a global, so async routines can find me
  @Published var image:NSImage?

  func runPrompt(_ prompt:String){
    SimpleDTClient.shared.runPrompt(prompt)
  }

  func returnImage(_ imageData:Data){
    self.image = NSImage(data: imageData)
  }
  

  /// not currently used. you can save the image received
  func saveTmpImage(_ imageData:Data)->URL?
  {
    let tempDirectoryURL = FileManager.default.temporaryDirectory
    let tempFileURL = tempDirectoryURL.appendingPathComponent("tmpImage.png")

    do{
      try imageData.write(to: tempFileURL)
    }
    catch{return nil}
    return tempFileURL
  }
}


#Preview {
    ContentView()
}

