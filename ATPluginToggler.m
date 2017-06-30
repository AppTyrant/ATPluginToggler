//
//  ATPluginToggler.m
//  ATPluginToggler
//
//  Created by ANTHONY CRUZ on 6/30/17.
//  Copyright © 2017 Writes for All. All rights reserved.
//
/*
Permission is hereby granted, free of charge, to any person obtaining a copy  of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "ATPluginToggler.h"

#define PLUGIN_KIT_PATH @"/usr/bin/pluginkit"

@implementation ATPluginToggler

+(BOOL)isPluginWithBundleIdentifierEnabled:(NSString*)bundleIdentifier
{
    if (!doesPluginKitCommandLineToolExist())
    {
        //Just return NO to avoid NSTask exception if pluginkit is not on the system.
        return NO;
    }
    
    NSTask *task = [[NSTask alloc]init];
    task.launchPath = PLUGIN_KIT_PATH;
    task.arguments = @[@"-m",@"-A",@"-i",bundleIdentifier];
    
    //Set up the pipe.
    NSPipe *standardOutputPipe = [NSPipe pipe];
    task.standardOutput = standardOutputPipe;
    
    [task launch];
    [task waitUntilExit];
    
    int terminationStatus = task.terminationStatus;
    
    if (terminationStatus == 0)
    {
        //NSLog(@"Task succeeded.");
        NSData *standardOutData = [standardOutputPipe.fileHandleForReading readDataToEndOfFile];
        if (standardOutData.length > 0)
        {
            NSString *outString = [[[NSString alloc]initWithData:standardOutData encoding:NSUTF8StringEncoding]stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
            
            if ([outString hasPrefix:@"+"]
                || [outString hasPrefix:@"!"])
            {
                //NSLog(@"Plugin is enabled.");
                return YES;
            }
            else
            {
                //NSLog(@"Not enabled. Result:\n%@",outString);
                return NO;
            }
        }
        else
        {
            //NSLog(@"Nothing on the standard output to parse!");
            return NO;
        }
    }
    else
    {
        //NSLog(@"Task failed, assume NO.");
        return NO;
    }
}

+(BOOL)disablePluginWithBundleIdentifier:(NSString*)bundleIdentifier
{
    if (!doesPluginKitCommandLineToolExist())
    {
        //Just return NO to avoid NSTask uncaught exception if pluginkit is not on the system.
        return NO;
    }
    NSTask *task = [[NSTask alloc]init];
    task.launchPath = PLUGIN_KIT_PATH;
    task.arguments = @[@"-e",@"ignore",@"-i",bundleIdentifier];
    [task launch];
    [task waitUntilExit];
    
    int terminationStatus = task.terminationStatus;
    if (terminationStatus == 0)
    {
        return YES;
    }
    else
    {
        //NSLog(@"Task failed with: %i",terminationStatus);
        return NO;
    }
}

+(BOOL)enablePluginWithBundleIdentifier:(NSString*)bundleIdentifier
{
    if (!doesPluginKitCommandLineToolExist())
    {
        //Just return NO to avoid NSTask uncaught exception if pluginkit is not on the system.
        return NO;
    }
    NSTask *task = [[NSTask alloc]init];
    task.launchPath = PLUGIN_KIT_PATH;
    task.arguments = @[@"-e",@"use",@"-i",bundleIdentifier];
    [task launch];
    [task waitUntilExit];
    
    int terminationStatus = task.terminationStatus;
    if (terminationStatus == 0)
    {
        return YES;
    }
    else
    {
        //NSLog(@"Task failed with: %i",terminationStatus);
        return NO;
    }
}

#pragma mark - Private
static BOOL doesPluginKitCommandLineToolExist()
{
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    if ([fileManager isExecutableFileAtPath:PLUGIN_KIT_PATH])
    {
        return YES;
    }
    else
    {
        //NSLog(@"plugin kit doesn't exist. Did Apple remove the tool?");
        return NO;
    }
}

@end
