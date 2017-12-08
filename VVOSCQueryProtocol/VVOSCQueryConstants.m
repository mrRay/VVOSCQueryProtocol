#import "VVOSCQueryConstants.h"




NSString * kVVOSCQ_ReqAttr_Path = @"FULL_PATH";
NSString * kVVOSCQ_ReqAttr_Contents = @"CONTENTS";
NSString * kVVOSCQ_ReqAttr_Desc = @"DESCRIPTION";
NSString * kVVOSCQ_ReqAttr_HostInfo = @"HOST_INFO";
NSString * kVVOSCQ_ReqAttr_HostInfo_Name = @"NAME";
NSString * kVVOSCQ_ReqAttr_HostInfo_Exts = @"EXTENSIONS";
NSString * kVVOSCQ_ReqAttr_HostInfo_OSCIP = @"OSC_IP";
NSString * kVVOSCQ_ReqAttr_HostInfo_OSCPort = @"OSC_PORT";
NSString * kVVOSCQ_ReqAttr_HostInfo_OSCTransport = @"OSC_TRANSPORT";
NSString * kVVOSCQ_ReqAttr_HostInfo_WSIP = @"WS_IP";	//	WS_IP
NSString * kVVOSCQ_ReqAttr_HostInfo_WSPort = @"WS_PORT";	//	WS_PORT


NSString * kVVOSCQ_OptAttr_Tags = @"TAGS";
NSString * kVVOSCQ_OptAttr_Type = @"TYPE";
NSString * kVVOSCQ_OptAttr_Access = @"ACCESS";
NSString * kVVOSCQ_OptAttr_Value = @"VALUE";
NSString * kVVOSCQ_OptAttr_Range = @"RANGE";
NSString * kVVOSCQ_OptAttr_Range_Min = @"MIN";
NSString * kVVOSCQ_OptAttr_Range_Max = @"MAX";
NSString * kVVOSCQ_OptAttr_Range_Vals = @"VALS";
NSString * kVVOSCQ_OptAttr_Clipmode = @"CLIPMODE";
NSString * kVVOSCQ_OptAttr_Unit = @"UNIT";
NSString * kVVOSCQ_OptAttr_Critical = @"CRITICAL";


NSArray<NSString*> * kVVOSCQ_NonRecursiveAttrs = nil;


NSString * kVVOSCQueryNodeClipModeNone = @"none";
NSString * kVVOSCQueryNodeClipModeLow = @"low";
NSString * kVVOSCQueryNodeClipModeHigh = @"high";
NSString * kVVOSCQueryNodeClipModeBoth = @"both";


NSString * kVVOSCQueryOSCTransportUDP = @"UDP";
NSString * kVVOSCQueryOSCTransportTCP = @"TCP";


NSString * kVVOSCQ_WSAttr_Command = @"COMMAND";
NSString * kVVOSCQ_WSAttr_Data = @"DATA";

NSString * kVVOSCQ_WSAttr_Cmd_PathChanged = @"PATH_CHANGED";




NSString * kVVOSCQueryRemoteServersNewServerNotification = @"kVVOSCQueryRemoteServersNewServerNotification";
NSString * kVVOSCQueryRemoteServersRemovedServerNotification = @"kVVOSCQueryRemoteServersRemovedServerNotification";
NSString * kVVOSCQueryRemoteServersUpdatedNotification = @"kVVOSCQueryRemoteServersUpdatedNotification";




@implementation VVOSCQueryConstants

+ (void) initialize	{
	kVVOSCQ_NonRecursiveAttrs = @[
		kVVOSCQ_OptAttr_Tags,
		kVVOSCQ_OptAttr_Type,
		kVVOSCQ_OptAttr_Access,
		kVVOSCQ_OptAttr_Value,
		kVVOSCQ_OptAttr_Range,
		kVVOSCQ_OptAttr_Clipmode,
		kVVOSCQ_OptAttr_Unit,
		kVVOSCQ_OptAttr_Critical
	];
}

@end
