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
