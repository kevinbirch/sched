//
//  sched
//
//  Copyright (c) 2012 kevin birch <kmb@pobox.com>. All rights reserved.
//

#import "Reminder.h"

@implementation Reminder
{
@private
    Priority priority;
    BOOL     completed;
    NSDate   *dueDate;
}

@synthesize priority;
@synthesize completed;
@synthesize dueDate;

- (id) init
{
    self = [super init];
    if(self)
    {
        priority = PriorityNone;
        completed = NO;
    }

    return self;
}

@end
