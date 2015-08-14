//
//  ThereClient.swift
//  there
//
//  Created by Tommaso Piazza on 08/08/15.
//  Copyright (c) 2015 Alloc Init. All rights reserved.
//

import Foundation


public typealias ThereSearchCallBack = ([ThereLocation]?, NSError?) -> ()
public typealias ThereRouteCallBack = ([ThereWayPoint]?, NSError?) -> ()
public typealias JSONRquestCompletionBlock = ([String:AnyObject]?, NSError?) -> ()


public class ThereClient {
    
    public static var logLevel:ThereLogLevel = ThereLogLevel.Error
    public let appId:String
    public let appCode:String
    private let requestGenerator:ThereRequestGenerator!
    
    private(set) var searchSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    private(set) var routeSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    
    /**
    Initializes a new client with the provided appId and appCode.
    
    :param: appId The id of the application registered with the here API.
    :param: appCode The code of the application registred with the here API.

    
    :returns: A new client.
    */
    
    public init(appId:String, appCode:String){
        
        self.appId = appId
        self.appCode = appCode
        self.requestGenerator = ThereRequestGenerator(appId: self.appId, appCode: self.appCode)
    }
    
    /**
    Initiates a new geocoding request for free form input. Cancels previous ongoing requests.
    
    :param: term The free form search term representing the location to geocode.
    :param: callBackQueue The queue on which to received the callbalck. Optional. Defaults to *dispatch_get_main_queue()*.
    :param: onCompletion The callback to be executed on completion.
    
    :returns: A new client.
    */
    
    public func searchWithTerm(term:String, callBackQueue:dispatch_queue_t = dispatch_get_main_queue(), onCompletion:ThereSearchCallBack) {
        
        self.searchSession.getTasksWithCompletionHandler{ [weak self](dataTasks, uploadTasks, downloadTasks) in
            
            if let strongSelf = self {
                
                if dataTasks != nil {
                    
                    dataTasks.map { $0.cancel() }
                }
                
                switch strongSelf.requestGenerator.searchRequestWithParameters(term) {
                    
                case .Left(let box):
                    onCompletion(nil, box.value as NSError)
                case .Right(let box):
                    
                    strongSelf.performDataTask(box.value, session:strongSelf.searchSession).then({ (data, response, error) -> NSError? in
                        
                        switch strongSelf.locationsWithData(data) {
                            
                        case .Left(let box):
                            return box.value
                        case .Right(let box):
                            performOnQueue(callBackQueue){
                                onCompletion(box.value, nil)
                            }
                            return nil
                        }
                    }).fail({ (error) -> () in
                        performOnQueue(callBackQueue){
                            onCompletion(nil, error)
                        }
                    })
                }
            }
        }
    }
    
    
    /**
    Initiates a new routing request given a set of waypoints. Cancels previous ongoing requests.
    
    :param: wayPoints The list of waypoints the route should touch. A minimum of two waypoints are required to calculare a route.
    :param: callBackQueue The queue on which to received the callbalck. Optional. Defaults to *dispatch_get_main_queue()*.
    :param: onCompletion The callback to be executed on completion.
    
    :returns: A new client.
    */
    
    public func routeWithWayPoins(wayPoints:[(Double, Double)], mode:ThereRoutingMode, callBackQueue:dispatch_queue_t = dispatch_get_main_queue(), onCompletion:ThereRouteCallBack) {
        
        
        self.routeSession.getTasksWithCompletionHandler{ [weak self](dataTasks, uploadTasks, downloadTasks) in
            
            if let strongSelf = self {
                
                if dataTasks != nil {
                    
                    dataTasks.map { $0.cancel() }
                }
                
                switch strongSelf.requestGenerator.routeRequestWithParameters(wayPoints, mode: mode) {

                case .Left(let box):
                    onCompletion(nil, box.value as NSError)
                case .Right(let box):

                    strongSelf.performDataTask(box.value, session:strongSelf.routeSession).then({ (data, response, error) -> NSError? in

                        switch strongSelf.wayPointsWithData(data) {

                        case .Left(let box):
                            return box.value
                        case .Right(let box):
                            performOnQueue(callBackQueue){
                                onCompletion(box.value, nil)
                            }
                            return nil
                        }
                    }).fail({ (error) -> () in
                        performOnQueue(callBackQueue){
                            onCompletion(nil, error)
                        }
                    })
                }
            }
        }
    }
    
    private func performDataTask(request:NSURLRequest, session:NSURLSession) -> NSURLRequestPromise {
        
        let promise = NSURLRequestPromise()
        
        session.dataTaskWithRequest(request){ (data, response, nError) -> Void in
            
            if nError != nil {
                promise.reject(nError)
            }
            
            promise.resolve()(data: data, response: response, error: nError)
            }.resume()
        
        return promise
    }
}


extension ThereClient {
    
    private func locationsWithData(data:NSData?) -> Either<NSError, [ThereLocation]> {
        
        if let maybeData = data {
            
            var jsonObjError:NSError?
            let maybeResponse = NSJSONSerialization.JSONObjectWithData(maybeData, options: NSJSONReadingOptions(0), error: &jsonObjError) as? [String:AnyObject]
            
            if let data = maybeResponse {
                
                if let response = data["Response"] as? [String:AnyObject] {
                    
                    // Singular noun for something that is acutally a list.
                    if let views = response["View"] as? [AnyObject] {
                        
                        if views.count > 0 {
                            
                            if let aView = views[0] as? [String:AnyObject] {
                                
                                // Same here, singular noun but this is actually an list in the api.
                                if let results = aView["Result"] as? [AnyObject] {
                                    var locations = [ThereLocation]()
                                    
                                    for aRusult in results {
                                        
                                        if let res = aRusult as? [String:AnyObject] {
                                            
                                            if let location = res["Location"] as? [String:AnyObject] {
                                                
                                                var hasDisplayPosition = false
                                                if let displayPosition = location["DisplayPosition"] as? [String:AnyObject] {
                                                    hasDisplayPosition = true
                                                }
                                                
                                                var hasAddress = false
                                                if let address = location["Address"] as? [String:AnyObject] {
                                                    hasAddress = true
                                                }
                                                
                                                if hasAddress && hasDisplayPosition {

                                                    let address = location["Address"] as! [String:AnyObject]
                                                    let addressLabel = address["Label"] as! String
/*"༼つಠ益ಠ༽つ ─=≡ΣO)) HADOUKEN"*/
                                                    let displayPosition = location["DisplayPosition"] as! [String:AnyObject]
                                                    let lat = displayPosition["Latitude"] as! Double
                                                    let lon = displayPosition["Longitude"] as! Double
                                                    
                                                    locations = locations + [ThereLocation(lat: lat, lon: lon, address: addressLabel)]
                                                }
                                                else {
                                                    return self.malformedLocationJSONError()
                                                }
                                            }
                                        }
                                        else {
                                            return self.malformedLocationJSONError()
                                        }
                                    }
                                    
                                    if locations.count > 0 {
                                        return Either.Right(Box(value:locations))
                                    }
                                }
                            }
                        }
                    }
                }
                else {
                    
                    //Some key are upper case, some are lower case
                    if let type = data["type"] as? String,
                        let details = data["Details"] as? String {
                            
                            return self.malformedLocationJSONError(message:details)
                    }
                }
            }
        }
        
        return self.malformedLocationJSONError()
    }
    
    
    private func wayPointsWithData(data:NSData?) -> Either<NSError, [ThereWayPoint]> {
        
        if let maybeData = data {
            
            var jsonObjError:NSError?
            let maybeResponse = NSJSONSerialization.JSONObjectWithData(maybeData, options: NSJSONReadingOptions(0), error: &jsonObjError) as? [String:AnyObject]
            
            if let data = maybeResponse {
                // Response is lowercase here... and upper case in the geocoding response...
                if let response = data["response"] as? [String:AnyObject] {
                    
                    // Singular noun for something that is acutally a list.
                    if let routes = response["route"] as? [AnyObject] {
                        
                        if routes.count > 0 {
                            
                            if let aRoute = routes[0] as? [String:AnyObject] {
                                
                                // Singular noun for something that is acutally a list.
                                if let legs = aRoute["leg"] as? [AnyObject] {
                                    
                                    var points = [ThereWayPoint]()
                                    
                                    for aLeg in legs {
                                        
                                        if let aLeg = aLeg as? [String:AnyObject] {
                                        
                                            // Singular noun for something that is acutally a list.
                                            if let maneuvers = aLeg["maneuver"] as? [[String:AnyObject]] {
                                                
                                                for aManeuver in maneuvers {
                                                    
                                                    if let position = aManeuver["position"] as? [String:AnyObject] {
                                                        
                                                        if  let error = self.addWayPointTo(&points, forMappedPosition:position) {
                                                            
                                                            return malformedWayPointJSONError()
                                                        }
                                                        else {
                                                            LogDebug("Leg: \(aLeg) - WayPoint: \(points.last)")
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    if points.count > 0 {
                                        
                                        return Either.Right(Box(value: points))
                                    }
                                }
                            }
                        }
                    }
                }
                else {
                    
                    //Details is lowercase here but uppercase for the other api
                    if let type = data["type"] as? String,
                        let details = data["details"] as? String {
                            
                            return self.malformedWayPointJSONError(message:details)
                    }
                }
            }
        }
        
        return self.malformedWayPointJSONError()
    }
    
    private func addWayPointTo(inout points:[ThereWayPoint], forMappedPosition mappedPosition:[String:AnyObject]) -> NSError? {
    
        if let lat = mappedPosition["latitude"] as? Double, let lon = mappedPosition["longitude"] as? Double {
            
            points = points + [ThereWayPoint(lat:lat, lon:lon)]
            return nil
        }
        else {
            
            return self.defaultRoutingVaidationError
        }
    }
    
    private func malformedLocationJSONError(message:String? = nil) -> Either<NSError, [ThereLocation]> {
        
        if let message = message {
            
            return Either.Left(Box(value: self.validationErrorWithMessage(message)))
        }
        else {
           return Either.Left(Box(value: self.defaultSearchValidationError))
        }
    }
    
    private func validationErrorWithMessage(message:String) -> NSError {
        
        return NSError(domain: ThereErrorDomain,
            code:ThereError.MalformedJSON.rawValue,
            userInfo:[NSLocalizedDescriptionKey:message])
    }
    
    private var defaultRoutingVaidationError: NSError {
        
        return self.validationErrorWithMessage("JSON does not pass validation for routing")
    }
    
    private var defaultSearchValidationError: NSError {
        return  self.validationErrorWithMessage("JSON does not pass validation for search")
    }
    
    private func malformedWayPointJSONError(message:String? = nil) -> Either<NSError, [ThereWayPoint]> {
        
        if let message = message {
            
            return Either.Left(Box(value: self.validationErrorWithMessage(message)))
        }
        else {
            return Either.Left(Box(value: self.defaultRoutingVaidationError))
        }
    }
}
