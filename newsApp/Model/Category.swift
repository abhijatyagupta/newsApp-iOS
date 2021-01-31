//
//  Category.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 09/10/20.
//
class Category {
    let categories: [String] = ["Sports", "Entertainment", "Business", "Technology", "Health", "Science", "General"]
    
    var title: String

    init(_ index: Int) {
        self.title = categories[index]
    }
}
