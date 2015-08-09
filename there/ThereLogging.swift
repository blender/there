//
//  ThereLogging.swift
//  there
//
//  Created by Tommaso Piazza on 08/08/15.
//  Copyright (c) 2015 Alloc Init. All rights reserved.
//

import Foundation



public enum ThereLogLevel: Int, Comparable {
    
    case Verbose = 0
    case Debug
    case Info
    case Warning
    case Error
}

public func ==(x: ThereLogLevel, y: ThereLogLevel) -> Bool { return x.rawValue == y.rawValue }
public func <(x: ThereLogLevel, y: ThereLogLevel) -> Bool { return x.rawValue < y.rawValue }



func Log(message: String,
    function: String = __FUNCTION__,
    file: String = __FILE__,
    line: Int = __LINE__,
    level:ThereLogLevel) {
        
        if ThereClient.logLevel <= level {
            
            NSLog("\"\(message)\" (File: \(file), Function: \(function), Line: \(line))")
        }
}

func LogVerbose(message:String,
    function: String = __FUNCTION__,
    file: String = __FILE__,
    line: Int = __LINE__){
        
        Log(message, function:function, file:file, line:line, ThereLogLevel.Verbose)
}

func LogDebug(message:String,
    function: String = __FUNCTION__,
    file: String = __FILE__,
    line: Int = __LINE__){
        
        Log(message, function:function, file:file, line:line, ThereLogLevel.Debug)
}

func LogInfo(message:String,
    function: String = __FUNCTION__,
    file: String = __FILE__,
    line: Int = __LINE__){
        
        Log(message, function:function, file:file, line:line, ThereLogLevel.Info)
}

func LogWarn(message:String,
    function: String = __FUNCTION__,
    file: String = __FILE__,
    line: Int = __LINE__){
        
        Log(message, function:function, file:file, line:line, ThereLogLevel.Warning)
}

func LogError(message:String,
    function: String = __FUNCTION__,
    file: String = __FILE__,
    line: Int = __LINE__){
        
        Log(message, function:function, file:file, line:line, ThereLogLevel.Error)
}
