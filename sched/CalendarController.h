//
//  sched
//
//  Copyright (c) 2012 kevin birch <kmb@pobox.com>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reminder.h"
#import "Event.h"

@class Event;

@interface CalendarController : NSObject

@property (nonatomic, copy) NSString *defaultReminderCalendar;
@property (nonatomic, copy) NSString *defaultEventCalendar;
@property (nonatomic, readonly) NSArray *reminderCalendars;
@property (nonatomic, readonly) NSArray *eventCalendars;

- (NSError *) addReminder: (Reminder *)reminder;
- (NSError *) addEvent: (Event *)event;

@end
