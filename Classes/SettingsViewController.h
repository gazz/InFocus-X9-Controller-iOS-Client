//
//  SettingsViewController.h
//  InfocusController_iOSClient
//
//  Created by Janis Dancis on 10/18/10.
//  Copyright 2010 digihaze. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ProjectorViewController.h"

@interface SettingsViewController : UIViewController {
	ProjectorViewController *projectorController;
}

@property (assign) IBOutlet ProjectorViewController *projectorController;

-(IBAction) editingDidEnd:(id)sender;

@end
