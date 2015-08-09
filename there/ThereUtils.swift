//
//  ThereUtils.swift
//  there
//
//  Created by Tommaso Piazza on 08/08/15.
//  Copyright (c) 2015 Alloc Init. All rights reserved.
//

import Foundation

let ThereErrorDomain = "com.allocinit.there"

func performOnQueue(callBackQueue:dispatch_queue_t, a:()->() ){
    
    dispatch_async(callBackQueue, a)
}

public enum ThereError:Int {
    
    case MalformedURL = -1001
    case MalformedParameters
    case MalformedJSON
}

enum Either<T,U> {
    
    case Left(Box<T>)
    case Right(Box<U>)
}

final class Box<T> {
    let value: T
    
    init(value: T) {
        self.value = value
    }
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