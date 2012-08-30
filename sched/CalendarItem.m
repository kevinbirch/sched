//
//  sched
//
//  Copyright (c) 2012 kevin birch <kmb@pobox.com>. All rights reserved.
//

#import "CalendarItem.h"

@implementation CalendarItem
{
@private
    NSString *calendar;
    NSString *description;
    AlarmType alarmType;
    NSString *url;
    NSString *note;
    NSTimeInterval alarmOffset;
}

@synthesize description;
@synthesize url;
@synthesize note;
@synthesize calendar;
@synthesize alarmType;
@synthesize alarmOffset;

- (id) init
{
    self = [super init];
    if(self)
    {
        alarmType = AlarmMessageWithSound;
    }

    return self;
}

@end
