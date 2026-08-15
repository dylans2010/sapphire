#import <UserNotifications/UserNotifications.h>
#import "NDNotificationCenterHackery.h"

@implementation NDNotificationCenterHackery

+ (void)removeDefaultAction:(UNMutableNotificationContent*) content{
	content.hasDefaultAction = NO;
}

@end