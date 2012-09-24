//
//  BMEAppDelegate.m
//  BeMyEyes
//
//  Created by Morten Bøgh on 15/09/12.
//  Copyright (c) 2012 Morten Bøgh. All rights reserved.
//

#import "BMEAppDelegate.h"
#import "BMELoginViewController.h"

@implementation BMEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#warning implement user session feature
    [self.window makeKeyAndVisible];
    if (YES) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        UINavigationController *loginNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"BMELoginNavigationController"];
        
        [self.window.rootViewController presentModalViewController:loginNavigationController animated:NO];
    }
    return YES;
}
							
@end
