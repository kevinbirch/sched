//
//  Created by kmb on 2012-08-29.
//  JetBrains AppCode
//
//  Copyright 2012 kmb.  All rights reserved.
//

#import "Event.h"

@implementation Event
{
@private
    NSDate *startDate;
    double duration;
    BOOL allDay;
    NSTimeInterval allDayAlarmOffset;
}

@synthesize startDate;
@synthesize duration;
@synthesize allDay;
@synthesize allDayAlarmOffset;

- (id) init
{
    self = [super init];
    if(self)
    {
        allDay = NO;
    }

    return self;
}

@end
