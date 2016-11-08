
#import "ToolUtil.h"

@implementation ToolUtil

+ (NSString *)MD5Code:(NSString *)value
{
    if (value == nil) {
        return @"";
    }
    const char *cStr = [value UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (NSString *)FormatTime:(NSString *)format timeInterval:(double)value;
{
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:value / 1000];
    [dateformatter setDateFormat:format];
    return [dateformatter stringFromDate:date];
}

+ (double)TimeStrToTimeInterval:(NSString *)format timeStr:(NSString *)time
{
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:format];
    NSDate  *date = [dateformatter dateFromString:time];
    return [date timeIntervalSince1970]*1000;
}

+ (double)rad:(double)d
{
    return d *3.14159265 / 180.0;
}

// 计算两点之间距离
+(NSString *)calculateDistance:(long long)lat1 lng1:(long long)lng1 lat2:(long long)lat2 lng2:(long long)lng2
{
    double EARTH_RADIUS = 6378137;
    
    double _lng1 = lng1 / 1000000.0;
    double _lat1 = lat1 / 1000000.0;
    double _lng2 = lng2 / 1000000.0;
    double _lat2 = lat2 / 1000000.0;
    
    double radLat1 = [self rad:_lat1];
    double radLat2 = [self rad:_lat2];
    double a = radLat1 - radLat2;
    double b = [self rad:_lng1] -[self rad:_lng2];
    double s = 2 * asin(sqrt(pow(sin(a/2),2) + cos(radLat1)*cos(radLat2)*pow(sin(b/2),2)));
    s = s * EARTH_RADIUS;
    s = round(s * 10000) / 10000;
        
    return [self prettyDistance:(long)s];
}

// 计算两点之间距离
+ (long long)calculateDistanceRaw:(long long)lat1 lng1:(long long)lng1 lat2:(long long)lat2 lng2:(long long)lng2
{
    double EARTH_RADIUS = 6378137;
    
    double _lng1 = lng1 / 1000000.0;
    double _lat1 = lat1 / 1000000.0;
    double _lng2 = lng2 / 1000000.0;
    double _lat2 = lat2 / 1000000.0;
    
    double radLat1 = [self rad:_lat1];
    double radLat2 = [self rad:_lat2];
    double a = radLat1 - radLat2;
    double b = [self rad:_lng1] -[self rad:_lng2];
    double s = 2 * asin(sqrt(pow(sin(a/2),2) + cos(radLat1)*cos(radLat2)*pow(sin(b/2),2)));
    s = s * EARTH_RADIUS;
    s = round(s * 10000) / 10000;
    
    return (long long)s;
}

// 格式化输出距离
+(NSString *)prettyDistance:(long long)distance
{
    if (distance <= 10) {
        return @"0.01km";
    } else if (distance <= 10000) {
        return [NSString stringWithFormat:@"%.2fkm", distance/1000.0];
    } else if (distance <= 100000) {
        return [NSString stringWithFormat:@"%.1fkm", distance/1000.0];
    } else {
        return [NSString stringWithFormat:@"%.0fkm", distance/1000.0];
    }
}

//刚刚	N分钟前	N小时前	昨天HH:mm	MM-DD HH:mm	YY-MM-DD HH:mm
+(NSString *)prettyTime2:(long long)timeInSeconds
{
    //原有时间
    NSString *firstDateStr=[ToolUtil FormatTime:@"yyyy-MM-dd" timeInterval:timeInSeconds];
    NSArray *firstDateStrArr=[firstDateStr componentsSeparatedByString:@"-"];
    
    //现在时间
    NSDate *now = [NSDate date];
    NSDateComponents *componentsNow = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:now];
    NSString *nowDateStr = [NSString stringWithFormat:@"%ld-%ld-%ld", (long)[componentsNow year], (long)[componentsNow month], (long)[componentsNow day]];
    NSArray *nowDateStrArr = [nowDateStr componentsSeparatedByString:@"-"];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInSeconds/1000];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    
    //同年
    if ([firstDateStrArr[0] intValue] == [nowDateStrArr[0] intValue])
    {
        
        //同月
        if( [firstDateStrArr[1] intValue] == [nowDateStrArr[1] intValue])
        {
            //今天之内
            if([nowDateStrArr[2] intValue]== [firstDateStrArr[2] intValue])
            {
                int MINUTE = 60;
                int HOUR = 60 * 60;
                int DAY = 60 * 60 * 24;
                
                NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
                [dateformatter setDateFormat:@"yyyy-MM-dd hh:mmaaa"];
                
                NSString *dateString = [dateformatter stringFromDate:[NSDate date]];
                double time = [ToolUtil TimeStrToTimeInterval:@"yyyy-MM-dd hh:mmaaa" timeStr:dateString];
                double interval=(time-timeInSeconds)/1000; //相隔时间秒
                
                if (interval < MINUTE) {
                    return @"刚刚";
                } else if (interval < HOUR) {
                    return [NSString stringWithFormat:@"%.0f分钟前", interval/MINUTE];
                } else if (interval < DAY) {
                    return [NSString stringWithFormat:@"%.0f小时前", interval/HOUR];
                }
            }else if([nowDateStrArr[2] intValue] - [firstDateStrArr[2] intValue] == 1) //昨天
            {
                [dateformatter setDateFormat:@"HH:mm"];
                return [NSString stringWithFormat:@"昨天 %@", [dateformatter stringFromDate:date]];
            }
            //昨天之前
            [dateformatter setDateFormat:@"MM-dd HH:mm"];
            return  [dateformatter stringFromDate:date];
        }
            //昨天之前
            [dateformatter setDateFormat:@"MM-dd HH:mm"];
            return  [dateformatter stringFromDate:date];
    }
        //跨年
        [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        return [dateformatter stringFromDate:date];
}

//HH:mm	HH:mm	HH:mm	昨天HH:mm	MM-DD HH:mm	YY-MM-DD HH:mm
+(NSString *)prettyTime3:(long long)timeInSeconds
{
    //原有时间
    NSString *firstDateStr=[ToolUtil FormatTime:@"yyyy-MM-dd" timeInterval:timeInSeconds];
    NSArray *firstDateStrArr=[firstDateStr componentsSeparatedByString:@"-"];
    
    //现在时间
    NSDate *now = [NSDate date];
    NSDateComponents *componentsNow = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:now];
    NSString *nowDateStr = [NSString stringWithFormat:@"%ld-%ld-%ld", (long)[componentsNow year], (long)[componentsNow month], (long)[componentsNow day]];
    NSArray *nowDateStrArr = [nowDateStr componentsSeparatedByString:@"-"];
    
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInSeconds/1000];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    
    //同年
    if ([firstDateStrArr[0] intValue] == [nowDateStrArr[0] intValue]){
        
        //当天
        if( [firstDateStrArr[1] intValue] == [nowDateStrArr[1] intValue] && [nowDateStrArr[2] intValue]== [firstDateStrArr[2] intValue]){
            [dateformatter setDateFormat:@"HH:mm"];
            return [NSString stringWithFormat:@"%@", [dateformatter stringFromDate:date]];
        }
        
        //昨天
        if( [firstDateStrArr[1] intValue]==[nowDateStrArr[1] intValue] && ([nowDateStrArr[2] intValue]-[firstDateStrArr[2] intValue]==1)){
            [dateformatter setDateFormat:@"HH:mm"];
            return [NSString stringWithFormat:@"昨天 %@", [dateformatter stringFromDate:date]];
            
        }else{//昨天之前
            [dateformatter setDateFormat:@"MM-dd HH:mm"];
            return  [dateformatter stringFromDate:date];
        }
        
    }else{
        [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        return [dateformatter stringFromDate:date];
    }
}

// 正则判断手机号码地址格式
+ (BOOL)isMobileNumber:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

//检查时间间隔是否超过1天
+(BOOL)checkMoreThanOneDayNeedRequest:(NSString *)lastAskTimeKey{
  
    double dateSpace = [[NSDate date] timeIntervalSince1970]*1000;
    NSNumber *lastDateNumber = [[NSUserDefaults standardUserDefaults] objectForKey:lastAskTimeKey];
    if(lastDateNumber){
        double dateDiffer = dateSpace - [lastDateNumber doubleValue];
        BOOL moreThanOneDay = (dateDiffer/1000) > (24 * 60 * 60);
        return moreThanOneDay;
    }
    return YES;
}

+ (CGFloat)calculating_Text_Height_IOS7_Width:(CGFloat)width WithString:(NSAttributedString *)string {
    NSTextStorage *textStorage = [[NSTextStorage alloc] init];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(width, FLT_MAX)];
    [textContainer setLineFragmentPadding:10.0];
    [layoutManager addTextContainer:textContainer];
    [textStorage setAttributedString:string];
    [layoutManager ensureLayoutForTextContainer:textContainer];
    CGRect frame = [layoutManager usedRectForTextContainer:textContainer];
    return frame.size.height;
}

// 网络类型
+(NETWORK_TYPE)getNetworkTypeFromStatusBar {
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    NSNumber *dataNetworkItemView = nil;
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]])     {
            dataNetworkItemView = subview;
            break;
        }
    }
    NETWORK_TYPE nettype = NETWORK_TYPE_NONE;
    NSNumber * num = [dataNetworkItemView valueForKey:@"dataNetworkType"];
    if([num isKindOfClass:[NSNumber class]]){
        nettype = [num intValue];
    }
    return nettype;
}

@end
