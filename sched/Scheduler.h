//
//  AppDelegate.h
//  sched
//
//  Copyright (c) 2012 Kevin Birch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CalendarController.h"

@interface Scheduler : NSObject <NSApplicationDelegate>

@property (atomic, strong)      IBOutlet NSWindow  *window;
@property (nonatomic, readonly) Reminder *reminder;
@property (nonatomic, copy)     NSString *selectedTab;
@property (nonatomic, readonly) NSArray *reminderCalendars;
@property (nonatomic, readonly) NSArray *eventCalendars;
@property (nonatomic, assign, setter=setOptionsVisible:) BOOL optionsVisible;

- (void) create;

@end
