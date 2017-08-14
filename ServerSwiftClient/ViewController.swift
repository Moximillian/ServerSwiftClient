//
//  ViewController.swift
//  ServerSwiftClient
//
//  Created by Soini, Mox on 4.7.2016.
//  Copyright © 2016 Mox Soini. All rights reserved.
//

import UIKit

struct Stuff: Codable {
  let index: Int
  let title: String
}

class ViewController: UIViewController {

  let localLabel = UILabel()
  let remoteLabel = UILabel()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    localLabel.frame = CGRect(x: 50, y: 100, width: 200, height: 30)
    localLabel.text = "local connection"
    view.addSubview(localLabel)
    getStuff(local: true)

    remoteLabel.frame = CGRect(x: 50, y: 200, width: 200, height: 30)
    remoteLabel.text = "Remote connection"
    view.addSubview(remoteLabel)
    getStuff(local: false)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func updateOnMainThread(local: Bool, text: String) {
    // update UI on main thread
    DispatchQueue.main.async(execute: { () -> Void in
      if local {
        self.localLabel.text = text
      } else {
        self.remoteLabel.text = text
      }
    })
  }

  func getStuff(local: Bool) {
    let url = URL(string: local ? "http://localhost:8080/" : "http://swiftserverrepo-cdf3d3a7.b856219f.svc.dockerapp.io:8080")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    // request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    // setup the task
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      guard
        let response = response as? HTTPURLResponse,
        let data = data else { return }

      self.parseResponse(local: local, response: response)
      let decoder = JSONDecoder()
      do {
        let stuff = try decoder.decode(Stuff.self, from: data)
        print("DATA: \(stuff)")
        self.updateOnMainThread(local: local, text: "Result is: \(stuff.index) – \(stuff.title)")
        print()
      } catch {
        print("Failed to decode \(data)")
      }
    }

    // run the task
    task.resume()
  }

  func parseResponse(local: Bool, response: HTTPURLResponse) {
    let status = response.statusCode == 200 ? "OK" : String(response.statusCode)
    print("Response \(status) (\(local ? "local" : "remote"))", separator: " ")
    if let server = response.allHeaderFields["Server"] {
      print("on server: ", server, "\n")
    }
  }
}

