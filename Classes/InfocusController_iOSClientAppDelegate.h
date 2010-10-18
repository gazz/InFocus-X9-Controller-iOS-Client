//
//  InfocusController_iOSClientAppDelegate.h
//  InfocusController_iOSClient
//
//  Created by Janis Dancis on 10/18/10.
//  Copyright digihaze 2010. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InfocusController_iOSClientAppDelegate : NSObject <UIApplicationDelegate> {
	
    UIWindow *window;
	UITabBarController *rootController;
	
}


@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *rootController;




@end

