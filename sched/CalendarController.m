//
//  Created by kmb on 2012-08-21.
//  JetBrains AppCode
//
//  Copyright 2012 kmb.  All rights reserved.
//

#import <CalendarStore/CalendarStore.h>
#import "CalendarController.h"

BOOL isReminderList(CalCalendar *calendar);

@interface CalendarController (Private)

- (void) initCalendars;
- (void) initDefaultCalendars;

@end

@implementation CalendarController
{
@private
    NSString            *defaultReminderCalendar;
    NSString            *defaultEventCalendar;
    NSMutableDictionary *reminderCalendarsByName;
    NSMutableDictionary *eventCalendarsByName;
}

@synthesize defaultReminderCalendar;
@synthesize defaultEventCalendar;

- (id) init
{
    self = [super init];
    if(self)
    {
        [self initCalendars];
    }

    return self;
}

- (void) initCalendars
{
    NSArray *calendars = [[CalCalendarStore defaultCalendarStore] calendars];
    reminderCalendarsByName = [NSMutableDictionary dictionary];
    eventCalendarsByName = [NSMutableDictionary dictionary];
    for(CalCalendar *calendar in [calendars filteredArrayUsingPredicate: [NSPredicate predicateWithFormat: @"isEditable == YES"]])
    {
        if(isReminderList(calendar))
        {
            [reminderCalendarsByName setObject: calendar forKey: calendar.title];
        }
        else
        {
            [eventCalendarsByName setObject: calendar forKey: calendar.title];
        }
    }
    [self initDefaultCalendars];
}

- (void) initDefaultCalendars
{
    CalCalendar *reminderCalendar = [reminderCalendarsByName objectForKey: @"Home"];
    defaultReminderCalendar = (nil != reminderCalendar ? reminderCalendar : (CalCalendar *) [[reminderCalendarsByName allValues] objectAtIndex:0]).title;
    CalCalendar *eventCalendar = [eventCalendarsByName objectForKey: @"Home"];
    defaultEventCalendar = (nil != eventCalendar ? reminderCalendar : (CalCalendar *) [[eventCalendarsByName allValues] objectAtIndex:0]).title;
}

- (NSArray *) reminderCalendars
{
    return [reminderCalendarsByName allKeys];
}

- (NSArray *) eventCalendars
{
    return [reminderCalendarsByName allKeys];
}

- (NSError *) addReminder: (Reminder *)reminder
{
    CalTask *calTask = [CalTask task];
    calTask.title = reminder.description;
    calTask.calendar = [reminderCalendarsByName objectForKey: reminder.calendar];
    if (nil != reminder.dueDate)
    {
        calTask.dueDate = reminder.dueDate;
        if(AlarmNone != reminder.alarmType)
        {
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
            NSDateComponents *components = [gregorian components: (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSTimeZoneCalendarUnit) fromDate:reminder.dueDate];
            NSDate *midnight = [gregorian dateFromComponents: components];
            CalAlarm *alarm = [CalAlarm alarm];
            alarm.relativeTrigger = [reminder.dueDate timeIntervalSinceDate: midnight];
            switch(reminder.alarmType)
            {
                case AlarmMessage:
                    alarm.action = CalAlarmActionDisplay;
                    break;
                case AlarmMessageWithSound:
                    alarm.action = CalAlarmActionSound;
                    break;
            }
            [calTask addAlarm: alarm];
        }
    }
    if (reminder.completed) calTask.isCompleted = YES;
    if (nil != reminder.note) calTask.notes = reminder.note;
    if (nil != reminder.url) calTask.url = [NSURL URLWithString: reminder.url];
    if (PriorityNone != reminder.priority) calTask.priority = reminder.priority;

    NSError *error = nil;
    [[CalCalendarStore defaultCalendarStore] saveTask: calTask error: &error];
    return error;
}

@end

BOOL isReminderList(CalCalendar *calendar)
{
    if(!calendar.isEditable)
    {
        return NO;
    }

    // Try to make a task here.
    CalTask *newTask = [CalTask task];
    newTask.calendar = calendar;
    newTask.title    = @"Test Item";
    NSError *anError = nil;
    if(![[CalCalendarStore defaultCalendarStore] saveTask: newTask error: &anError])
    {
        return NO;
    }

    [[CalCalendarStore defaultCalendarStore] removeTask: newTask error: nil];

    return YES;
}
