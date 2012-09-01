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

#import "Scheduler.h"
#import "CalendarStoreController.h"
#import "EventKitController.h"

static const int kWindowHeightVariance = 113;

static NSString * const ReminderCalendarKey = @"ReminderCalendar";
static NSString * const ReminderPriorityKey = @"ReminderPriority";
static NSString * const ReminderAlarmTypeKey = @"ReminderAlarmType";
static NSString * const ReminderAlarmOffsetKey = @"ReminderAlarmOffset";

static NSString * const EventCalendarKey = @"EventCalendar";
static NSString * const EventAlarmTypeKey = @"EventAlarmType";
static NSString * const EventDurationKey = @"EventDuration";
static NSString * const EventAlarmOffsetKey = @"EventAlarmOffset";
static NSString * const EventAllDayAlarmOffsetKey = @"EventAllDayAlarmOffset";

NSDictionary *makeUserDefaultsDictionary(id <CalendarController> controller);

@interface Scheduler (Private)

- (void) showHideMoreOptions;

@end

@implementation Scheduler
{
@private
    NSWindow *window;
    NSString *selectedTab;
    BOOL optionsVisible;
    Reminder *reminder;
    Event *event;
    id<CalendarController> controller;
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
        // xxx - this should change based on the OS version!
        controller = [[CalendarStoreController alloc] init];
        reminder = [[Reminder alloc] init];
        event = [[Event alloc] init];

        selectedTab = @"Reminder";
        optionsVisible = YES;
    }

    return self;
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (id)sender
{
#pragma unused (sender)
    return YES;
}

- (void) applicationDidFinishLaunching: (id)notification
{
#pragma unused (notification)
    [self setOptionsVisible: NO];
    [[NSUserDefaults standardUserDefaults] registerDefaults: makeUserDefaultsDictionary(controller)];

    reminder.calendar = [[NSUserDefaults standardUserDefaults] stringForKey: ReminderCalendarKey];
    reminder.alarmType = (AlarmType) [[NSUserDefaults standardUserDefaults] integerForKey: ReminderAlarmTypeKey];
    reminder.priority = (Priority) [[NSUserDefaults standardUserDefaults] integerForKey: ReminderPriorityKey];
    reminder.alarmOffset = [[NSUserDefaults standardUserDefaults] integerForKey: ReminderAlarmOffsetKey];
    event.calendar = [[NSUserDefaults standardUserDefaults] stringForKey: EventCalendarKey];
    event.alarmType = (AlarmType) [[NSUserDefaults standardUserDefaults] integerForKey: EventAlarmTypeKey];
    event.duration = [[NSUserDefaults standardUserDefaults] doubleForKey: EventDurationKey];
    event.alarmOffset = [[NSUserDefaults standardUserDefaults] integerForKey: EventAlarmOffsetKey];
    event.allDayAlarmOffset = [[NSUserDefaults standardUserDefaults] integerForKey: EventAllDayAlarmOffsetKey];

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
    else
    {
        [window close];
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

NSDictionary *makeUserDefaultsDictionary(id<CalendarController> controller)
{
    return [NSDictionary dictionaryWithObjectsAndKeys: [controller defaultReminderCalendar], ReminderCalendarKey,
                                                       [NSNumber numberWithInt: PriorityNone], ReminderPriorityKey,
                                                       [NSNumber numberWithInt: AlarmMessageWithSound], ReminderAlarmTypeKey,
                                                       [NSNumber numberWithInt: 0], ReminderAlarmOffsetKey,
                                                       [controller defaultEventCalendar], EventCalendarKey,
                                                       [NSNumber numberWithInt: AlarmMessageWithSound], EventAlarmTypeKey,
                                                       [NSNumber numberWithDouble: 1.0], EventDurationKey,
                                                       [NSNumber numberWithInt: -900], EventAlarmOffsetKey,
                                                       [NSNumber numberWithInt: 32400], EventAllDayAlarmOffsetKey,
                                                       nil];

}
