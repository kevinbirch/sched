//
//  sched
//
//  Copyright (c) 2012 kevin birch <kmb@pobox.com>. All rights reserved.
//

#import "Scheduler.h"

static const int kWindowHeightVariance = 113;

@interface Scheduler (Private)

- (void) showHideMoreOptions;

@end

@implementation Scheduler
{
@private
    CalendarController *controller;
    NSWindow *window;
    NSString *selectedTab;
    BOOL optionsVisible;
    Reminder *reminder;
    Event *event;
}

@synthesize window;
@synthesize selectedTab;
@synthesize optionsVisible;
@synthesize reminder;
@synthesize event;

+ (NSSet *) keyPathsForValuesAffectingReady
{
    return [NSSet setWithObjects: @"selectedTab", @"reminder.description", @"event.description", @"event.startDate", nil];
}

+ (NSSet *) keyPathsForValuesAffectingDurationLabel
{
    return [NSSet setWithObjects: @"event.allDay", @"event.duration", nil];
}

- (id) init
{
    self = [super init];
    if(self)
    {
        controller = [[CalendarController alloc] init];
        reminder = [[Reminder alloc] init];
        reminder.calendar = controller.defaultReminderCalendar;
        // xxx - add preferences based event alarm offset
        reminder.alarmOffset = 0;
        event = [[Event alloc] init];
        event.calendar = controller.defaultEventCalendar;
        // xxx - add preferences based duration
        event.duration = 1.0;
        // xxx - add preferences based event alarm offset
        event.alarmOffset = -900;
        event.allDayAlarmOffset = 32400;

        selectedTab = @"Reminder";
        optionsVisible = YES;
    }

    return self;
}

- (void) applicationDidFinishLaunching:(id) notification
{
#pragma unused (notification)
    [self setOptionsVisible: NO];
    [window setIsVisible: YES];
}

- (void) setOptionsVisible: (BOOL)value
{
    optionsVisible = value;
    [self showHideMoreOptions];
}

- (NSArray *) reminderCalendars
{
    return [controller reminderCalendars];
}

- (NSArray *) eventCalendars
{
    return [controller eventCalendars];
}

- (NSString *) durationLabel
{
    return [NSString stringWithFormat: @"%@%@", event.allDay ? @"day" : @"hour", event.duration == 1.0 ? @"" : @"s"];
}

- (BOOL) isReady
{
    return [@"Reminder" isEqualToString: selectedTab] ? nil != reminder.description : (nil != event.description && nil != event.startDate);
}

- (void) create
{
    NSError *error;
    if([@"Reminder" isEqualToString: selectedTab])
    {
        error = [controller addReminder: reminder];
    }
    else
    {
        error = [controller addEvent: event];
    }
    if(nil != error)
    {
        [[NSAlert alertWithError: error] runModal];
    }
}

- (void) showHideMoreOptions
{
    NSRect frame = [window frame];
    if(optionsVisible)
    {
        frame.size.height += kWindowHeightVariance;
        frame.origin.y -= kWindowHeightVariance;
    }
    else
    {
        frame.size.height -= kWindowHeightVariance;
        frame.origin.y += kWindowHeightVariance;
    }
    [window setFrame: frame display: YES animate: YES];
}

@end
