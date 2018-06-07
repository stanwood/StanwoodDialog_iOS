//
//  FirebaseTracker.swift
//  StanwoodAnalytics_Example
//
//  Created by Ronan on 02/01/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import FirebaseAnalytics
import StanwoodAnalytics

struct FirebaseParameterMapper: ParameterMapper {
    func map(parameters: TrackingParameters) -> [String:NSString] {
        var keyValues: [String:NSString] = [:]

        if let itemId = parameters.itemId {
            keyValues[AnalyticsParameterItemID] = NSString(string: itemId)
        }

        if let contentType = parameters.contentType {
            keyValues[AnalyticsParameterContentType] = NSString(string: contentType)
        }

        if let category = parameters.category {
            keyValues[AnalyticsParameterItemCategory] = NSString(string: category)
        }

        if let name = parameters.name {
            keyValues[AnalyticsParameterItemName] = NSString(string: name)
        }

        return keyValues
    }
}

open class FirebaseTracker: Tracker {
    
    var parameterMapper: ParameterMapper?
    
    init(builder: FirebaseBuilder) {
        super.init(builder: builder)
        
        if builder.parameterMapper == nil {
            parameterMapper = FirebaseParameterMapper()
        } else {
            parameterMapper = builder.parameterMapper
        }
        
        if builder.configFileName != nil {
            let firebaseConfigFile = Bundle.main.path(forResource: builder.configFileName, ofType: "plist")
            let firebaseOptions = FirebaseOptions(contentsOfFile: firebaseConfigFile!)
            FirebaseApp.configure(options: firebaseOptions!)
        } else {
            FirebaseApp.configure()
        }
    }

    override open func track(trackingParameters: TrackingParameters) {

        if parameterMapper != nil {
            Analytics.logEvent(trackingParameters.eventName, parameters: parameterMapper?.map(parameters: trackingParameters))
        } else {
            var keyValueDict: [String: NSString] = ["event_name":trackingParameters.eventName as NSString]
            
            if let category = trackingParameters.category {
                keyValueDict["category"] = category as NSString
            }
            
            if let contentType = trackingParameters.contentType {
                keyValueDict["contentType"] = contentType as NSString
            }
            
            if let itemId = trackingParameters.itemId {
                keyValueDict["itemId"] = itemId as NSString
            }
            
            if let name = trackingParameters.name {
                keyValueDict["name"] = name as NSString
            }
            
            if let description = trackingParameters.description {
                keyValueDict["description"] = description as NSString
            }
            
            Analytics.logEvent(trackingParameters.eventName, parameters: keyValueDict)
        }
    }

    override open func track(error: NSError) {
        let parameters = error.userInfo as [String:Any]
        Analytics.logEvent("error", parameters: parameters)
    }

    override open func track(trackerKeys: TrackerKeys) {
        let customKeys = trackerKeys.customKeys
        
        var screenName: String = ""
        var screenClass: String = ""
        
        for (key,value) in customKeys {
            if key == StanwoodAnalytics.Key.screenName {
                screenName = value as! String
            }
            
            if key == StanwoodAnalytics.Key.screenClass {
                screenClass = value as! String
            }
        }
        
        if !screenName.isEmpty {
            if screenClass.isEmpty {
                Analytics.setScreenName(screenName, screenClass: nil)
            } else {
                Analytics.setScreenName(screenName, screenClass: screenClass)
            }
        }
    }
    
    open class FirebaseBuilder: Tracker.Builder {
        
        var parameterMapper: ParameterMapper?
        var configFileName: String?
        
        public init(context: UIApplication, configFileName: String? = nil) {
            super.init(context: context, key: nil)
            self.configFileName = configFileName
        }
        
        open func add(mapper: ParameterMapper) -> FirebaseBuilder {
            parameterMapper = mapper
            return self
        }
        
        open override func build() -> FirebaseTracker {
            return FirebaseTracker(builder: self)
        }
    }
}
