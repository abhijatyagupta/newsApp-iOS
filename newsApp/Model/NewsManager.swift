//
//  NewsManager.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 04/11/20.
//

import Foundation

class NewsManager {
    
    func performRequest(_ apiCall: String, callback: @escaping (Data?) -> Void) {
        if let colonIndex = apiCall.firstIndex(of: ":") {
            if apiCall[apiCall.startIndex..<colonIndex] == "http" {
                print("https used!")
                self.performRequestHelper("https" + apiCall[colonIndex..<apiCall.endIndex]) { (data) in
                    callback(data)
                }
            }
            else if apiCall[apiCall.startIndex..<colonIndex] == "https" {
                self.performRequestHelper(apiCall) { (data) in
                    callback(data)
                }
            }
            else {
                callback(nil)
            }
        }
        else {
            callback(nil)
        }
    }
    
    private func performRequestHelper(_ apiCall: String, callback: @escaping (Data?) -> Void) {
        if let url = URL(string: apiCall) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error == nil {
                    print("data will be sent!")
                    callback(data)
                }
                else {
                    print("Error occured in session.dataTask")
                    print(error.debugDescription)
                }
            }
            task.resume()
        }
        else {
            print("in performRequest, error creating url object")
            callback(nil)
        }
    }
}
