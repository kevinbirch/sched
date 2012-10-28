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

#import "Preferences.h"

@implementation Preferences
{
@private
    NSView       *remindersView;
    NSView       *eventsView;
    NSToolbar    *toolbar;
    NSDatePicker *datePicker;
    id <CalendarController> controller;
}

@synthesize remindersView;
@synthesize eventsView;
@synthesize toolbar;
@synthesize datePicker;

- (id) initWithController: (id <CalendarController>)calendarController
{
    self = [super initWithWindowNibName: @"Preferences"];
    if (self)
    {
        controller = calendarController;
    }

    return self;
}

- (void) windowDidLoad
{
    [super windowDidLoad];
    // N.B. - see http://stackoverflow.com/questions/7212068/nsdatepicker-timezone-weirdness for this bit of weirdness
    NSTimeZone *tz = [NSTimeZone timeZoneWithAbbreviation: @"GMT"];
    [datePicker setTimeZone: tz];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    [calendar setTimeZone: tz];
    [datePicker setCalendar: calendar];
    [[[self window] contentView] addSubview: remindersView];
    [toolbar setSelectedItemIdentifier: @"reminder"];
}

- (NSArray *) reminderCalendars
{
    return [controller reminderCalendars];
}

- (NSArray *) eventCalendars
{
    return [controller eventCalendars];
}

- (NSDate *) allDayAlarm
{
    NSTimeInterval offset = [[NSUserDefaults standardUserDefaults] doubleForKey: @"EventAllDayAlarmOffset"];
    return [NSDate dateWithTimeIntervalSince1970: offset];
}

- (void) setAllDayAlarm: (NSDate *)value
{
    [[NSUserDefaults standardUserDefaults] setDouble: [value timeIntervalSince1970] forKey: @"EventAllDayAlarmOffset"];
}

- (IBAction) showRemindersView: (id)sender
{
#pragma unused (sender)
    [[[self window] contentView] replaceSubview: eventsView with: remindersView];
}

- (IBAction) showEventsView: (id)sender
{
#pragma unused (sender)
    [[[self window] contentView] replaceSubview: remindersView with: eventsView];
}

@end
