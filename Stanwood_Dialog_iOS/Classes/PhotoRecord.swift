//
//  PhotoRecord.swift
//  Pods-Stanwood_Dialog_iOS_Example
//
//  Created by Eugène Peschard on 13/02/2018.
//

import UIKit

enum PhotoRecordState {
    case new, downloaded, failed
}

class PhotoRecord {
    let name: String
    let url: URL
    var state = PhotoRecordState.new
    var image = UIImage(named: "Placeholder")

    init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
}
