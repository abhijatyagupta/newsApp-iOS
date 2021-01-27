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
        static let errorString = "Error"
        static let sentString = "Sent"
        static let signUpString = "Sign Up"
        static let signInString = "Sign In"
        static let signOutString = "Sign Out"
        static let createAccountButton = "CREATE ACCOUNT AND SIGN IN"
        
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
        static let publicViews = "Public Views"
        static let publicViewsFooter = "All public views are anonymous. Read guidelines on posting public views."
        static let undoMark = "Undo mark"
        static let markThisNews = "Mark this news as"
        static let newsMarked = "You marked this news as"
        static let emailAddressPlaceholder = "Email address"
        static let passwordPlaceholder = "Password"
        static let tryAgain = "Try Again"
        static let sentSuccessful = "Reset link sent successfully"
        static let noUser = "No user found"
        static let areYouSure = "Are you sure?"
        static let deleteAccountFooter = "Deleting an account will unmark all the news you have marked till date. This action cannot be undone."
        static let deleteSuccess = "Account successfully deleted."
        static let deleteAndSignOut = "Delete and sign out"
        static let signOutMessage = "You will be signed out."
        static let passwordResetMessage = "A password reset link has been sent to your email."
    }
}
