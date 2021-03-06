#import "OSCQueryProtocolClientAppDelegate.h"
#import <VVOSC/VVOSC.h>




@interface OSCQueryProtocolClientAppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@property (strong) id activity;
@end




@implementation OSCQueryProtocolClientAppDelegate


- (id) init	{
	self = [super init];
	if (self != nil)	{
		//	disable app nap
		self.activity = [[NSProcessInfo processInfo] beginActivityWithOptions:NSActivityUserInitiated reason:@"OSCQuery Client"];
		
		//	make an OSC manager, set myself up as its delegate so i receive any OSC traffic that i can display here
		oscm = [[OSCManager alloc] init];
		[oscm setDelegate:self];
		//	make a new OSC input- this is what will receive OSC data
		//oscIn = [oscm createNewInput];
		oscIn = [oscm createNewInput];
		[oscIn setPortLabel:@"OSC query client test app OSC input"];
		
		
		coalescingTimer = nil;
		//	register to receive notifications that the list of OSC query servers has updated
		[[NSNotificationCenter defaultCenter]
			addObserver:self
			selector:@selector(oscQueryServersUpdated:)
			name:kVVOSCQueryRemoteServersUpdatedNotification
			object:nil];
		//	initialize the remote server class, which will start looking for remote servers automatically...
		[VVOSCQueryRemoteServer class];
	}
	return self;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	NSLog(@"%s",__func__);
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	NSLog(@"%s",__func__);
}


- (void) oscQueryServersUpdated:(NSNotification *)note	{
	NSLog(@"%s",__func__);
	//	multiple notifications may be fired if many servers are coming online at once, so use a timer to coalesce those updates
	@synchronized (self)	{
		if (coalescingTimer != nil)
			[coalescingTimer invalidate];
		coalescingTimer = [NSTimer
			scheduledTimerWithTimeInterval:0.25
			target:self
			selector:@selector(coalescingTimerCallback:)
			userInfo:nil
			repeats:NO];
	}
}
- (void) coalescingTimerCallback:(NSTimer *)t	{
	@synchronized (self)	{
		coalescingTimer = nil;
	}
	
	NSMutableString		*displayString = [[NSMutableString alloc] init];
	NSArray				*servers = [VVOSCQueryRemoteServer remoteServers];
	[displayString appendFormat:@"%d servers detected:\n",(servers==nil) ? 0 : (int)[servers count]];
	[displayString appendFormat:@"**************\n"];
	for (VVOSCQueryRemoteServer *server in servers)	{
		[server addDelegate:self];
		[displayString appendFormat:@"name: \"%@\"\n",[server oscName]];
		[displayString appendFormat:@"\tbonjour: \"%@\"\n",[server bonjourName]];
		[displayString appendFormat:@"\taddress: %@:%d\n",[server webServerAddressString],[server webServerPort]];
	}
	
	[textView setString:displayString];
	
	/*
	NSArray		*servers = [VVOSCQueryRemoteServer remoteServers];
	if (servers==nil || [servers count]<1)	{
		NSLog(@"\t\tno remote servers detected, bailing...");
		return;
	}
	VVOSCQueryRemoteServer	*server = [servers objectAtIndex:0];
	NSLog(@"\t\tfirst remote server is %@",server);
	NSLog(@"\t\tfirst remote server's HOST_INFO is %@",[server hostInfo]);
	//NSLog(@"\t\tfirst remote server's root node is %@",[server rootNode]);
	*/
}


- (IBAction) listenClicked:(id)sender	{
	NSLog(@"%s",__func__);
	NSArray						*servers = [VVOSCQueryRemoteServer remoteServers];
	VVOSCQueryRemoteServer		*server = (servers==nil || [servers count]<1) ? nil : [servers objectAtIndex:0];
	if (server == nil)
		return;
	NSLog(@"\t\tserver is %@",server);
	[server websocketSendJSONObject:@{
		kVVOSCQ_WSAttr_Command: kVVOSCQ_WSAttr_Cmd_Listen,
		kVVOSCQ_WSAttr_Data: @"/test/my_float"
		}];
	//[server websocketSendJSONObject:@{ @"COMMAND": @"LISTEN", @"DATA": @"/foo/bar/baz/qux" }];
}
- (IBAction) ignoreClicked:(id)sender	{
	NSLog(@"%s",__func__);
	NSArray						*servers = [VVOSCQueryRemoteServer remoteServers];
	VVOSCQueryRemoteServer		*server = (servers==nil || [servers count]<1) ? nil : [servers objectAtIndex:0];
	if (server == nil)
		return;
	NSLog(@"\t\tserver is %@",server);
	[server websocketSendJSONObject:@{
		kVVOSCQ_WSAttr_Command: kVVOSCQ_WSAttr_Cmd_Ignore,
		kVVOSCQ_WSAttr_Data: @"/test/my_float"
		}];
	//[server websocketSendJSONObject:@{ @"COMMAND": @"IGNORE", @"DATA": @"/test/dingus" }];
	//[server websocketSendJSONObject:@{ @"COMMAND": @"IGNORE", @"DATA": @"/foo/bar/baz/qux" }];
}
- (IBAction) testClicked:(id)sender	{
	NSLog(@"%s",__func__);
	NSArray						*servers = [VVOSCQueryRemoteServer remoteServers];
	VVOSCQueryRemoteServer		*server = (servers==nil || [servers count]<1) ? nil : [servers objectAtIndex:0];
	if (server == nil)
		return;
	OSCMessage			*msg = [OSCMessage createWithAddress:@"/test/my_float"];
	[msg addFloat:0.33];
	
	//OSCPacket			*pkt = [OSCPacket createWithContent:msg];
	//[server
	//	sendOSCPacketData:[pkt payload]
	//	sized:[pkt bufferLength]
	//	toClientsListeningToOSCAddress:[msg address]];
	
	NSString		*ip = [server oscServerAddressString];
	if (ip == nil)
		ip = [server webServerAddressString];
	int				port = [server oscServerPort];
	//NSLog(@"\t\tremote server address is %@:%d",ip,port);
	//	find the OSC output that matches my server's IP and port (create one if it doesn't exist yet)
	OSCOutPort		*outPort = [oscm findOutputWithAddress:ip andPort:port];
	if (outPort == nil)
		outPort = [oscm createNewOutputToAddress:ip atPort:port];
	if (outPort != nil)	{
		[outPort sendThisMessage:msg];
	}
	else
		NSLog(@"\t\terr: can't send, outPort nil, %s",__func__);
}


#pragma mark ---------------------------- OSCDelegateProtocol


- (void) receivedOSCMessage:(OSCMessage *)m	{
	NSLog(@"%s ... %@",__func__,m);
}


#pragma mark ---------------------------- VVOSCQueryRemoteServerDelegate


- (void) remoteServerWentOffline:(VVOSCQueryRemoteServer *)remoteServer	{
	NSLog(@"%s",__func__);
}
- (void) remoteServer:(VVOSCQueryRemoteServer *)remoteServer websocketDeliveredJSONObject:(NSDictionary *)jsonObj	{
	NSLog(@"%s",__func__);
}
- (void) remoteServer:(VVOSCQueryRemoteServer *)remoteServer receivedOSCPacket:(const void *)packet sized:(size_t)packetSize	{
	NSLog(@"%s",__func__);
	[OSCPacket
		parseRawBuffer:(unsigned char *)packet
		ofMaxLength:(int)packetSize
		toInPort:oscIn
		fromAddr:0
		port:0];
}
- (void) remoteServer:(VVOSCQueryRemoteServer *)remoteServer pathChanged:(NSString *)n	{
	NSLog(@"%s",__func__);
	NSLog(@"\t\t%@",n);
}
- (void) remoteServer:(VVOSCQueryRemoteServer *)remoteServer pathRenamedFrom:(NSString *)oldName to:(NSString *)newName	{
	NSLog(@"%s",__func__);
	NSLog(@"\t\t%@ -> %@",oldName,newName);
}
- (void) remoteServer:(VVOSCQueryRemoteServer *)remoteServer pathRemoved:(NSString *)n	{
	NSLog(@"%s",__func__);
	NSLog(@"\t\t%@",n);
}
- (void) remoteServer:(VVOSCQueryRemoteServer *)remoteServer pathAdded:(NSString *)n	{
	NSLog(@"%s ... %@",__func__,n);
}


@end
