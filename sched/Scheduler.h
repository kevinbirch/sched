//
//  sched
//
//  Copyright (c) 2012 kevin birch <kmb@pobox.com>. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CalendarController.h"

@interface Scheduler : NSObject <NSApplicationDelegate>

@property (atomic, strong)      IBOutlet NSWindow  *window;
@property (nonatomic, copy)     NSString *selectedTab;
@property (nonatomic, readonly) Reminder *reminder;
@property (nonatomic, readonly) Event *event;
@property (nonatomic, readonly) NSArray *reminderCalendars;
@property (nonatomic, readonly) NSArray *eventCalendars;
@property (nonatomic, readonly, getter=isReady) BOOL ready;
@property (nonatomic, assign, setter=setOptionsVisible:) BOOL optionsVisible;
@property (nonatomic, readonly) NSString *durationLabel;

- (void) create;

@end
