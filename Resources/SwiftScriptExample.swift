#!/usr/bin/env xcrun swift

//
//  SwiftSum.swift
//  
//
//  Created by Robert Mißbach on 12.08.15.
//
//

var total : Int = 0

for i in 1..<Process.argc
{
    let index = Int(i)
    if let argStr = String.fromCString(Process.unsafeArgv[index])
    {
        if let argInt = Int(argStr)
        {
            total += argInt
        }
    }
}

print(total)
