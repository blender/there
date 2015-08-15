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

// MARK: Constants

let ThereErrorDomain = "com.allocinit.there"

// MARK: Public stuff

public enum ThereError:Int {
    
    case MalformedURL = -1001
    case MalformedParameters
    case MalformedJSON
}

public enum ThereRoutingMode:String {
    
    case FastestCar = "fastest;car"
}

public enum Either<T,U> {
    
    case Left(Box<T>)
    case Right(Box<U>)
}

public final class Box<T> {
    public let value: T
    
    public init(value: T) {
        self.value = value
    }
}

// MARK: Internal Stuff

func performOnQueue(callBackQueue:dispatch_queue_t, a:()->() ){
    
    dispatch_async(callBackQueue, a)
}


typealias NSURLRequestCallBack = (data:NSData!, response:NSURLResponse!, error:NSError!)->NSError?

class NSURLRequestPromise {
    
    var pending:[NSURLRequestCallBack] = []
    var onFailure:(error:NSError)->() = { error in return }
    var failure:NSError? = nil
    
    func resolve() -> NSURLRequestCallBack {
        
        func performAResolution(data:NSData!, response:NSURLResponse!, error:NSError!)->NSError? {
            
            if error != nil {
                
                onFailure(error: error!)
                return nil
            }
            
            for f in self.pending {
                
                self.failure = f(data: data, response: response, error: error)
                
                if let error = self.failure {
                    
                    onFailure(error: error)
                    break
                }
            }
            
            return nil
        }
        
        return performAResolution
    }
    
    func fail(onFailure:(error:NSError) ->()) -> NSURLRequestPromise {
        
        self.onFailure = onFailure
        return self
    }
    
    func reject(error:NSError) {
        
        self.failure = error
    }
    
    func then(what:NSURLRequestCallBack)->NSURLRequestPromise {
        
        self.pending.append(what)
        return self
    }
}