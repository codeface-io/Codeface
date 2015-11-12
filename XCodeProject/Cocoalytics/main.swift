//
//  main.swift
//  Cocoalytics
//
//  Created by Sebastian Fichtner on 22/10/15.
//  Copyright © 2015 Flowtoolz. All rights reserved.
//

import Foundation

func run()
{
    // get code file paths
    let codeDirectory = "/Users/sfichtner/Desktop/LondonReal/XcodeProject/Code/"
    
    let filePaths = absolutePathsOfFilesInDirectory(codeDirectory,
        fileExtensiion: ".swift")
    
    // print code file paths
    for filePath in filePaths
    {
        print(filePath)
    }
    
    // example: access file content
    var fileContent: String?
    
    do
    {
        fileContent = try String(contentsOfFile: filePaths[0])
    }
    catch
    {
        
    }
    
    guard let _ = fileContent else
    {
        return
    }
    
    print(fileContent!)
}

func absolutePathsOfFilesInDirectory(directoryPath: String,
    fileExtensiion: String) -> [String]
{
    let filemanager = NSFileManager()
    
    var filePaths = [String]()
    
    if let enumerator = filemanager.enumeratorAtPath(directoryPath)
    {
        let objects = enumerator.allObjects
        
        for object in objects
        {
            let path = object as! String

            if path.hasSuffix(fileExtensiion)
            {
                filePaths.append(directoryPath + path)
            }
        }
    }
    
    return filePaths
}

run()



