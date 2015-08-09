//
//  ThereRequestGenerator.swift
//  there
//
//  Created by Tommaso Piazza on 08/08/15.
//  Copyright (c) 2015 Alloc Init. All rights reserved.
//

import Foundation

internal class ThereRequestGenerator {
    
    static let geoCodederHost:String = "geocoder.cit.api.here.com"
    static let routeHost:String = "route.cit.api.here.com"
    static let routingPath:String = "/routing"
    static let requestScheme:String = "https"
    
    static let searchEndpoint:String = "geocode.json"
    static let routeEndpoint:String = "calculateroute.json"
    
    let appId:String
    let appCode:String
    
    init(appId:String, appCode:String){
        self.appId = appId
        self.appCode = appCode
    }
    
    private func appCreantialsQuery() -> String {
        
        return "app_id=\(self.appId)&app_code=\(self.appCode)"
    }
    
    internal func searchRequestWithParameters(term:String) -> Either<NSError, NSURLRequest> {
        
        switch self.requestWithParameters(ThereRequestGenerator.geoCodederHost,
            apiVersion:6.2,
            endPoint:ThereRequestGenerator.searchEndpoint,
            query:self.appCreantialsQuery()) {
            
        case .Left(let box):
            return Either.Left(box)
        case .Right(let box):
            let url:NSURL! = box.value.URL
            let escapedSearchTerm = self.escape(term)
            let finalSearchTerm = escapedSearchTerm ?? ""
            LogDebug("Escaped search term from \(term) to \(finalSearchTerm)")
            let finalURLString = url.absoluteString!+"&searchtext=\(finalSearchTerm)"
            LogDebug("Create request with URL: \(finalURLString)")
            return Either.Right(Box(value: NSURLRequest(URL: NSURL(string: finalURLString)!)))
        }
    }
    
    internal func routeRequestWithParameters(wayPoints:[(Double, Double)],
        mode:String) -> Either<NSError, NSURLRequest> {
    
        if wayPoints.count < 2 {
            return Either.Left(Box(value: NSError(domain: ThereErrorDomain,
                code: ThereError.MalformedParameters.rawValue,
                userInfo:[NSLocalizedDescriptionKey:"A routing request required 2 or more waypoints."])))
        }
        
        let wayPointsAsStrings = wayPoints.map { (lat, lon) -> String in
            return String(format:"%f,%f", lat,lon)
        }
        
        let enumeration = enumerate(0 ... wayPointsAsStrings.count-1)
        
        let wayPointsWithWayPointIndex:[String] = map(enumeration){ (index, element)  in
            let singleWayPointQueryString = "waypoint\(index)=\(wayPointsAsStrings[index])"
            return singleWayPointQueryString
        }
        
        let allWayPointsQueryString = "&".join(wayPointsWithWayPointIndex)
        let queryString = allWayPointsQueryString + "&mode=\(mode)" + "&" + self.appCreantialsQuery()
        
        switch self.requestWithParameters(ThereRequestGenerator.routeHost,
            path:ThereRequestGenerator.routingPath,
            apiVersion:7.2,
            endPoint:ThereRequestGenerator.routeEndpoint,
            query:queryString) {
            
        case .Left(let box):
            return Either.Left(box)
        case .Right(let box):
            let url:NSURL! = box.value.URL
            return Either.Right(Box(value: NSURLRequest(URL: url)))
        }
    }
    
    private func requestWithParameters(host:String,
        path:String?=nil,
        apiVersion:Double,
        endPoint:String,
        query:String? = nil) -> Either<NSError, NSURLRequest> {
        
        let components = NSURLComponents()
        
        components.scheme = ThereRequestGenerator.requestScheme
        components.host = host
        
        let versionPath = String(format:"/%.1f", apiVersion)
        
        var finalPath = ""
        
        if let path = path {
            finalPath = finalPath + path
        }
        
        finalPath = finalPath.stringByAppendingPathComponent(versionPath).stringByAppendingPathComponent(endPoint)

        components.path = finalPath
        components.query = query ?? ""
        
        if let requestURL = components.URL {
            
            return Either.Right(Box(value: NSURLRequest(URL: requestURL)))
        }
        else {
            
            let invalidURL = ThereRequestGenerator.requestScheme + "://" + host.stringByAppendingPathComponent(finalPath).stringByAppendingPathComponent(query ?? "")
            
            return Either.Left(Box(value: NSError(domain: ThereErrorDomain,
                code: ThereError.MalformedURL.rawValue,
                userInfo:[NSLocalizedDescriptionKey:invalidURL + " is not a valid URL"])))
        }
    }
    
    private func escape(string: String) -> String {
        
        let funkyChars = "!*'\"();:@&=+$,/?%#[]% "
        
        let legalURLCharactersToBeEscaped: CFStringRef = funkyChars
        return CFURLCreateStringByAddingPercentEscapes(nil, string, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue) as String
    }

}