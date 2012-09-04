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
#import "Preferences.h"

static const int kWindowHeightVariance = 113;

static NSString *const ReminderCalendarKey    = @"ReminderCalendar";
static NSString *const ReminderPriorityKey    = @"ReminderPriority";
static NSString *const ReminderAlarmTypeKey   = @"ReminderAlarmType";
static NSString *const ReminderAlarmOffsetKey = @"ReminderAlarmOffset";

static NSString *const EventCalendarKey          = @"EventCalendar";
static NSString *const EventAlarmTypeKey         = @"EventAlarmType";
static NSString *const EventDurationKey          = @"EventDuration";
static NSString *const EventAlarmOffsetKey       = @"EventAlarmOffset";
static NSString *const EventAllDayAlarmOffsetKey = @"EventAllDayAlarmOffset";

NSDictionary *makeUserDefaults(id <CalendarController> controller);

@interface Scheduler (Private)

- (void) showHideMoreOptions;
- (void) configureModelFromPreferences;
- (void) ensureSavedCalendarsStillExist;

@end

@implementation Scheduler
{
@private
    NSWindow *window;
    NSString *selectedTab;
    BOOL optionsVisible;
    Reminder *reminder;
    Event    *event;
    id <CalendarController> controller;
    Preferences *preferences;
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
        reminder   = [[Reminder alloc] init];
        event      = [[Event alloc] init];

        selectedTab    = @"Reminder";
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
    [[NSUserDefaults standardUserDefaults] registerDefaults: makeUserDefaults(controller)];

    [self configureModelFromPreferences];
    [self ensureSavedCalendarsStillExist];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(configureModelFromPreferences) name: NSUserDefaultsDidChangeNotification object: nil];

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
        reminder.alarmOffset = [[NSUserDefaults standardUserDefaults] doubleForKey: ReminderAlarmOffsetKey] * -60;
        error = [controller addReminder: reminder];
    }
    else
    {
        event.alarmOffset       = [[NSUserDefaults standardUserDefaults] integerForKey: EventAlarmOffsetKey] * -60;
        event.allDayAlarmOffset = [[NSUserDefaults standardUserDefaults] doubleForKey: EventAllDayAlarmOffsetKey];
        error = [controller addEvent: event];
    }
    if(nil != error)
    {
        [[NSAlert alertWithError: error] runModal];
    }
    else
    {
        [window performClose: self];
    }
}

- (void) showPreferences
{
    if(nil == preferences)
    {
        preferences = [[Preferences alloc] initWithController: controller];
    }

    [preferences showWindow: self];
}

- (void) configureModelFromPreferences
{
    reminder.calendar  = [[NSUserDefaults standardUserDefaults] stringForKey: ReminderCalendarKey];
    reminder.alarmType = (AlarmType) [[NSUserDefaults standardUserDefaults] integerForKey: ReminderAlarmTypeKey];
    reminder.priority  = (Priority) [[NSUserDefaults standardUserDefaults] integerForKey: ReminderPriorityKey];
    event.calendar     = [[NSUserDefaults standardUserDefaults] stringForKey: EventCalendarKey];
    event.alarmType    = (AlarmType) [[NSUserDefaults standardUserDefaults] integerForKey: EventAlarmTypeKey];
    event.duration     = [[NSUserDefaults standardUserDefaults] doubleForKey: EventDurationKey];
}

- (void) ensureSavedCalendarsStillExist
{
    if(![controller hasReminderCalendar: reminder.calendar])
    {
        [[NSUserDefaults standardUserDefaults] setValue: [controller defaultReminderCalendar] forKey: ReminderCalendarKey];
        reminder.calendar = [[NSUserDefaults standardUserDefaults] stringForKey: ReminderCalendarKey];
    }
    if(![controller hasEventCalendar: event.calendar])
    {
        [[NSUserDefaults standardUserDefaults] setValue: [controller defaultEventCalendar] forKey: EventCalendarKey];
        event.calendar = [[NSUserDefaults standardUserDefaults] stringForKey: EventCalendarKey];
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

NSDictionary *makeUserDefaults(id <CalendarController> controller)
{
    return @{
    ReminderCalendarKey: [controller defaultReminderCalendar],
    ReminderPriorityKey: @(PriorityNone),
    ReminderAlarmTypeKey: @(AlarmMessageWithSound),
    ReminderAlarmOffsetKey: @15,
    EventCalendarKey: [controller defaultEventCalendar],
    EventAlarmTypeKey: @(AlarmMessageWithSound),
    EventDurationKey: @1.0,
    EventAlarmOffsetKey: @15,
    EventAllDayAlarmOffsetKey: @32400.0
    };
}
