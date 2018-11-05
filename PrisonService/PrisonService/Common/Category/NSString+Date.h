//
//  NSString+Date.h
//  PrisonService
//
//  Created by calvin on 2018/4/21.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Date)

- (NSDate *)stringToDateWithFormat:(NSString *)format;
- (NSString *)timestampToDateString;
- (NSDate *)timestampToDate;
- (NSString *)timestampToMonthDayString;

@end