//
//  sched
//
//  Copyright (c) 2012 kevin birch <kmb@pobox.com>. All rights reserved.
//

#import <CalendarStore/CalendarStore.h>
#import "CalendarController.h"
#import "Event.h"

BOOL isReminderList(CalCalendar *calendar);
NSDate *toMidnight(NSDate *date);

@interface CalendarController (Private)

- (void) initCalendars;
- (void) initDefaultCalendars;
- (void) addCommonAttributesOf: (CalendarItem *)item to: (CalCalendarItem *)calItem;
- (void) addAlarmTo: (CalCalendarItem *)calItem offset: (NSTimeInterval)interval type: (AlarmType)type;

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
    defaultEventCalendar = (nil != eventCalendar ? eventCalendar : (CalCalendar *) [[eventCalendarsByName allValues] objectAtIndex:0]).title;
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
    calTask.calendar = [reminderCalendarsByName objectForKey: reminder.calendar];
    [self addCommonAttributesOf: reminder to: calTask];

    if (nil != reminder.dueDate)
    {
        calTask.dueDate = reminder.dueDate;

        NSDate *midnight = toMidnight(reminder.dueDate);
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
    calEvent.calendar = [eventCalendarsByName objectForKey: event.calendar];
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

NSDate *toMidnight(NSDate *date)
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *components = [gregorian components: (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSTimeZoneCalendarUnit) fromDate: date];
    return [gregorian dateFromComponents: components];
}
