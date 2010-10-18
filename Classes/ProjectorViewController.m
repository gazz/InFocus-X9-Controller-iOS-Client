//
//  ProjectorViewController.m
//  InfocusController_iOSClient
//
//  Created by Janis Dancis on 10/18/10.
//  Copyright 2010 digihaze. All rights reserved.
//

#import "ProjectorViewController.h"

#import "CJSONDeserializer.h"


@implementation ProjectorViewController

@synthesize baseURL;
@synthesize sourcesPicker, displayModesPicker, 
	sources, displayModes, tmpPickerButton,
	statusLabel, powerSwitch, sourceLockSwitch,
	sourceSelectButton, displayModeSelectButton,
	brightnessSlider, contrastSlider;

- (void)viewDidAppear:(BOOL)animated {
//	self.baseURL = @"http://192.168.1.51:64299";
	self.baseURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"baseURL"];
	if (baseURL==nil) {
		self.baseURL = @"http://192.168.1.51:64299";
		[[NSUserDefaults standardUserDefaults] setObject:baseURL forKey:@"baseURL"];
	}

    // Override point for customization after application launch.
	self.sources = [NSArray arrayWithObjects:@"Computer", @"Component", @"S-Video", 
					@"Composite", @"DVI", @"SCART", @"HDMI", nil];
	self.displayModes = [NSArray arrayWithObjects:@"PC", @"Movie", @"sRGB", 
						 @"Game", @"User", nil];
	
	ProjectorStatus status;
	status.isConnected = NO;
	status.isOn = NO;
	[self updateStatus:[NSValue valueWithPointer:&status]];
}

-(void) dealloc {
	[receivedData release];
	
	[baseURL release];
	[tmpPickerButton release];
	// controls
	[sourcesPicker release];
	[displayModesPicker release];
	[statusLabel release];
	[powerSwitch release];
	[sourceLockSwitch release];
	[sourceSelectButton release];
	[displayModeSelectButton release];
	[brightnessSlider release];
	[contrastSlider release];
	
	[sources release];
	[displayModes release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark Controls responders

-(void) togglePower:(id)sender {
	[self sendMessage:@"PWR" withValue:powerSwitch.on ];
}

-(void) toggleSourceLock:(id)sender {
	[self sendMessage:@"SRL" withValue:sourceLockSwitch.on ];
}

-(void) adjustSlider:(id)sender {
	NSString *msg = nil;
	if ([sender isEqual:brightnessSlider]) {
		msg = @"BRI";
	} else if ([sender isEqual:contrastSlider]) {
		msg = @"CON";
	}
	if (msg==nil)
		return;
	UISlider *slider = sender;
	[self sendMessage:msg withValue:[slider value]];
}


#pragma mark -
#pragma mark Query Projector Controller through web

-(void) sendMessage:(NSString*)message withValue:(SInt32)value {
	if (receivedData!=nil) {
		// there must be some error
		return;
	}
	NSString *msg = [NSString stringWithFormat:@"%@/%@/%d.JSON", baseURL, message, value];
	NSURLRequest *theRequest= [NSURLRequest requestWithURL:[NSURL URLWithString:msg]
											   cachePolicy:NSURLRequestUseProtocolCachePolicy
										   timeoutInterval:60.0];
	// create the connection with the request
	// and start loading the data
	NSURLConnection *theConnection= [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection) {
		// Create the NSMutableData to hold the received data.
		// receivedData is an instance variable declared elsewhere.
		receivedData = [[NSMutableData data] retain];
	} else {
		// Inform the user that the connection failed.
		ProjectorStatus status;
		status.isConnected = NO;
		status.isOn = NO;
		status.error = kSomeWeirdError;
		[self performSelectorOnMainThread:@selector(updateStatus:) withObject:[NSValue valueWithPointer:&status] waitUntilDone:YES];
	}
}

-(void) queryStatus {
	// async request to query status of projector
	// Create the request.
	NSURLRequest *theRequest= [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/.JSON", baseURL]]
											   cachePolicy:NSURLRequestUseProtocolCachePolicy
										   timeoutInterval:60.0];
	// create the connection with the request
	// and start loading the data
	NSURLConnection *theConnection= [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection) {
		// Create the NSMutableData to hold the received data.
		// receivedData is an instance variable declared elsewhere.
		receivedData = [[NSMutableData data] retain];
	} else {
		// Inform the user that the connection failed.
		ProjectorStatus status;
		status.isConnected = NO;
		status.isOn = NO;
		status.error = kSomeWeirdError;
		[self performSelectorOnMainThread:@selector(updateStatus:) withObject:[NSValue valueWithPointer:&status] waitUntilDone:YES];
	}
}

-(void) updateStatus:(NSValue*)statusValue {
	ProjectorStatus status = *((ProjectorStatus*)[statusValue pointerValue]);
	if (status.isConnected) {
		statusLabel.text = @"Connected";
	} else {
		statusLabel.text = @"Not Connected";
	}
	
	if (!status.isConnected || !status.isOn) {
		// disable all controls
		powerSwitch.enabled = status.isConnected;
		sourceSelectButton.enabled = NO;
		sourceLockSwitch.enabled = NO;
		displayModeSelectButton.enabled = NO;
		brightnessSlider.enabled = NO;
		contrastSlider.enabled = NO;
		// try to perform query status in 3 secs
		[self performSelector:@selector(queryStatus) withObject:nil afterDelay:3];
	} else {
		powerSwitch.enabled = YES;
		powerSwitch.on = status.isOn;
		sourceLockSwitch.enabled = YES;
		sourceLockSwitch.on = status.isSourceLocked;
		
		// source select
		sourceSelectButton.enabled = YES;
		[sourceSelectButton setTitle:[self pickerView:sourcesPicker titleForRow:status.source forComponent:0] 
							forState:UIControlStateNormal];
		[sourcesPicker selectRow:status.source inComponent:0 animated:NO];
		// display mode select
		displayModeSelectButton.enabled = YES;
		[displayModeSelectButton setTitle:[self pickerView:displayModesPicker titleForRow:status.displayMode forComponent:0] 
								 forState:UIControlStateNormal];
		[displayModesPicker selectRow:status.displayMode inComponent:0 animated:NO];
		
		// brightness & contrast
		brightnessSlider.enabled = YES;
		brightnessSlider.value = status.brightness;
		contrastSlider.enabled = YES;
		contrastSlider.value = status.contrast;
	}
}


-(IBAction) pickValue:(id)sender {
	if (tmpPickerButton!=nil) {
		[tmpPickerButton setHidden:NO];
		[activePicker setHidden:YES];
		// release tmp button
		self.tmpPickerButton = nil;
		activePicker = nil;
	}
	self.tmpPickerButton = sender;
	[tmpPickerButton setHidden:YES];
	if ([sender tag]==0) {
		// source picker
		[sourcesPicker setHidden:NO];
		// offset - 142x45
		activePicker = sourcesPicker;
	} else {
		// display mode picker
		[displayModesPicker setHidden:NO];
		// offset - 142x127
		activePicker = displayModesPicker;
	}
}


#pragma mark -
#pragma mark UIPickerView data source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	if ([pickerView isEqual:sourcesPicker]) {
		return [sources count];
	} else if ([pickerView isEqual:displayModesPicker]) {
		return [displayModes count];
	}
	return 0;
}

#pragma mark -
#pragma mark UIPickerView delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	if ([pickerView isEqual:sourcesPicker]) {
		return [sources objectAtIndex:row];
	} else if ([pickerView isEqual:displayModesPicker]) {
		return [displayModes objectAtIndex:row];
	}
	return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	[tmpPickerButton setTitle:[self pickerView:pickerView titleForRow:row forComponent:0] forState:UIControlStateNormal];
	// hide picker view
	[tmpPickerButton setHidden:NO];
	[pickerView setHidden:YES];
	// release tmp button
	self.tmpPickerButton = nil;
	activePicker = nil;
	
	// send message
	NSString *msg = nil;
	if ([pickerView isEqual:sourcesPicker]) {
		msg = @"SRC";
	} else if ([pickerView isEqual:displayModesPicker]) {
		msg = @"DSP";
	}
	if (msg==nil)
		return;	
	[self sendMessage:msg withValue:row];
}

#pragma mark -
#pragma mark NSURlConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
	
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
	
    // receivedData is an instance variable declared elsewhere.
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
	
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
	//    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	
	//	// deserialize received data and toggle app status
	//	NSString *data = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	CJSONDeserializer *deserializer = [CJSONDeserializer deserializer];
	NSError *error;
	NSDictionary *dictValues = [deserializer deserialize:receivedData error:&error];
	
    // release the connection, and the data object
    [connection release];
    [receivedData release];
	receivedData = nil;
	
	if (error!=nil) {
		NSLog(@"Error deserializing: %@", error);
	}
	NSLog(@"ReceivedValues: %@", dictValues);
	
	if ([dictValues objectForKey:@"result"]==nil) {
		ProjectorStatus status;
		status.isConnected = [[dictValues objectForKey:@"CNC"] boolValue];
		status.isOn = [[dictValues objectForKey:@"PWR"] boolValue];
		status.source = [[dictValues objectForKey:@"SRC"] intValue];
		status.isSourceLocked = [[dictValues objectForKey:@"SRL"] boolValue];
		status.displayMode = [[dictValues objectForKey:@"DSP"] intValue];
		status.brightness = [[dictValues objectForKey:@"BRI"] intValue];
		status.contrast = [[dictValues objectForKey:@"CON"] intValue];
		[self performSelectorOnMainThread:@selector(updateStatus:) withObject:[NSValue valueWithPointer:&status] waitUntilDone:YES];
	}
	
}



@end
