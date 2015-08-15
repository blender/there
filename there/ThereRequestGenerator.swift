//    The MIT License (MIT)
//
//    Copyright (c) <2015> <Tommaso Piazza>
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in
//    all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//    THE SOFTWARE.

import Foundation

// This is public for testing reasons. In Swift 2.0 this would have visibility "testable"

public class ThereRequestGenerator {
    
    static let geoCodederHost:String = "geocoder.cit.api.here.com"
    static let routeHost:String = "route.cit.api.here.com"
    static let routingPath:String = "/routing"
    static let requestScheme:String = "https"
    
    static let searchEndpoint:String = "geocode.json"
    static let routeEndpoint:String = "calculateroute.json"
    
    let appId:String
    let appCode:String
    
    public init(appId:String, appCode:String){
        self.appId = appId
        self.appCode = appCode
    }
    
    private func appCreantialsQuery() -> String {
        
        return "app_id=\(self.appId)&app_code=\(self.appCode)"
    }
    
    public func searchRequestWithParameters(term:String) -> Either<NSError, NSURLRequest> {
        
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
            LogDebug("Created request with URL: \(finalURLString)")
            return Either.Right(Box(value: NSURLRequest(URL: NSURL(string: finalURLString)!)))
        }
    }
    
    public func routeRequestWithParameters(wayPoints:[(Double, Double)],
        mode:ThereRoutingMode) -> Either<NSError, NSURLRequest> {
    
        if wayPoints.count < 2 {
            return Either.Left(Box(value: NSError(domain: ThereErrorDomain,
                code: ThereError.MalformedParameters.rawValue,
                userInfo:[NSLocalizedDescriptionKey:"A routing request requires 2 or more waypoints."])))
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
        let queryString = allWayPointsQueryString + "&mode=\(mode.rawValue)" + "&" + self.appCreantialsQuery()
        
        switch self.requestWithParameters(ThereRequestGenerator.routeHost,
            path:ThereRequestGenerator.routingPath,
            apiVersion:7.2,
            endPoint:ThereRequestGenerator.routeEndpoint,
            query:queryString) {
            
        case .Left(let box):
            return Either.Left(box)
        case .Right(let box):
            let url:NSURL! = box.value.URL
            LogDebug("Created request with URL: \(url)")
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