//
//  NSDate+Category_lib.m
//  Category
//
//  Created by huangkaizhan on 2016/12/5.
//  Copyright © 2016年 mama.cn. All rights reserved.
//

#import "NSDate+Category_lib.h"

#define DateMinute_bb       60          // 一分60秒
#define DateHour_bb         3600        // 一小时3600秒
#define DateDay_bb          86400       // 一天86400秒
#define DateWeek_bb         604800      // 一周604800秒
#define Date_ear_bb         31556926    // 一年31556926秒（不准确）

@implementation NSDate (Category_lib)

#pragma mark - 格式化
// 根据格式转换
- (NSString *)format_lib:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *text = [dateFormatter stringFromDate:self];
    return text;
}

// 根据格式把NSDate转换为年，如：2016
- (NSString *)formatYear_lib
{
    return [self format_lib:DateFormatYear];
}

// 根据格式把NSDate转换为年月，如：2016-06
- (NSString *)formatYearMonth_lib
{
    return [self format_lib:DateFormatMonth];
}

// 根据格式把NSDate转换为年月日，如：2016-06-26
- (NSString *)formatYearMonthDay_lib
{
    return [self format_lib:DateFormatDay];
}

// 根据格式把NSDate转换为年月日，如：2016年06月26日
- (NSString *)formatYearMonthDayChinese_lib
{
    return [self format_lib:DateFormatDayChinese];
}

// 根据格式把NSDate转换为年月日时，如：2016-06-26 14:05
- (NSString *)formatYearMonthDayHourMinute_lib
{
    return [self format_lib:DateFormatMinute];
}

// 根据格式把NSDate转换为年月日，如：2016.06.26
- (NSString *)formatYearMonthDayDot_lib
{
    return [self format_lib:DateFormatDayDot];
}

#pragma mark - 求天数
// 明天
- (NSDate *)tomorrow_lib
{
    return [self dateByAddingTimeInterval:1];
}

// 昨天
- (NSDate *)yesterday_lib
{
    return [self dateByAddingTimeInterval:-1];
}

// 未来第几天
- (NSDate *)futureDay_lib:(NSInteger)days
{
    return [self dateByAddingTimeInterval:days];
}

// 过去第几天
- (NSDate *)pastDay_lib:(NSInteger)days
{
    return [self dateByAddingTimeInterval:-days];
}

// 更改天数
- (NSDate *)dateByAddingDays:(NSInteger)days
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + DateDay_bb * days;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

#pragma mark - 创建
// 根据格式和日期字符串转为NSDate
+ (NSDate *)createDateWithFormat:(NSString *)format dateString:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
}

// 将2016.06.26这种格式转为NSDate
+ (NSDate *)createDateWithFormatYearMonthDayDotString:(NSString *)dateString
{
    return [self createDateWithFormat:DateFormatDayDot dateString:dateString];
}

// 将2016-06-26这种格式转为NSDate
+ (NSDate *)createDateWithFormatYearMonthDayLineString:(NSString *)dateString
{
    return [self createDateWithFormat:DateFormatDay dateString:dateString];
}

// 将2016年6月26日这种格式转为NSDate
+ (NSDate *)createDateWithFormatYearMonthDayChineseString:(NSString *)dateString
{
    return [self createDateWithFormat:DateFormatDayChinese dateString:dateString];
}

#pragma mark - 比较日期
// 比较年月日
- (BOOL)equalToDateForYearMonthDay:(NSDate *)otherDate
{
    unsigned unitFlag = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSCalendar *calenda = [NSCalendar currentCalendar];
    NSDateComponents *comps1 = [calenda components:unitFlag fromDate:self];
    NSDateComponents *comps2 = [calenda components:unitFlag fromDate:otherDate];
    return (comps1.day == comps2.day) && (comps1.month == comps2.month) && (comps1.year == comps2.year);
}

#pragma mark - 获取特殊日期

// 获取星期几
- (NSString *)weakDay
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSInteger unitFlags = NSCalendarUnitWeekOfMonth|NSCalendarUnitWeekday;
    
    NSDateComponents *comps = [calendar components:unitFlags fromDate:self];
    NSMutableString *weekDayString = [NSMutableString stringWithString:@"星期"];
    NSString *dayString = @"";
    switch (comps.weekday) {
        case 1:
            dayString = @"日";
            break;
        case 2:
            dayString = @"一";
            break;
        case 3:
            dayString = @"二";
            break;
        case 4:
            dayString = @"三";
            break;
        case 5:
            dayString = @"四";
            break;
        case 6:
            dayString = @"五";
            break;
        case 7:
            dayString = @"六";
            break;
        default:
            dayString = @"日";
            break;
    }
    [weekDayString appendString:dayString];
    return weekDayString;
}

// 获取一年第几周
- (NSInteger)weakOfYear
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger unitFlags = NSCalendarUnitWeekOfYear|NSCalendarUnitWeekday;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:self];
    return comps.weekOfYear;
}

#pragma mark - 日期描述
// 距离当前的时间间隔描述
- (NSString *)timeIntervalDescription
{
    NSTimeInterval timeInterval = -[self timeIntervalSinceNow];
    if (timeInterval < DateMinute_bb) {
        return @"1分钟内";
    } else if (timeInterval < DateHour_bb) {
        return [NSString stringWithFormat:@"%.f分钟前", timeInterval / DateMinute_bb];
    } else if (timeInterval < DateDay_bb) {
        return [NSString stringWithFormat:@"%.f小时前", timeInterval / DateHour_bb];
    } else if (timeInterval < 2592000) {//30天内
        return [NSString stringWithFormat:@"%.f天前", timeInterval / DateDay_bb];
    } else {
        return [self formatYearMonthDayDot_lib];
    }
}
@end
