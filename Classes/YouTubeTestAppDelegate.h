//
//  YouTubeTestAppDelegate.h
//  YouTubeTest
//
//  Created by Uri Nieto on 10/15/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YouTubeTestViewController;

@interface YouTubeTestAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    YouTubeTestViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet YouTubeTestViewController *viewController;

@end

