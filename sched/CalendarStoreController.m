/*
 * The MIT License
 *
 * Copyright (c) 2012 Kevin Birch <kmb@pobox.com>. Some rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import <CalendarStore/CalendarStore.h>
#import "CalendarStoreController.h"

BOOL isReminderList(CalCalendar *calendar);

@interface CalendarStoreController (Private)

- (void) initCalendars;
- (void) initDefaultCalendars;
- (void) addCommonAttributesOf: (CalendarItem *)item to: (CalCalendarItem *)calItem;
- (void) addAlarmTo: (CalCalendarItem *)calItem offset: (NSTimeInterval)interval type: (AlarmType)type;

@end

@implementation CalendarStoreController
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
            reminderCalendarsByName[calendar.title] = calendar;
        }
        else
        {
            eventCalendarsByName[calendar.title] = calendar;
        }
    }
    [self initDefaultCalendars];
}

- (void) initDefaultCalendars
{
    CalCalendar *reminderCalendar = reminderCalendarsByName[@"Home"];
    defaultReminderCalendar = (nil != reminderCalendar ? reminderCalendar : (CalCalendar *) [reminderCalendarsByName allValues][0]).title;
    CalCalendar *eventCalendar = eventCalendarsByName[@"Home"];
    defaultEventCalendar = (nil != eventCalendar ? eventCalendar : (CalCalendar *) [eventCalendarsByName allValues][0]).title;
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
    calTask.calendar = reminderCalendarsByName[reminder.calendar];
    [self addCommonAttributesOf: reminder to: calTask];

    if (nil != reminder.dueDate)
    {
        calTask.dueDate = reminder.dueDate;

        NSDate *midnight = [reminder.dueDate toMidnight];
        [self addAlarmTo: calTask offset: ([reminder.dueDate timeIntervalSinceDate: midnight] + reminder.alarmOffset) type: reminder.alarmType];
    }

    if (reminder.completed) calTask.isCompleted = YES;
    if (PriorityNone != reminder.priority) calTask.priority = reminder.priority;

    NSError *error = nil;
    [[CalCalendarStore defaultCalendarStore] saveTask: calTask error: &error];
    return error;
}

- (NSError *) addEvent: (Event *)event
{
    CalEvent *calEvent = [CalEvent event];
    calEvent.calendar = eventCalendarsByName[event.calendar];
    [self addCommonAttributesOf: event to: calEvent];
    calEvent.isAllDay = event.allDay;
    calEvent.startDate = event.startDate;

    if(event.allDay)
    {
        if(round(event.duration) > 1)
        {
            calEvent.endDate = ([event.startDate dateByAddingTimeInterval: round(event.duration) * 86400]);
        }
        else
        {
            calEvent.endDate = event.startDate;
        }
        [self addAlarmTo: calEvent offset: event.allDayAlarmOffset type: event.alarmType];
    }
    else
    {
        calEvent.endDate = ([event.startDate dateByAddingTimeInterval: round(60 * event.duration) * 60]);
        [self addAlarmTo: calEvent offset: event.alarmOffset type: event.alarmType];
    }

    NSError *error = nil;
    [[CalCalendarStore defaultCalendarStore] saveEvent: calEvent span: CalSpanThisEvent error: &error];
    return error;
}

- (void) addCommonAttributesOf: (CalendarItem *)item to: (CalCalendarItem *)calItem
{
    calItem.title = item.description;
    if (nil != item.note) calItem.notes = item.note;
    if (nil != item.url) calItem.url = [NSURL URLWithString: item.url];
}

- (void) addAlarmTo: (CalCalendarItem *)calItem offset: (NSTimeInterval)interval type: (AlarmType)type
{
    if(AlarmNone != type)
    {
        CalAlarm *alarm = [CalAlarm alarm];
        alarm.relativeTrigger = interval;
        switch(type)
        {
            case AlarmMessage:
                alarm.action = CalAlarmActionDisplay;
                break;
            case AlarmMessageWithSound:
                alarm.action = CalAlarmActionSound;
                break;
            default:
                break;
        }
        [calItem addAlarm: alarm];
    }
}

@end

BOOL isReminderList(CalCalendar *calendar)
{
    if(!calendar.isEditable)
    {
        return NO;
    }

    CalTask *task = [CalTask task];
    task.calendar = calendar;
    task.title = @"Test Item (created by sched)";
    task.url = [NSURL URLWithString: @"https://github.com/kevinbirch/sched/wiki/What-Gives"];
    task.notes = @"This task was created by sched as part of its normal operation.  Please feel free to delete it, we're very sorry for any inconvenience.  For more information, please visit the provided URL.";
    if(NO == [[CalCalendarStore defaultCalendarStore] saveTask: task error: nil])
    {
        return NO;
    }

    NSError *err;
    if (NO == ([[CalCalendarStore defaultCalendarStore] removeTask: task error: &err]))
    {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary: err.userInfo];
        userInfo[NSLocalizedRecoveryOptionsErrorKey] = @"Something went wrong while trying to clean up a test reminder we created in iCal.  It's probably still there so if you see something named \"Test Item\", please feel free to delete it.";
        NSError *betterError = [NSError errorWithDomain: err.domain code: err.code userInfo: userInfo];
        [[NSAlert alertWithError: betterError] runModal];
    }

    return YES;
}
