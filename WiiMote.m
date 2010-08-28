//
//  WiiMote.m
//  GoogleEarthController
//
//  Created by Tim Groeneboom on 2/6/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "WiiMote.h"

@implementation WiiMote

- (void)Initialize: (int) _Num
{
	_azimuth = 0;
	isActiveBool = FALSE;
	wiiremoteX = wiiremoteY = wiiremoteZ = 0;
	nunchuckX = nunchuckY = nunchuckZ = 0;

	_delegate = nil;
	
	Num = _Num;
}

- (int)getNum
{
	return Num;
}

- (void) startDiscovery
{
	//instantiate WiiRemoteDiscovery and starts inquiry
	_discovery = [[WiiRemoteDiscovery alloc] init];
	[_discovery setDelegate:self];
	[_discovery start];
}

- (void) stopDiscovery
{
	//instantiate WiiRemoteDiscovery and starts inquiry
	[_discovery stop];
}

- (void) setLed: (BOOL) enable1 : (BOOL) enable2 : (BOOL) enable3 : (BOOL) enable4
{
	led1 = enable1;
	led2 = enable2;
	led3 = enable3;
	led4 = enable4;
	
	if(_wii) [_wii setLEDEnabled1:led1 enabled2:led2 enabled3:led3 enabled4:led4];
}

- (void) setVibration: (BOOL) enable
{
	[_wii setForceFeedbackEnabled:enable];
}

- (void) closeConnection
{
	//do forget to close connection.
	[_wii closeConnection];
	[_wii release];
	isActiveBool = FALSE;
}

- (BOOL) isActive
{
	return isActiveBool;
}

- (void) WiiRemoteDiscovered:(WiiRemote*)wiimote
{
	// stops Bluetooth inquiry
	[_discovery stop];
	if(!isActiveBool){
	
		//wiimote settings
		_wii = wiimote;

		[_wii setLEDEnabled1:led1 enabled2:led2 enabled3:led3 enabled4:led4];
	
		isActiveBool = TRUE;
		
		[_wii setExpansionPortEnabled:YES];
		[_wii setIRSensorEnabled:YES];
		[_wii setMotionSensorEnabled:YES];

		[_wii setDelegate:self];
		
		remoteAccCalibData = [_wii accCalibData:WiiRemoteAccelerationSensor];

		[_delegate WiiMoteDiscovered : self];
		
		// set listener
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(expansionPortChanged) name:@"WiiRemoteExpansionPortChangedNotification" object:_wii];
	}
}

// === Listening method ===
- (void) expansionPortChanged
{
	if([_wii expansionPortType] == WiiNunchuk){
		NSLog(@"Nunchuck attached");
		[_wii setExpansionPortEnabled:YES];
		[_wii setIRSensorEnabled:YES];
		[_wii setMotionSensorEnabled:YES];
	}else if([_wii expansionPortType] == WiiClassicController){
		NSLog(@"Classic controller attached");
		[_wii setExpansionPortEnabled:YES];
		[_wii setIRSensorEnabled:YES];
		[_wii setMotionSensorEnabled:YES];
	}
}

- (void) irPointMovedX:(float)px Y:(float)py ANGLE:(float)angle tracking:(BOOL)_irTracking wiiRemote:(WiiRemote*)wiiRemote
{
	irPointX = px;
	irPointY = py;
	irAngle = angle;
	irTracking = _irTracking;
}

// === WiiRemote delegates ===
- (void) accelerationChanged:(WiiAccelerationSensorType)type accX:(unsigned char)accX accY:(unsigned char)accY accZ:(unsigned char)accZ wiiRemote:(WiiRemote*)wiiRemote
{
	switch (type) {
		case WiiRemoteAccelerationSensor:
			remoteAccCalibData = [_wii accCalibData:WiiRemoteAccelerationSensor];

			wiiremoteX = accX;
			wiiremoteY = accY;
			wiiremoteZ = accZ;
			break;
		case WiiNunchukAccelerationSensor:
			nunchuckAccCalibData = [_wii accCalibData:WiiNunchukAccelerationSensor];
			
			nunchuckX = accX;
			nunchuckY = accY;
			nunchuckZ = accZ;
			break;
	}
}

- (WiiExpansionPortType)getExpansionPortType
{
	return [_wii expansionPortType];
}

- (void) reportRemoteButtonData:(UInt16)_data wiiRemote:(WiiRemote*)wiiRemote
{
	//NSLog(@"reporting button data");
	remoteButtonData = _data;
}

- (void) reportNunchuckButtonData:(UInt16)_data wiiRemote:(WiiRemote*)wiiRemote
{
	//NSLog(@"reporting button data");
	nunchuckButtonData = _data;
}

- (void) reportClassicControllerButtonData:(UInt16)_data wiiRemote:(WiiRemote*)wiiRemote
{
	//NSLog(@"reporting button data");
	classicControllerButtonData = _data;
}

- (void) analogButtonChanged:(WiiButtonType)type amount:(unsigned)press wiiRemote:(WiiRemote*)wiiRemote
{
	switch (type) {
		case WiiClassicControllerLeftButton:
			analogButtonLeft = press;
			break;
		case WiiClassicControllerRightButton :
			analogButtonRight = press;
			break;
	}
}

- (void) joyStickChanged:(WiiJoyStickType)type tiltX:(unsigned char)tiltX tiltY:(unsigned char)tiltY wiiRemote:(WiiRemote*)wiiRemote
{
	switch (type) {
		case WiiNunchukJoyStick:
			nunchuckJoystickX = tiltX;
			nunchuckJoystickY = tiltY;
			break;
		case WiiClassicControllerLeftJoyStick:
			classicControllerLeftJoystickX = tiltX;
			classicControllerLeftJoystickY = tiltY;
			break;
		case WiiClassicControllerRightJoyStick:
			classicControllerRightJoystickX = tiltX;
			classicControllerRightJoystickY = tiltY;
			break;
	}
}


- (void) buttonChanged:(WiiButtonType)type isPressed:(BOOL)isPressed wiiRemote:(WiiRemote*)wiiRemote
{
	;
}

- (void) wiiRemoteDisconnected:(IOBluetoothDevice*)device{
	[_wii release];
	_wii = nil;
	isActiveBool = FALSE;
}

- (id)delegate
{
    return _delegate;
}

- (void)setDelegate:(id)new_delegate
{	
    _delegate = new_delegate;
}

- (void)dealloc
{
    if (_delegate)		
		[super dealloc];
}

- (int) getRemoteX
{
	return wiiremoteX;
}

- (int) getRemoteY
{
	return wiiremoteY;
}

- (int) getRemoteZ
{
	return wiiremoteZ;
}

- (int) getNunchuckX
{
	return nunchuckX;
}

- (int) getNunchuckY
{
	return nunchuckY;
}

- (int) getNunchuckZ
{
	return nunchuckZ;
}

- (UInt16) getRemoteButtonData
{
	return remoteButtonData;
}

- (UInt16) getNunchuckButtonData
{
	return nunchuckButtonData;
}

- (UInt16) getClassicControllerButtonData
{
	return classicControllerButtonData;
}

-(UInt16) getNunchuckStickX
{
	return nunchuckJoystickX;
}

-(UInt16) getNunchuckStickY
{
	return nunchuckJoystickY;
}

-(float) getIRPointX
{
	return irPointX;
}

-(float) getIRPointY
{
	return irPointY;
}

-(float) getIRAngle
{
	return irAngle;
}

-(BOOL) getIRTracking
{
	return irTracking;
}

-(int) getClassicControllerLeftJoystickX
{
	return classicControllerLeftJoystickX;
}
-(int) getClassicControllerLeftJoystickY
{
	return classicControllerLeftJoystickY;
}

-(int) getClassicControllerRightJoystickX
{
	return classicControllerRightJoystickX;
}
-(int) getClassicControllerRightJoystickY
{
	return classicControllerRightJoystickY;
}

-(int) getClassicControllerAnalogButtonRight
{
	return analogButtonRight;
}
-(int) getClassicControllerAnalogButtonLeft;
{
	return analogButtonLeft;
}

- (void) updateRemoteCalibrationData
{
	[self updateRemoteCalibrationData];
	remoteAccCalibData = [_wii accCalibData:WiiRemoteAccelerationSensor];
}

- (void) updateNunchuckCalibrationData
{
	[self updateNunchuckCalibrationData];
	nunchuckAccCalibData = [_wii accCalibData:WiiNunchukAccelerationSensor];
	nunchuckStickCalibData = [_wii joyStickCalibData:WiiNunchukJoyStick];
}

-(int) getRemoteMotionCalibrationXZero
{
	return remoteAccCalibData.accX_zero;
}
-(int) getRemoteMotionCalibrationYZero
{
	return remoteAccCalibData.accY_zero;
}
-(int) getRemoteMotionCalibrationZZero
{
	return remoteAccCalibData.accZ_zero;
}

-(int) getRemoteMotionCalibrationX1g
{
	return remoteAccCalibData.accX_1g;
}
-(int) getRemoteMotionCalibrationY1g
{
	return remoteAccCalibData.accY_1g;
}
-(int) getRemoteMotionCalibrationZ1g
{
	return remoteAccCalibData.accZ_1g;
}


-(int) getNunchuckMotionCalibrationXZero
{
	return nunchuckAccCalibData.accX_zero;
}
-(int) getNunchuckMotionCalibrationYZero
{
	return nunchuckAccCalibData.accY_zero;
}
-(int) getNunchuckMotionCalibrationZZero
{
	return nunchuckAccCalibData.accZ_zero;
}

-(int) getNunchuckMotionCalibrationX1g
{
	return nunchuckAccCalibData.accX_1g;
}
-(int) getNunchuckMotionCalibrationY1g
{
	return nunchuckAccCalibData.accY_1g;
}
-(int) getNunchuckMotionCalibrationZ1g
{
	return nunchuckAccCalibData.accZ_1g;
}

-(int) getNunchuckStickCalibrationXMin
{
	return nunchuckStickCalibData.x_min;
}
-(int) getNunchuckStickCalibrationYMin
{
	return nunchuckStickCalibData.y_min;
}
-(int) getNunchuckStickCalibrationXCenter
{
	return nunchuckStickCalibData.x_center;
}

-(int) getNunchuckStickCalibrationXMax
{
	return nunchuckStickCalibData.x_max;
}
-(int) getNunchuckStickCalibrationYMax
{
	return nunchuckStickCalibData.y_max;
}
-(int) getNunchuckStickCalibrationYCenter
{
	return nunchuckStickCalibData.y_center;
}

@end
