//
//  RatingDialogTracking.swift
//  StanwoodDialog
//
//  Created by Ronan on 10/01/2018.
//

import Foundation

public enum RatingDialogEvent: String {
    case showDialog = "rating_dialog_shown"
    case acceptAction = "rating_dialog_yes_pressed"
    case cancelAction = "rating_dialog_no_pressed"
    case timeout = "rating_dialog_timeout"
}

public enum RatingDialogError: Error {
    case dialogError(String)
}

public protocol RatingDialogTracking {
    func track(event: RatingDialogEvent)
    func log(error: RatingDialogError)
}

public let kRatingDialogShown = "rating_dialog_shown"
public let kRatingDialogAcceptAction = "rating_dialog_yes_pressed"
public let kRatingDialogCancelAction = "rating_dialog_no_pressed"
public let kRatingDialogTimeout = "rating_dialog_timeout"

@objc public protocol SWDRatingDialogTracking {
    func track(event: String)
    func log(error: String)
}
