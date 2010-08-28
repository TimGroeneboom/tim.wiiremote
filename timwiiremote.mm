/**
	@file
	timwiiremote - another wiiremote extension for max/msp, works in Max 5 too!
	Tim Groeneboom - tim@ijsfontein.nl
*/

#include "ext.h"							// standard Max include, always required
#include "ext_obex.h"						// required for new style Max object

#import <Cocoa/Cocoa.h>
#import "WiiMote.h"

////////////////////////// object struct
typedef struct _timwiiremote 
{
	t_object					ob;			// the object itself (must be first)
	WiiMote						*wiiMote;  // pointer to wiimote object
	void *p_outlet;							// outlet creation - inlets are automatic, but objects must "own" their own outlets
	
	t_atom remoteMotionList[5];
	t_atom nunchuckMotionList[5];
	t_atom remoteButtonStateList[3];
	t_atom nunchuckButtonStateList[3];
	t_atom nunchuckStickStateList[4];
	t_atom remoteIRList[6];
	t_atom classicLeftStickStateList[4];
	t_atom classicRightStickStateList[4];
	t_atom classicAnalog[5];
	t_atom classicButtonStateList[3];
	t_atom remoteMotionCalibrationList[8];
	t_atom nunchuckMotionCalibrationList[8];
	t_atom nunchuckStickCalibrationList[8];
	
	t_atom remoteStatusList[2];

	bool extraOutputEnabled , extraOutputNeedsToBeEnabled;
	bool led1,led2,led3,led4;

} t_timwiiremote;
///////////////////////// local functions
void setupLists(t_timwiiremote* x);

///////////////////////// function prototypes
//// standard set
void *timwiiremote_new(t_symbol *s, long argc, t_atom *argv);
void timwiiremote_free(t_timwiiremote *x);
void timwiiremote_assist(t_timwiiremote *x, void *b, long m, long a, char *s);
void timwiiremote_connect(t_timwiiremote *x);
void timwiiremote_disconnect(t_timwiiremote *x);
void timwiiremote_bang(t_timwiiremote *x);
void timwiiremote_led(t_timwiiremote *x, long enable1, long enable2, long enable3, long enable4);
void timwiiremote_vibration(t_timwiiremote *x, long enable);
void timwiiremote_extraoutput(t_timwiiremote *x, long enable);

//////////////////////// global class pointer variable
void *timwiiremote_class;


int main(void)
{	
	// object initialization, OLD STYLE
	 setup((t_messlist **)&timwiiremote_class, (method)timwiiremote_new, (method)timwiiremote_free, (short)sizeof(t_timwiiremote), 
			0L, A_GIMME, 0);
	
	addmess((method)timwiiremote_assist,			"assist",		A_CANT, 0);  
	addmess((method)timwiiremote_connect, "connect", A_GIMME,0);
	addmess((method)timwiiremote_disconnect, "disconnect", A_GIMME,0);
	addmess((method)timwiiremote_led, "led" , A_DEFLONG , A_DEFLONG , A_DEFLONG, A_DEFLONG,0);
	addmess((method)timwiiremote_vibration, "vibration" , A_DEFLONG, 0);
	addmess((method)timwiiremote_extraoutput, "extraoutput", A_DEFLONG, 0);
	addbang((method)timwiiremote_bang);	

	post("I am the timwiiremote object");
	
	return 0;
}

void timwiiremote_assist(t_timwiiremote *x, void *b, long m, long a, char *s)
{
	// 
	if (m == ASSIST_INLET) { // inlet
		sprintf(s, "I am inlet %ld", a);
	} 
	else {	// outlet
		sprintf(s, "I am outlet %ld", a); 			
	}
}

void timwiiremote_free(t_timwiiremote *x)
{
	;
}


void timwiiremote_connect(t_timwiiremote *x)
{
	if(![x->wiiMote isActive]) [x->wiiMote startDiscovery];
	
}

void timwiiremote_disconnect(t_timwiiremote *x)
{
	if([x->wiiMote isActive]) [x->wiiMote closeConnection];
}

void timwiiremote_led(t_timwiiremote *x, long enable1, long enable2, long enable3, long enable4)
{	
	x->led1 = enable1;
	x->led2 = enable2;
	x->led3 = enable3;
	x->led4 = enable4;
	
	[x->wiiMote setLed : x->led1 : x->led2: x->led3: x->led4];	
}

void timwiiremote_vibration(t_timwiiremote *x, long enable)
{	
	if([x->wiiMote isActive]) [x->wiiMote setVibration : enable];	
}

void timwiiremote_extraoutput(t_timwiiremote *x, long enable)
{
	x->extraOutputEnabled = enable;
}

void timwiiremote_bang(t_timwiiremote *x)	
{
	//update poll
	if([x->wiiMote isActive])
	{
		//update wiiremote motion values
		atom_setlong(x->remoteMotionList+2, [x->wiiMote getRemoteX]);
		atom_setlong(x->remoteMotionList+3, [x->wiiMote getRemoteY]);
		atom_setlong(x->remoteMotionList+4, [x->wiiMote getRemoteZ]);
		
		outlet_list(x->p_outlet, NULL, 5 , x->remoteMotionList);
		
		//update wiiremote buttonstate
		atom_setlong(x->remoteButtonStateList+2, [x->wiiMote getRemoteButtonData]);
		
		outlet_list(x->p_outlet, NULL, 3, x->remoteButtonStateList);
		
		//update remote ir list
		atom_setfloat(x->remoteIRList+2, [x->wiiMote getIRPointX]);
		atom_setfloat(x->remoteIRList+3, [x->wiiMote getIRPointY]);
		atom_setfloat(x->remoteIRList+4, [x->wiiMote getIRAngle]);
		atom_setlong(x->remoteIRList+5, (int)[x->wiiMote getIRTracking]);
		
		outlet_list(x->p_outlet,NULL,6,x->remoteIRList);
		
		if([x->wiiMote getExpansionPortType] == WiiNunchuk)
		{
			//update nunchuck motion values
			atom_setlong(x->nunchuckMotionList+2, [x->wiiMote getNunchuckX]);
			atom_setlong(x->nunchuckMotionList+3, [x->wiiMote getNunchuckY]);
			atom_setlong(x->nunchuckMotionList+4, [x->wiiMote getNunchuckZ]);
			
			outlet_list(x->p_outlet, NULL , 5 , x->nunchuckMotionList);
			
			//update nunchuck buttonstate
			atom_setlong(x->nunchuckButtonStateList+2, [x->wiiMote getNunchuckButtonData]);
			
			outlet_list(x->p_outlet,NULL,3,x->nunchuckButtonStateList);
			
			//update nunchuck joystick state
			atom_setlong(x->nunchuckStickStateList+2, [x->wiiMote getNunchuckStickX]);
			atom_setlong(x->nunchuckStickStateList+3, [x->wiiMote getNunchuckStickY]);
			
			outlet_list(x->p_outlet,NULL,4,x->nunchuckStickStateList);
			
			atom_setlong(x->remoteStatusList+1, 2);
			outlet_list(x->p_outlet,NULL,2,x->remoteStatusList);
		}else if([x->wiiMote getExpansionPortType] == WiiClassicController){
			// update classic left joystick
			atom_setlong(x->classicLeftStickStateList+2, [x->wiiMote getClassicControllerLeftJoystickX]);
			atom_setlong(x->classicLeftStickStateList+3, [x->wiiMote getClassicControllerLeftJoystickY]);
			
			outlet_list(x->p_outlet, NULL, 4, x->classicLeftStickStateList);
			
			// update classic Right joystick
			atom_setlong(x->classicRightStickStateList+2, [x->wiiMote getClassicControllerRightJoystickX]);
			atom_setlong(x->classicRightStickStateList+3, [x->wiiMote getClassicControllerRightJoystickY]);
			
			outlet_list(x->p_outlet, NULL, 4, x->classicRightStickStateList);
			
			// update analog buttons
			atom_setlong(x->classicAnalog+2, [x->wiiMote getClassicControllerAnalogButtonLeft]);
			atom_setlong(x->classicAnalog+3, [x->wiiMote getClassicControllerAnalogButtonRight]);
			
			outlet_list(x->p_outlet, NULL, 4, x->classicAnalog);
			
			// update buttons
			atom_setlong(x->classicButtonStateList+2, [x->wiiMote getClassicControllerButtonData]);
			
			outlet_list(x->p_outlet, NULL, 3 , x->classicButtonStateList);
			
			atom_setlong(x->remoteStatusList+1, 3);
			outlet_list(x->p_outlet,NULL,2,x->remoteStatusList);
		}else{
			atom_setlong(x->remoteStatusList+1, 1);
			outlet_list(x->p_outlet,NULL,2,x->remoteStatusList);
		}
		
		if(x->extraOutputEnabled){
			// update wii motion calibration
			
			atom_setlong(x->remoteMotionCalibrationList+2, [x->wiiMote getRemoteMotionCalibrationXZero]);
			atom_setlong(x->remoteMotionCalibrationList+3, [x->wiiMote getRemoteMotionCalibrationYZero]);
			atom_setlong(x->remoteMotionCalibrationList+4, [x->wiiMote getRemoteMotionCalibrationZZero]);
			atom_setlong(x->remoteMotionCalibrationList+5, [x->wiiMote getRemoteMotionCalibrationX1g]);
			atom_setlong(x->remoteMotionCalibrationList+6, [x->wiiMote getRemoteMotionCalibrationY1g]);
			atom_setlong(x->remoteMotionCalibrationList+7, [x->wiiMote getRemoteMotionCalibrationZ1g]);
			
			outlet_list(x->p_outlet, NULL, 8, x->remoteMotionCalibrationList);
			
			if([x->wiiMote getExpansionPortType] == WiiNunchuk){				
				atom_setlong(x->nunchuckMotionCalibrationList+2, [x->wiiMote getNunchuckMotionCalibrationXZero]);
				atom_setlong(x->nunchuckMotionCalibrationList+3, [x->wiiMote getNunchuckMotionCalibrationYZero]);
				atom_setlong(x->nunchuckMotionCalibrationList+4, [x->wiiMote getNunchuckMotionCalibrationZZero]);
				atom_setlong(x->nunchuckMotionCalibrationList+5, [x->wiiMote getNunchuckMotionCalibrationX1g]);
				atom_setlong(x->nunchuckMotionCalibrationList+6, [x->wiiMote getNunchuckMotionCalibrationY1g]);
				atom_setlong(x->nunchuckMotionCalibrationList+7, [x->wiiMote getNunchuckMotionCalibrationZ1g]);
				
				outlet_list(x->p_outlet, NULL, 8, x->nunchuckMotionCalibrationList);
				
				atom_setlong(x->nunchuckStickCalibrationList+2, [x->wiiMote getNunchuckStickCalibrationXMin]);
				atom_setlong(x->nunchuckStickCalibrationList+3, [x->wiiMote getNunchuckStickCalibrationXMax]);
				atom_setlong(x->nunchuckStickCalibrationList+4, [x->wiiMote getNunchuckStickCalibrationXCenter]);
				atom_setlong(x->nunchuckStickCalibrationList+5, [x->wiiMote getNunchuckStickCalibrationYMin]);
				atom_setlong(x->nunchuckStickCalibrationList+6, [x->wiiMote getNunchuckStickCalibrationYMax]);
				atom_setlong(x->nunchuckStickCalibrationList+7, [x->wiiMote getNunchuckStickCalibrationYCenter]);
				
				outlet_list(x->p_outlet, NULL, 8, x->nunchuckStickCalibrationList);
				
			}
		}
	}else{
		atom_setlong(x->remoteStatusList+1, 0);
		outlet_list(x->p_outlet,NULL,2,x->remoteStatusList);
	}
}

void *timwiiremote_new(t_symbol *s, long argc, t_atom *argv)
{
	t_timwiiremote *x = NULL;
    long i;
	
	// object instantiation, OLD STYLE
	if(x = (t_timwiiremote*)newobject(timwiiremote_class))
	{
		object_post((t_object *)x, "tim.wiiremote created by Tim Groeneboom with the WiiRemote.framework by Hiroaki Kimura");
        
		for (i = 0; i < argc; i++) {
			if ((argv + i)->a_type == A_LONG) {
				object_post((t_object *)x, "arg %ld: long (%ld)", i, atom_getlong(argv+i));
			} else if ((argv + i)->a_type == A_FLOAT) {
				object_post((t_object *)x, "arg %ld: float (%f)", i, atom_getfloat(argv+i));
			} else if ((argv + i)->a_type == A_SYM) {
				object_post((t_object *)x, "arg %ld: symbol (%s)", i, atom_getsym(argv+i)->s_name);
			} else {
				object_error((t_object *)x, "forbidden argument");
			}
		}
		
		setupLists(x);
		
		x->p_outlet = listout(x);
		x->extraOutputEnabled = false;
		x->led1 = x->led2 = x->led3 = x->led4 = false;
		
		x->wiiMote = [[WiiMote alloc] init];
		[x->wiiMote Initialize:1];
	}
	
	return (x);
}

void setupLists(t_timwiiremote* x)
{
	// remote motion
	atom_setsym(x->remoteMotionList, gensym("remote"));
	atom_setsym(x->remoteMotionList+1, gensym("motion"));
	
	// nunchuck motion
	atom_setsym(x->nunchuckMotionList, gensym("nunchuck"));
	atom_setsym(x->nunchuckMotionList+1, gensym("motion"));
	
	// remote buttonstate list
	atom_setsym(x->remoteButtonStateList, gensym("remote"));
	atom_setsym(x->remoteButtonStateList+1, gensym("buttons"));
	
	// nunchuck buttonstate list
	atom_setsym(x->nunchuckButtonStateList, gensym("nunchuck"));
	atom_setsym(x->nunchuckButtonStateList+1, gensym("buttons"));
	
	// nunchuck buttonstate list
	atom_setsym(x->nunchuckStickStateList, gensym("nunchuck"));
	atom_setsym(x->nunchuckStickStateList+1, gensym("stick"));
	
	// remote ire list
	atom_setsym(x->remoteIRList, gensym("remote"));
	atom_setsym(x->remoteIRList+1, gensym("ir"));
	
	//
	atom_setsym(x->classicLeftStickStateList, gensym("classic"));
	atom_setsym(x->classicLeftStickStateList+1, gensym("stick1"));
	
	// 
	atom_setsym(x->classicRightStickStateList, gensym("classic"));
	atom_setsym(x->classicRightStickStateList+1, gensym("stick2"));
	
	//
	atom_setsym(x->classicAnalog, gensym("classic"));
	atom_setsym(x->classicAnalog+1, gensym("analog"));
	
	//
	atom_setsym(x->classicButtonStateList, gensym("classic"));
	atom_setsym(x->classicButtonStateList+1, gensym("buttons"));
	
	// 
	atom_setsym(x->remoteMotionCalibrationList, gensym("remote"));
	atom_setsym(x->remoteMotionCalibrationList+1, gensym("motion_calibration"));
	
	// 
	atom_setsym(x->nunchuckMotionCalibrationList, gensym("nunchuck"));
	atom_setsym(x->nunchuckMotionCalibrationList+1, gensym("motion_calibration"));
	
	// 
	atom_setsym(x->nunchuckStickCalibrationList, gensym("nunchuck"));
	atom_setsym(x->nunchuckStickCalibrationList+1, gensym("stick_calibration"));
	
	atom_setsym(x->remoteStatusList, gensym("status"));
	
}

