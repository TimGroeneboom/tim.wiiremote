//
//  WiiMote.h
//  GoogleEarthController
//
//  Created by Tim Groeneboom on 2/6/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "WiiRemote/WiiRemote.h"
#import "WiiRemote/WiiRemoteDiscovery.h"

@interface WiiMote : NSObject
{
	WiiRemote* _wii;
	WiiRemoteDiscovery* _discovery;
	WiiAccCalibData _accCalib;
	
	
	BOOL isActiveBool;
	double _azimuth, _distance;
		
	id _delegate;
	int Num;
	
	int wiiremoteX,wiiremoteY,wiiremoteZ;
	int nunchuckX,nunchuckY,nunchuckZ;
	
	int nunchuckJoystickX,nunchuckJoystickY;
	int classicControllerLeftJoystickX,classicControllerLeftJoystickY;
	int classicControllerRightJoystickX,classicControllerRightJoystickY;
	int analogButtonLeft,analogButtonRight;
	
	UInt16 remoteButtonData, nunchuckButtonData, classicControllerButtonData;
	float irPointX,irPointY,irAngle;
	BOOL irTracking;
	
	WiiAccCalibData remoteAccCalibData , nunchuckAccCalibData;
	WiiJoyStickCalibData nunchuckStickCalibData;
	
	bool led1,led2,led3,led4;
}

- (void) Initialize: (int) _Num;
- (void) startDiscovery;
- (void) closeConnection;
- (BOOL) isActive;
- (int) getNum;
- (void) stopDiscovery;
- (void) setLed: (BOOL) enable1 : (BOOL) enable2 : (BOOL) enable3 : (BOOL) enable4;
- (void) setVibration: (BOOL) enable;


- (int) getRemoteX;- (int) getRemoteY;- (int) getRemoteZ;
- (int) getNunchuckX;- (int) getNunchuckY;- (int) getNunchuckZ;

- (UInt16) getRemoteButtonData;
- (UInt16) getNunchuckButtonData;
- (UInt16) getClassicControllerButtonData;

-(int) getRemoteMotionCalibrationXZero;
-(int) getRemoteMotionCalibrationYZero;
-(int) getRemoteMotionCalibrationZZero;
-(int) getRemoteMotionCalibrationX1g;
-(int) getRemoteMotionCalibrationY1g;
-(int) getRemoteMotionCalibrationZ1g;

-(int) getNunchuckMotionCalibrationXZero;
-(int) getNunchuckMotionCalibrationYZero;
-(int) getNunchuckMotionCalibrationZZero;
-(int) getNunchuckMotionCalibrationX1g;
-(int) getNunchuckMotionCalibrationY1g;
-(int) getNunchuckMotionCalibrationZ1g;

-(int) getNunchuckStickCalibrationXMin;
-(int) getNunchuckStickCalibrationYMin;
-(int) getNunchuckStickCalibrationXCenter;
-(int) getNunchuckStickCalibrationXMax;
-(int) getNunchuckStickCalibrationYMax;
-(int) getNunchuckStickCalibrationYCenter;

-(BOOL) isActive;


// listining method
- (void) expansionPortChanged;

// WiiRemote Delegates

- (void) WiiRemoteDiscovered:(WiiRemote*)wiimote;
- (void) buttonChanged:(WiiButtonType)type isPressed:(BOOL)isPressed wiiRemote:(WiiRemote*)wiiRemote;
- (void) accelerationChanged:(WiiAccelerationSensorType)type accX:(unsigned char)accX accY:(unsigned char)accY accZ:(unsigned char)accZ wiiRemote:(WiiRemote*)wiiRemote;
- (void) joyStickChanged:(WiiJoyStickType)type tiltX:(unsigned char)tiltX tiltY:(unsigned char)tiltY wiiRemote:(WiiRemote*)wiiRemote;
- (void) irPointMovedX:(float)px Y:(float)py ANGLE:(float)angle tracking:(BOOL)_irTracking wiiRemote:(WiiRemote*)wiiRemote;
- (void) analogButtonChanged:(WiiButtonType)type amount:(unsigned)press wiiRemote:(WiiRemote*)wiiRemote;


- (void) wiiRemoteDisconnected:(IOBluetoothDevice*)device;

- (void) reportRemoteButtonData:(UInt16)_data wiiRemote:(WiiRemote*)wiiRemote;
- (void) reportNunchuckButtonData:(UInt16)_data wiiRemote:(WiiRemote*)wiiRemote;
- (void) reportClassicControllerButtonData:(UInt16)_data wiiRemote:(WiiRemote*)wiiRemote;

- (id)delegate;
- (void)setDelegate:(id)new_delegate;

-(UInt16) getNunchuckStickX;
-(UInt16) getNunchuckStickY;
- (void) updateRemoteCalibrationData;
- (void) updateNunchuckCalibrationData;
-(int) getClassicControllerLeftJoystickX;
-(int) getClassicControllerLeftJoystickY;
-(int) getClassicControllerRightJoystickX;
-(int) getClassicControllerRightJoystickY;
-(int) getClassicControllerAnalogButtonRight;
-(int) getClassicControllerAnalogButtonLeft;

-(float) getIRPointX;
-(float) getIRPointY;
-(float) getIRAngle;
-(BOOL) getIRTracking;

- (WiiExpansionPortType)getExpansionPortType;

@end

@interface NSObject ( WiiMoteDelegate )

- (void)WiiMoteDiscovered:(WiiMote*)wiiMote;
- (void)WiiMoteDisconnected:(WiiMote*)wiiMote;
- (void)WiiMoteAccelerationDataChanged:(int)Xas :(int)Yas :(int)Zas:(WiiMote*)wiiMote;
- (void)WiiMoteIsAPressed:(BOOL)isPressed:(WiiMote*)wiiMote;
- (void)WiiMoteIsBPressed:(BOOL)isPressed:(WiiMote*)wiiMote;
- (void)WiiMoteIsHomePressed:(BOOL)isPressed:(WiiMote*)wiiMote;
- (void)WiiMoteIsLeftPressed:(BOOL)isPressed:(WiiMote*)wiiMote;
- (void)WiiMoteIsRightPressed:(BOOL)isPressed:(WiiMote*)wiiMote;
- (void)WiiMoteIsUpPressed:(BOOL)isPressed:(WiiMote*)wiiMote;
- (void)WiiMoteIsDownPressed:(BOOL)isPressed:(WiiMote*)wiiMote;
- (void)WiiMoteIs1Pressed:(BOOL)isPressed:(WiiMote*)wiiMote;
- (void)WiiMoteIs2Pressed:(BOOL)isPressed:(WiiMote*)wiiMote;
- (void)WiiMoteIsMinusPressed:(BOOL)isPressed:(WiiMote*)wiiMote;
- (void)WiiMoteIsPlusPressed:(BOOL)isPressed:(WiiMote*)wiiMote;


@end


