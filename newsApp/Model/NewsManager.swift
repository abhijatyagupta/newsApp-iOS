//
//  NewsManager.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 04/11/20.
//

import Foundation

class NewsManager {
    
    func performRequest(_ apiCall: String, callback: @escaping (Data?) -> Void) {
        if apiCall.count == 0 { callback(nil) }
        
        let urlValidation = URLValidation(url: apiCall)
        
        if urlValidation.isValidURL {
            performRequestHelper(urlValidation.isHTTPSecure ? apiCall : urlValidation.fixedURL) { (data) in
                callback(data)
            }
        }
        else {
            performRequestHelper(urlValidation.fixedURL) { (data) in
                callback(data)
            }
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
                    callback(nil)
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


private class URLValidation {
    let url: String
    var fixedURL: String = ""
    let colonIndex: String.Index?
    lazy var isHTTPSecure: Bool = {
        return checkHTTPSecure()
    }()
    lazy var isValidURL: Bool = {
        return checkValidURL()
    }()
    
    init(url: String) {
        self.url = url
        colonIndex = url.firstIndex(of: ":")
    }
    
    
    private func checkHTTPSecure() -> Bool {
        if let safeColonIndex = colonIndex {
            if url[url.startIndex..<safeColonIndex] == "https" {
                return true
            }
            else {
                print("https used!!")
                fixedURL = "https" + url[safeColonIndex..<url.endIndex]
                return false
            }
        }
        else {
            return false
        }
    }
    
    private func checkValidURL() -> Bool {
        if let safeColonIndex = colonIndex {
            let beginIndex = url.index(safeColonIndex, offsetBy: 2)
            let endIndex = 	url.index(safeColonIndex, offsetBy: 13)
            if url[beginIndex..<endIndex] == "/localhost/" {
                print("localhost url fixed!!")
                fixedURL = "https://" + url[endIndex..<url.endIndex]
                return false
            }
            else {
                return true
            }
        }
        else {
            return false
        }
    }
}
