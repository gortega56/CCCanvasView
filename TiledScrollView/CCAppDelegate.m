//
//  CCAppDelegate.m
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/7/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCAppDelegate.h"
#import "CCTileScrollViewController.h"
#import "CCWebViewController.h"
@implementation CCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
 //   self.window.rootViewController = [[CCTileScrollViewController alloc] init];
    self.window.rootViewController = [[CCWebViewController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
