//
//  sched
//
//  Copyright (c) 2012 kevin birch <kmb@pobox.com>. All rights reserved.
//

typedef NSUInteger AlarmType;

enum
{
    AlarmNone = 0,
    AlarmMessage = 1,
    AlarmMessageWithSound = 2
};

@interface CalendarItem : NSObject

@property (nonatomic, copy)   NSString *calendar;
@property (nonatomic, copy)   NSString *description;
@property (nonatomic, assign) AlarmType alarmType;
@property (nonatomic, copy)   NSString *url;
@property (nonatomic, copy)   NSString *note;
@property (nonatomic, assign) NSTimeInterval alarmOffset;

@end
