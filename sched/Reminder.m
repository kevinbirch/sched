//
//  Created by kmb on 2012-08-21.
//  JetBrains AppCode
//
//  Copyright 2012 kmb.  All rights reserved.
//

#import "Reminder.h"

@implementation Reminder
{
@private
    NSString *calendar;
    NSString *description;
    Priority priority;
    BOOL     completed;
    NSDate   *dueDate;
    Alarm alarmType;
    NSString *url;
    NSString *note;
}

@synthesize description;
@synthesize priority;
@synthesize completed;
@synthesize dueDate;
@synthesize url;
@synthesize note;
@synthesize calendar;
@synthesize alarmType;

- (id) init
{
    self = [super init];
    if(self)
    {
        priority = PriorityNone;
        completed = NO;
        alarmType = AlarmMessageWithSound;
    }

    return self;
}

@end
