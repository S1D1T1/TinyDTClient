//
//  TinyDTClient.swift
//
//  Created by SoDoTo on 1/11/24.
//  cloned and copied from PromptWriter Main
//
//  Built on "RealHTTP" network client library
//    https://github.com/immobiliare/RealHTTP

//  This is bare bones - no error checking, or tracking of requests at all. It will send requests at any time, and
//  when a request succeeds, it simply stores the image in a globally accessible variable. So it doesn't
//  even track what image is in response to what request.



import Foundation
import RealHTTP
import SwiftUI

// server address, port and api path all hardcoded here
let serverPath = "/sdapi/v1/txt2img"
let defaultServerBaseURL = "localhost:7860"
let defaultServerPrefix = "http://"

//  so a console can reflect change in status
class SimpleDTClient : ObservableObject {
  enum serverStatus : Int {
    case unknown = 0,serverUp, serverDown
  }
  enum requestStatus : Int {
    case requestOK = 0, requestCancelled, requestError, requestServerDown
  }

  static var shared = SimpleDTClient()
  var status:serverStatus = .unknown
  var serverAddress:String=""

  init(thisDevice:Bool = true, address:String=""){
    //  make initial connection
    if thisDevice {
      self.serverAddress = defaultServerBaseURL
    }
    else {
      self.serverAddress = address
    }
    status = getServerStatusAsync()
  }

  // send a prompt, and optional negative prompt, async. Doesn't return anything.
  // it inserts a -1 seed
  func runPrompt(_ posPrompt:String, negPrompt:String = ""){

    // make prompt into json
    let dictionary:[String:Any?] = ["prompt":posPrompt,"negative_prompt":negPrompt, "seed":-1]

    do {
      let myjson =  try HTTPBody.json(dictionary)
      if  let req =   createJSONRequest(json:myjson) {
        runRequest(req)
      }
    }
    catch{
      return
    }
  }

  // this does 2 things : returns status and also updates.
  // functions shouldn't do 2 things.
  func getServerStatusAsync()->serverStatus {
    let req = HTTPRequest {
      $0.url = URL(string:defaultServerPrefix+serverAddress )
      if $0.url == nil {
        status = .serverDown
        return
      }
      $0.method = .head
      $0.timeout = 5
      $0.allowsCellularAccess = true
    }
    req.headers = HTTPHeaders(  )

    Task.init {
      do {
        let response =  try await req.fetch()
        let newStatus:serverStatus

        if response.statusCode != .none {
          newStatus = .serverUp
        }
        else {
          newStatus = .serverDown
        }

        // Server Status change - server status is observed. Changing it can trigger things.
        if status != newStatus {
          DispatchQueue.main.async {
            self.status = newStatus
          }
        }
      }
      catch {
        print("Error fetching request: \(error)")
        return serverStatus.serverDown
      }
      return self.status
    }
    return self.status
  }

  func createJSONRequest(json:HTTPBody)->HTTPRequest? {
    guard      let url = URL(string:defaultServerPrefix+serverAddress+serverPath )
    else {return nil}

    let req = HTTPRequest {
      // Setup default params
      $0.url = url
      $0.method = .post
      $0.timeout = 10000  //  this is needed, in seconds
      $0.allowsCellularAccess = true
      // Setup URL query params & body
      $0.body = json
    }
    if req.url == nil {return nil}
    req.headers = HTTPHeaders()
    return req
  }

  // asynchonous - send the request to the server. return immediately
  // when/ if the request succeeds, it will call simpleImageRequester.shared.returnImage

  func runRequest(_ req:HTTPRequest){
    struct jsonImageArray : Codable {
      var images:[Data]
    }
    Task.init {
      var response:HTTPResponse?
      do {
        response = try await req.fetch()
      }
      catch {
        print("Error fetching http request: \(error)")
        return
      }

      if response?.statusCode != .ok {
        return
      }

      if let rawResponse = response?.data {
        let decoder = JSONDecoder()
        let jsonimages = try decoder.decode(jsonImageArray.self, from: rawResponse)

        if jsonimages.images.isEmpty{
        }
        else {  // images array is not empty
          if jsonimages.images.count > 1 {
              //   [see deleted code in repo]
          } //  End of Batch Handling
          else {    //  not a batch

            let imageData = jsonimages.images[0]

            /// SUCCESS
            // Simply jam this image data into a known place. 
            DispatchQueue.main.async {
              simpleImageRequester.shared.returnImage(imageData)
            }
          }
        }     // END of Else: Images Array not empty
      }
    }
    return
  }
}
