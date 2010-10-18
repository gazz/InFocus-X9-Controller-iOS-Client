    //
//  SettingsViewController.m
//  InfocusController_iOSClient
//
//  Created by Janis Dancis on 10/18/10.
//  Copyright 2010 digihaze. All rights reserved.
//

#import "SettingsViewController.h"


@implementation SettingsViewController

@synthesize projectorController;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) editingDidEnd:(id)sender {
	[sender resignFirstResponder];
	UITextField *textField = sender;
	NSLog(@"New address: %@", [textField text]);
	// save to application settings
	[[NSUserDefaults standardUserDefaults] setObject:[textField text] forKey:@"baseURL"];
	// update base URL & send message to reconnect
	projectorController.baseURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"baseURL"];
}

- (void)dealloc {
    [super dealloc];
}


@end
