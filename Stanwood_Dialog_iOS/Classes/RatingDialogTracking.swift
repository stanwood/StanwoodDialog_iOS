//
//  RatingDialogTracking.swift
//  StanwoodDialog
//
//  Created by Ronan on 10/01/2018.
//  Distributed under MIT licence.

import Foundation

public enum RatingDialogEvent: String {
    case showDialog = "show"
    case acceptAction = "acceptAction"
    case cancelAction = "cancelAction"
    case timeout = "timeout"
}

public enum RatingDialogError: Error {
    case dialogError(String)
}

public protocol RatingDialogTracking {
    func track(event: RatingDialogEvent)
    func log(error: RatingDialogError)
}
