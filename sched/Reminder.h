//
//  sched
//
//  Copyright (c) 2012 kevin birch <kmb@pobox.com>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CalendarItem.h"

typedef NSUInteger Priority;

enum
{
    PriorityNone     = 0,
    PriorityHigh     = 1,
    PriorityMedium   = 5,
    PriorityLow      = 9
};

@interface Reminder : CalendarItem

@property (nonatomic, assign) Priority priority;
@property (nonatomic, assign) BOOL completed;
@property (nonatomic, copy)   NSDate *dueDate;

@end
