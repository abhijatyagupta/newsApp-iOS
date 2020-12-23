//
//  Constants.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 03/12/20.
//

struct K {
    static let rCSKey = "rememberCountrySettings"
    static let countryKey = "country"
    static let countryCodeKey = "countryCode"
    static let initialScreenKey = "initialScreen"
    static let recentSearchesKey = "recentSearches"
    static let searchHistoryKey = "searchHistory"
    
    struct UIText {
        static let deleteString = "Delete"
        static let cancelString = "Cancel"
        static let searchString = "Search"
        static let okString = "OK"
        static let worldString = "World"
        
        static let turnOff = "Turn Off"
        static let turnOffAndDelete = "Turn Off and Delete"
        static let turnOffHistoryTitle = "What would you like to do?"
        static let turnOffHistoryMessage = "'Turn off and Delete', along with turning history off, will also delete current search history."
        static let clearHistoryTitle = "Are you sure you want to delete recent search history?"
        static let historyFooter = "Recent history is stored for only past 10 queries."
        static let recentSearchHeader = "Recent searches"
        static let shareErrorTitle = "Error sharing article"
        static let shareErrorMessage = "The news URL is invalid."
        static let articleOpenErrorTitle = "Unable to open article"
        static let searchPlaceholder = "Search topic"
    }
}
