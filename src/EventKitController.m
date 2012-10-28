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

#import <EventKit/EventKit.h>
#import "EventKitController.h"

static NSUInteger const kCalendarUnits = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSTimeZoneCalendarUnit;

NSDictionary *asDictionary(NSArray *calendars);

@interface EventKitController (Private)

- (void) addCommonAttributesOf: (CalendarItem *)item to: (EKCalendarItem *)ekCalendarItem;

@end

@implementation EventKitController
{
@private
    EKEventStore *store;
    NSDictionary *reminderCalendarsByTitle;
    NSDictionary *eventCalendarsByTitle;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        store                    = [[EKEventStore alloc] initWithAccessToEntityTypes: EKEntityMaskReminder];
        reminderCalendarsByTitle = asDictionary([store calendarsForEntityType: EKEntityTypeReminder]);
        eventCalendarsByTitle    = asDictionary([store calendarsForEntityType: EKEntityTypeEvent]);
    }

    return self;
}

- (NSString *) defaultReminderCalendar
{
    return [store defaultCalendarForNewReminders].title;
}

- (NSString *) defaultEventCalendar
{
    return [store defaultCalendarForNewEvents].title;
}

- (NSArray *) reminderCalendars
{
    return [reminderCalendarsByTitle allKeys];
}

- (NSArray *) eventCalendars
{
    return [eventCalendarsByTitle allKeys];
}

- (BOOL) hasReminderCalendar: (NSString *)name
{
    return nil != reminderCalendarsByTitle[name];
}

- (BOOL) hasEventCalendar: (NSString *)name
{
    return nil != eventCalendarsByTitle[name];
}

- (NSError *) addReminder: (Reminder *)reminder
{
    EKReminder *ekReminder = [EKReminder reminderWithEventStore: store];
    ekReminder.calendar = reminderCalendarsByTitle[reminder.calendar];
    [self addCommonAttributesOf: reminder to: ekReminder];
    ekReminder.completed = reminder.completed;

    if (nil != reminder.dueDate)
    {
        NSCalendar       *gregorian  = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
        NSDateComponents *components = [gregorian components: kCalendarUnits fromDate: reminder.dueDate];
        ekReminder.dueDateComponents = components;

        NSDate *midnight = [reminder.dueDate toMidnight];
        [self addAlarmTo: ekReminder offset: ([reminder.dueDate timeIntervalSinceDate: midnight] + reminder.alarmOffset) type: reminder.alarmType];
    }

    NSError *error = nil;
    [store saveReminder: ekReminder commit: YES error: &error];

    return error;
}

- (NSError *) addEvent: (Event *)event
{
    EKEvent *ekEvent = [EKEvent eventWithEventStore: store];
    ekEvent.calendar = eventCalendarsByTitle[event.calendar];
    [self addCommonAttributesOf: event to: ekEvent];
    ekEvent.allDay    = event.allDay;
    ekEvent.startDate = event.startDate;

    if (event.allDay)
    {
        if (round(event.duration) > 1)
        {
            ekEvent.endDate = ([event.startDate dateByAddingTimeInterval: round(event.duration) * 86400]);
        }
        else
        {
            ekEvent.endDate = event.startDate;
        }
        [self addAlarmTo: ekEvent offset: event.allDayAlarmOffset type: event.alarmType];
    }
    else
    {
        ekEvent.endDate = ([event.startDate dateByAddingTimeInterval: round(60 * event.duration) * 60]);
        [self addAlarmTo: ekEvent offset: event.alarmOffset type: event.alarmType];
    }

    NSError *error = nil;
    [store saveEvent: ekEvent span: EKSpanThisEvent commit: YES error: &error];

    return error;
}

- (void) addCommonAttributesOf: (CalendarItem *)item to: (EKCalendarItem *)ekCalendarItem
{
    ekCalendarItem.title = item.description;
    if (nil != item.note)
    {
        ekCalendarItem.notes = item.note;
    }
    if (nil != item.url)
    {
        ekCalendarItem.URL = [NSURL URLWithString: item.url];
    }
}

- (void) addAlarmTo: (EKCalendarItem *)calItem offset: (NSTimeInterval)interval type: (AlarmType)type
{
    if (AlarmNone != type)
    {
        EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset: interval];
        switch (type)
        {
            case AlarmMessage:
                alarm.soundName    = nil;
                alarm.emailAddress = nil;
                alarm.url          = nil;
                break;
            case AlarmMessageWithSound:
                alarm.soundName = @"Basso";
                break;
            default:
                break;
        }
        [calItem addAlarm: alarm];
    }
}

@end

NSDictionary *asDictionary(NSArray *calendars)
{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity: calendars.count];
    for (EKCalendar     *calendar in calendars)
    {
        if (calendar.allowsContentModifications)
        {
            result[calendar.title] = calendar;
        }
    }
    return result;
}

