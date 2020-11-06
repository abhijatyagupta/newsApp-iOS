//
//  NewsManager.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 04/11/20.
//

import Foundation

class NewsManager {
    
    func fetchNews(_ url: String) {
        
    }
    
    func performRequest(_ apiCall: String, callback: @escaping (URLResponse?) -> Void) {
        if let url = URL(string: apiCall) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error == nil {
                    print("response will be sent!")
                    callback(response)
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
        }
    }
    
    
    
    
    
}