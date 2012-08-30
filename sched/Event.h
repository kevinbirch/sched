//
//  sched
//
//  Copyright (c) 2012 kevin birch <kmb@pobox.com>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CalendarItem.h"

@interface Event : CalendarItem

@property (nonatomic, copy)   NSDate *startDate;
@property (nonatomic, assign) double duration;
@property (nonatomic, assign) BOOL allDay;
@property (nonatomic, assign) NSTimeInterval allDayAlarmOffset;

@end
