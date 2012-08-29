//
//  Created by kmb on 2012-08-21.
//  JetBrains AppCode
//
//  Copyright 2012 kmb.  All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reminder.h"

@interface CalendarController : NSObject

@property (nonatomic, copy) NSString *defaultReminderCalendar;
@property (nonatomic, copy) NSString *defaultEventCalendar;
@property (nonatomic, readonly) NSArray *reminderCalendars;
@property (nonatomic, readonly) NSArray *eventCalendars;

-(NSError *) addReminder: (Reminder *)reminder;

@end
