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

static const int kWindowHeightVariance = 113;

@interface Scheduler (Private)

- (void) showHideMoreOptions;

@end

@implementation Scheduler
{
@private
    NSWindow *window;
    NSFormCell *eventDate;
    NSString *selectedTab;
    BOOL optionsVisible;
    Reminder *reminder;
    Event *event;
    CalendarController *controller;
}

@synthesize window;
@synthesize eventDate;
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
        // xxx - add preferences based reminder alarm offset
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

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (id)sender
{
#pragma unused (sender)
    return YES;
}

- (void) applicationDidFinishLaunching: (id)notification
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

    [window close];
}

- (IBAction) toggleEventDateFormat: (id)sender
{
#pragma unused (sender)
    if(event.allDay)
    {
        eventDate.formatter = [[NSDateFormatter alloc] initWithDateFormat: @"%A, %B %1d %Y" allowNaturalLanguage: YES];
    }
    else
    {
        eventDate.formatter = [[NSDateFormatter alloc] initWithDateFormat: @"%A, %B %1d %Y %1I:%M %p %z" allowNaturalLanguage: YES];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
        NSUInteger componentNames = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSTimeZoneCalendarUnit;
        NSDateComponents *components = [gregorian components:componentNames fromDate:event.startDate];
        [components setHour: 9];
        event.startDate =  [gregorian dateFromComponents: components];
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
