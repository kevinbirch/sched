//
//  AppDelegate.m
//  sched
//
//  Copyright (c) 2012 Kevin Birch. All rights reserved.
//

#import "Scheduler.h"

@interface Scheduler (Private)

- (void) showHideMoreOptions;

@end

@implementation Scheduler
{
    CalendarController *controller;
    NSWindow *window;
    Reminder *reminder;
    NSString *selectedTab;
    BOOL optionsVisible;
}

@synthesize window;
@synthesize reminder;
@synthesize selectedTab;
@synthesize optionsVisible;

static const int kWindowHeightVariance = 113;

- (id) init
{
    self = [super init];
    if(self)
    {
        controller = [[CalendarController alloc] init];
        reminder = [[Reminder alloc] init];
        reminder.calendar = controller.defaultReminderCalendar;
        selectedTab = @"Reminder";
        optionsVisible = YES;
    }

    return self;
}

- (void) setOptionsVisible: (BOOL)value
{
    optionsVisible = value;
    [self showHideMoreOptions];
}

- (void)applicationDidFinishLaunching:(id) notification
{
#pragma unused (notification)
    [self setOptionsVisible: NO];
    [window setIsVisible: YES];
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

- (NSArray *) reminderCalendars
{
    return [controller reminderCalendars];
}

- (NSArray *) eventCalendars
{
    return [controller eventCalendars];
}

- (void) create
{
    if([@"Reminder" isEqualToString: selectedTab])
    {
        [controller addReminder: reminder];
    }
    else
    {
    }
}

@end
