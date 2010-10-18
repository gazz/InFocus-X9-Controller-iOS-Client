//
//  ProjectorViewController.h
//  InfocusController_iOSClient
//
//  Created by Janis Dancis on 10/18/10.
//  Copyright 2010 digihaze. All rights reserved.
//
#import <UIKit/UIKit.h>


enum {
	kSomeWeirdError = 1
} typedef ConnectionErrorCode;

struct {
	BOOL isConnected;
	BOOL isOn;
	UInt32 source;
	BOOL isSourceLocked;
	UInt32 displayMode;
	SInt32 brightness;
	SInt32 contrast;
	ConnectionErrorCode error;
} typedef ProjectorStatus;

@interface ProjectorViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate> {
	NSString *baseURL;
	// controls
	UIPickerView *sourcesPicker;
	UIPickerView *displayModesPicker;
	UILabel *statusLabel;
	UISwitch *powerSwitch;
	UISwitch *sourceLockSwitch;
	UIButton *sourceSelectButton;
	UIButton *displayModeSelectButton;
	UISlider *brightnessSlider;
	UISlider *contrastSlider;
	
	UIButton *tmpPickerButton;
	UIPickerView *activePicker;
	
	NSArray *sources;
	NSArray *displayModes;
	
	// web loading
	NSMutableData *receivedData;
	
}

@property (nonatomic, retain) NSString *baseURL;
// controls
@property (nonatomic, retain) IBOutlet UIPickerView *sourcesPicker;
@property (nonatomic, retain) IBOutlet UIPickerView *displayModesPicker;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UISwitch *powerSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *sourceLockSwitch;
@property (nonatomic, retain) IBOutlet UIButton *sourceSelectButton;
@property (nonatomic, retain) IBOutlet UIButton *displayModeSelectButton;
@property (nonatomic, retain) IBOutlet UISlider *brightnessSlider;
@property (nonatomic, retain) IBOutlet UISlider *contrastSlider;

// misc retainable props
@property (nonatomic, retain) NSArray *sources;
@property (nonatomic, retain) NSArray *displayModes;
@property (nonatomic, retain) UIButton *tmpPickerButton;

-(IBAction) pickValue:(id)sender;

-(void) queryStatus;
-(void) updateStatus:(NSValue*)status;

-(void) togglePower:(id)sender;
-(void) toggleSourceLock:(id)sender;
-(void) adjustSlider:(id)sender;

-(void) sendMessage:(NSString*)message withValue:(SInt32)value;


@end
