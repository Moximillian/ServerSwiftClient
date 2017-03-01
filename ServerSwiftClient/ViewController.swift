//
//  ViewController.swift
//  ServerSwiftClient
//
//  Created by Soini, Mox on 4.7.2016.
//  Copyright © 2016 Mox Soini. All rights reserved.
//

import UIKit

struct Stuff {
  let index: Int
  let title: String

  init?(data: Data) {
    do {
      guard
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
        let index = json["index"] as? Int,
        let title = json["title"] as? String
        else {
          print("Failed to build struct from JSON: \(data)")
          return nil
      }
      self.index = index
      self.title = title

    } catch let error as NSError {
      print("Stuff(data:) error converting from json: \(error.localizedDescription)\n")
      return nil
    }
  }
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

    let url = URL(string: local ? "http://localhost:8080/" : "https://example.herokuapp.com")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    // request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    // setup the task
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      guard let response = response as? HTTPURLResponse else { return }
      self.parseResponse(local: local, response: response)

      guard let theData = data else { return }
      guard let stuff = Stuff(data: theData) else {
        print("DATA ERROR: ", String(data: theData, encoding: String.Encoding.utf8) ?? "unknown")
        return
      }

      print("DATA: \(stuff)")
      self.updateOnMainThread(local: local, text: "Result is: \(stuff.index) – \(stuff.title)")
      print()
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

