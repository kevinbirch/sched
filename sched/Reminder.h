//
//  Created by kmb on 2012-08-21.
//  JetBrains AppCode
//
//  Copyright 2012 kmb.  All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSUInteger Priority;

enum
{
    PriorityNone     = 0,
    PriorityHigh     = 1,
    PriorityMedium   = 5,
    PriorityLow      = 9
};

typedef NSUInteger Alarm;

enum
{
    AlarmNone = 0,
    AlarmMessage = 1,
    AlarmMessageWithSound = 2
};

@interface Reminder : NSObject

@property (nonatomic, copy)   NSString *calendar;
@property (nonatomic, copy)   NSString *description;
@property (nonatomic, assign) Priority priority;
@property (nonatomic, assign) BOOL completed;
@property (nonatomic, copy)   NSDate *dueDate;
@property (nonatomic, assign) Alarm alarmType;
@property (nonatomic, copy)   NSString *url;
@property (nonatomic, copy)   NSString *note;

@end
