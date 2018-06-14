//
//  FirebaseTracker.swift
//  StanwoodDialog_iOS
//
//  Copyright (c) 2018 stanwood GmbH
//  Distributed under MIT licence.
//

import Foundation
import FirebaseCore
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

public protocol FirebaseCoreEnabler {
    static func configure(options: [String:String])
}

public protocol FirebaseAnalyticsEnabler {
    static func logEvent()
    static func setScreenName()
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
        
        AnalyticsConfiguration.shared().setAnalyticsCollectionEnabled(StanwoodAnalytics.trackingEnabled())
        
        if builder.configFileName != nil {
            guard let firebaseConfigFile = Bundle.main.path(forResource: builder.configFileName, ofType: "plist") else {
                let fileName = builder.configFileName!
                print("StanwoodAnalytics Error: The file \(String(describing: fileName)) cannot be found.")
                return
            }
            let firebaseOptions = FirebaseOptions(contentsOfFile: firebaseConfigFile)
            FirebaseApp.configure(options: firebaseOptions!)
        } else {
            if hasConfigurationFile() == true {
                FirebaseApp.configure()
            }
        }
    }
    
    private func hasConfigurationFile() -> Bool {
        guard let _ = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            print("StanwoodAnalytics Error: The GoogleService-Info property list used to configure Firebase Analytics cannot be found.")
            return false }
        return true
    }
    
    open override func start() {
        AnalyticsConfiguration.shared().setAnalyticsCollectionEnabled(true)
    }
    
    override open func setTracking(enable: Bool) {
        AnalyticsConfiguration.shared().setAnalyticsCollectionEnabled(enable)
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
    
    /**
     
     Track the error using logEvent and the UserInfo dictionary.
     
     */

    override open func track(error: NSError) {
        let parameters = error.userInfo as [String:Any]
        Analytics.logEvent("error", parameters: parameters)
    }
    
    /**
     
     Track screen name and class.
     
     Using the custom keys and values, use the StanwoodAnalytics.Key.screenName key
     
     */

    override open func track(trackerKeys: TrackerKeys) {
        let customKeys = trackerKeys.customKeys
        
        var screenName: String = ""
        var screenClass: String = ""
        
        for (key,value) in customKeys {
            if key == StanwoodAnalytics.Keys.screenName {
                screenName = value as! String
            }
            
            if key == StanwoodAnalytics.Keys.screenClass {
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
