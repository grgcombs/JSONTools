//
//  JSONSchemaValidator.m
//  JSONTools
//
//  Copyright (C) 2014 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.

#import "JSONSchemaValidator.h"
//#include <time.h>

@interface JSONSchemaValidator ()
@property (nonatomic,readonly) NSCalendar *isoCalendar;
@end

@implementation JSONSchemaValidator

- (id)init
{
    self = [super init];
    if (self)
    {
        _formatValidationEnabled = YES;
    }
    return self;
}

- (BOOL)_validateJSONString:(NSString *)jsonString withSchemaDict:(NSDictionary *)schema
{
    NSNumber *validationNumber = schema[@"maxLength"];
    if (validationNumber &&
        ![self validateJSONString:jsonString maximumLength:validationNumber])
    {
        return NO;
    }

    validationNumber = schema[@"minLength"];
    if (validationNumber &&
        ![self validateJSONString:jsonString minimumLength:validationNumber])
    {
        return NO;
    }

    NSString *validationString = schema[@"pattern"];
    if (validationString &&
        ![self validateJSONString:jsonString pattern:validationString])
    {
        return NO;
    }

    if (self.isFormatValidationEnabled)
    {
        validationString = schema[@"format"];
        if (validationString &&
            ![self validateJSONString:jsonString format:validationString])
        {
            return NO;
        }
    }

	return YES;
}

- (BOOL)validateJSONString:(NSString *)jsonString maximumLength:(NSNumber *)maxLength
{
    if (maxLength && [maxLength respondsToSelector:@selector(intValue)])
    {
        //A string instance is valid against this keyword if its length is less than, or equal to, the value of this keyword.
        if (jsonString.length > maxLength.intValue)
        {
            return NO;
        }
    }
    return YES;
}

- (BOOL)validateJSONString:(NSString *)jsonString minimumLength:(NSNumber *)minLength
{
    if (minLength && [minLength respondsToSelector:@selector(intValue)])
    {
        //A string instance is valid against this keyword if its length is greater than, or equal to, the value of this keyword.
        if (jsonString.length < minLength.intValue)
        {
            return NO;
        }
    }
    return YES;
}

- (BOOL)validateJSONString:(NSString *)jsonString pattern:(NSString *)pattern
{
    if (pattern && [pattern isKindOfClass:[NSString class]])
    {
        //A string instance is considered valid if the regular expression matches the instance successfully. Recall: regular expressions are not implicitly anchored.
        //This string SHOULD be a valid regular expression, according to the ECMA 262 regular expression dialect.
        //NOTE: this regex uses ICU which has some differences to ECMA-262 (such as look-behind)
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
        if (!error && regex)
        {
            NSRange matchRange = [regex rangeOfFirstMatchInString:jsonString options:0 range:NSMakeRange(0, jsonString.length)];
            if (matchRange.location == NSNotFound ||
                matchRange.length == 0)
            {
                //A string instance is considered valid if the regular expression matches the instance successfully. Recall: regular expressions are not implicitly anchored.
                return NO;
            }
        }
    }
    return YES;
}

- (BOOL)validateJSONString:(NSString *)jsonString format:(NSString *)format
{
    static NSArray * formatTypes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatTypes = @[@"date-time", @"email", @"hostname", @"ipv4", @"ipv6", @"uri"];
    });

    if (!format ||
        ![formatTypes containsObject:format])
    {
        return YES;
    }
    if (!jsonString ||
        ![jsonString isKindOfClass:[NSString class]])
    {
        return NO; // with a known format type, the non-string doesn't conform
    }

    if ([format isEqualToString:@"hostname"])
    {
        return [self validateJSONStringAsHostname:jsonString];
    }

    if ([format isEqualToString:@"email"])
    {
        return [self validateJSONStringAsEmail:jsonString];
    }

    if ([format isEqualToString:@"uri"])
    {
        return [self validateJSONStringAsURI:jsonString];
    }

    if ([format isEqualToString:@"ipv4"])
    {
        return [self validateJSONStringAsIPv4:jsonString];
    }

    if ([format isEqualToString:@"ipv6"])
    {
        return [self validateJSONStringAsIPv6:jsonString];
    }

    if ([format isEqualToString:@"date-time"])
    {
        return [self validateJSONStringAsDateTime:jsonString];
    }

    return YES;
}

- (BOOL)validateJSONStringAsHostname:(NSString *)jsonString
{
    /* RFC 1034, Section 3.1 */

    if (!jsonString.length)
    {
        /*
         One label is reserved, and that is the null (i.e., zero length) label used for the root
         */
        return NO;
    }

    if (jsonString.length > 255)
    {
        /*
         To simplify implementations, the total number of octets that represent a
         domain name (i.e., the sum of all label octets and label lengths) is
         limited to 255. 
         */
        return NO;
    }

    if (![jsonString canBeConvertedToEncoding:NSASCIIStringEncoding])
    {
        /*
         ... domain name comparisons for all present domain functions are done in a
         case-insensitive manner, assuming an ASCII character set, and a high
         order zero bit.
         */
        return NO;
    }

    for (NSString *component in [jsonString componentsSeparatedByString:@"."])
    {
        /* Each node has a label, which is zero to 63 octets in length */
        if (component.length > 63)
        {
            return NO;
        }
    }

    static NSRegularExpression *rfc1034Check = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *pattern = @"^([a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?\\.)*[a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?$";
        NSError *error = NULL;
        rfc1034Check = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        NSParameterAssert(rfc1034Check != NULL && !error);
    });

    NSRange inputRange = NSMakeRange(0, jsonString.length);
    NSUInteger numberOfMatches = [rfc1034Check numberOfMatchesInString:jsonString options:0 range:inputRange];

    return (numberOfMatches == 1);
}

- (BOOL)validateJSONStringAsEmail:(NSString *)jsonString
{
    /* RFC 5322, Section 3.4.1 */

    if (!jsonString.length)
    {
        return NO;
    }

    static NSRegularExpression *emailCheck = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //NSString *pattern = @"^[+\\w\\.\\-']+@[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)*(\\.[a-zA-Z]{2,})+$";
        NSString *pattern = @"^([\\!#\\$%&'\\*\\+/\\=?\\^`\{\\|\\}~a-zA-Z0-9_-]+[\\.]?)+[\\!#\\$%&'\\*\\+/\\=?\\^`\{\\|\\}~a-zA-Z0-9_-]+@{1}((([0-9A-Za-z_-]+)([\\.]{1}[0-9A-Za-z_-]+)*\\.{1}([A-Za-z]){1,6})|(([0-9]{1,3}[\\.]{1}){3}([0-9]{1,3}){1}))$";
        NSError *error = NULL;
        emailCheck = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        NSParameterAssert(emailCheck != NULL && !error);
    });
    NSRange inputRange = NSMakeRange(0, jsonString.length);
    NSUInteger numberOfMatches = [emailCheck numberOfMatchesInString:jsonString options:0 range:inputRange];

    return (numberOfMatches == 1);
}

- (BOOL)validateJSONStringAsURI:(NSString *)jsonString
{
    /* RFC 3986 */

    if (!jsonString.length)
    {
        return NO;
    }

    static NSRegularExpression *uriCheck = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *pattern = @"^([a-zA-Z][a-zA-Z0-9+-.]*):((/\\/(((([a-zA-Z0-9\\-._~!$&'()*+,;=':]|(%[0-9a-fA-F]{2}))*)@)?((\\[((((([0-9a-fA-F]{1,4}:){6}|(::([0-9a-fA-F]{1,4}:){5})|(([0-9a-fA-F]{1,4})?::([0-9a-fA-F]{1,4}:){4})|((([0-9a-fA-F]{1,4}:)?[0-9a-fA-F]{1,4})?::([0-9a-fA-F]{1,4}:){3})|((([0-9a-fA-F]{1,4}:){0,2}[0-9a-fA-F]{1,4})?::([0-9a-fA-F]{1,4}:){2})|((([0-9a-fA-F]{1,4}:){0,3}[0-9a-fA-F]{1,4})?::[0-9a-fA-F]{1,4}:)|((([0-9a-fA-F]{1,4}:){0,4}[0-9a-fA-F]{1,4})?::))((([0-9a-fA-F]{1,4}):([0-9a-fA-F]{1,4}))|(([0-9]|(1[0-9]{2})|(2[0-4][0-9])|(25[0-5]))\\.([0-9]|(1[0-9]{2})|(2[0-4][0-9])|(25[0-5]))\\.([0-9]|(1[0-9]{2})|(2[0-4][0-9])|(25[0-5]))\\.([0-9]|(1[0-9]{2})|(2[0-4][0-9])|(25[0-5])))))|((([0-9a-fA-F]{1,4}:){0,5}[0-9a-fA-F]{1,4})?::[0-9a-fA-F]{1,4})|((([0-9a-fA-F]{1,4}:){0,5}[0-9a-fA-F]{1,4})?::))|(v[0-9a-fA-F]+\\.[a-zA-Z0-9\\-._~!$&'()*+,;=':]+))\\])|(([0-9]|(1[0-9]{2})|(2[0-4][0-9])|(25[0-5]))\\.([0-9]|(1[0-9]{2})|(2[0-4][0-9])|(25[0-5]))\\.([0-9]|(1[0-9]{2})|(2[0-4][0-9])|(25[0-5]))\\.([0-9]|(1[0-9]{2})|(2[0-4][0-9])|(25[0-5])))|(([a-zA-Z0-9\\-._~!$&'()*+,;=']|(%[0-9a-fA-F]{2}))*))(:[0-9]*)?)((\\/([a-zA-Z0-9\\-._~!$&'()*+,;=':@]|(%[0-9a-fA-F]{2}))*)*))|(\\/?(([a-zA-Z0-9\\-._~!$&'()*+,;=':@]|(%[0-9a-fA-F]{2}))+(\\/([a-zA-Z0-9\\-._~!$&'()*+,;=':@]|(%[0-9a-fA-F]{2}))*)*)?))(\\?(([a-zA-Z0-9\\-._~!$&'()*+,;=':@\\/?]|(%[0-9a-fA-F]{2}))*))?((#(([a-zA-Z0-9\\-._~!$&'()*+,;=':@\\/?]|(%[0-9a-fA-F]{2}))*)))?$";
        NSError *error = NULL;
        uriCheck = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        NSParameterAssert(uriCheck != NULL && !error);
    });
    NSRange inputRange = NSMakeRange(0, jsonString.length);
    NSUInteger numberOfMatches = [uriCheck numberOfMatchesInString:jsonString options:0 range:inputRange];

    return (numberOfMatches == 1);
}

- (BOOL)validateJSONStringAsIPv4:(NSString *)jsonString
{
    /* RFC 2673, Section 3.2 */

    if (!jsonString.length)
    {
        return NO;
    }

    static NSRegularExpression *ipv4check = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *pattern = @"^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$";
        NSError *error = NULL;
        ipv4check = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        NSParameterAssert(ipv4check != NULL && !error);
    });
    NSRange inputRange = NSMakeRange(0, jsonString.length);
    NSUInteger numberOfMatches = [ipv4check numberOfMatchesInString:jsonString options:0 range:inputRange];

    return (numberOfMatches == 1);
}
- (BOOL)validateJSONStringAsIPv6:(NSString *)jsonString
{
    /* RFC 2373, Section 2.2 */

    if (!jsonString.length)
    {
        return NO;
    }

    static NSRegularExpression *ipv6check = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *pattern = @"^(^(([0-9A-F]{1,4}(((:[0-9A-F]{1,4}){5}::[0-9A-F]{1,4})|((:[0-9A-F]{1,4}){4}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,1})|((:[0-9A-F]{1,4}){3}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,2})|((:[0-9A-F]{1,4}){2}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,3})|(:[0-9A-F]{1,4}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,4})|(::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,5})|(:[0-9A-F]{1,4}){7}))$|^(::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,6})$)|^::$)|^((([0-9A-F]{1,4}(((:[0-9A-F]{1,4}){3}::([0-9A-F]{1,4}){1})|((:[0-9A-F]{1,4}){2}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,1})|((:[0-9A-F]{1,4}){1}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,2})|(::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,3})|((:[0-9A-F]{1,4}){0,5})))|([:]{2}[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,4})):|::)((25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{0,2})\\.){3}(25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{0,2})$$";

        NSError *error = NULL;
        ipv6check = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        NSParameterAssert(ipv6check != NULL && !error);
    });
    NSRange inputRange = NSMakeRange(0, jsonString.length);
    NSUInteger numberOfMatches = [ipv6check numberOfMatchesInString:jsonString options:0 range:inputRange];

    return (numberOfMatches == 1);
}

#define DATETIME_WITH_EASY_WAY 1

- (BOOL)validateJSONStringAsDateTime:(NSString *)jsonString
{
    /* RFC 3339, Section 5.6 */

#if DATETIME_WITH_EASY_WAY
    NSDate *date = [self dateForRFC3339DateTimeString:jsonString];
    return (date != NULL);
#else

    static NSRegularExpression *dateCheck = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *pattern = @"^([0-9]{4})-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])T([01][0-9]|2[0-3]):([0-4][0-9]|5[0-9]):([0-5][0-9]|60)(\\.[0-9]+)?(Z|([+-][01][0-9]|2[0-3]):([0-4][0-9]|5[0-9]))$";

        NSError *error = NULL;
        dateCheck = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        NSParameterAssert(dateCheck != NULL && !error);
    });
    NSRange inputRange = NSMakeRange(0, jsonString.length);
    NSTextCheckingResult *match = [dateCheck firstMatchInString:jsonString options:0 range:inputRange];
    if (!match)
        return NO;

    @try {
        NSDateComponents *components = [[NSDateComponents alloc] init];
        components.calendar = [self isoCalendar];

        components.year = [self componentForDate:jsonString index:1 match:match];
        if (components.year == -1)
            return NO;
        components.month = [self componentForDate:jsonString index:2 match:match];
        if (components.month == -1)
            return NO;
        components.day = [self componentForDate:jsonString index:3 match:match];
        if (![self isValidDay:components.day forMonth:components.month year:components.year])
            return NO;
        components.hour = [self componentForDate:jsonString index:4 match:match];
        if (components.hour == -1)
            return NO;
        components.minute = [self componentForDate:jsonString index:5 match:match];
        if (components.minute == -1)
            return NO;
        components.second = [self componentForDate:jsonString index:6 match:match];
        if (components.second == -1)
            return NO;
        if ([self componentForDate:jsonString index:7 match:match] == -1) // msec
            return NO;
        NSInteger tzHour = [self componentForDate:jsonString index:8 match:match];
        if (tzHour == -1)
            return NO;
        NSInteger tzMin = [self componentForDate:jsonString index:9 match:match];
        if (tzMin == -1)
            return NO;
        NSInteger secondsFromGMT = (tzHour * 60 * 60) + (tzMin * 60);
        components.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:secondsFromGMT];
        if (!components.date)
            return NO;

        components.timeZone = nil; // clear it because this part grabs a named timezone instead of an offset
        NSDateComponents *newComponents = [[self isoCalendar] components:(NSCalendarUnitCalendar |
                                                                          NSCalendarUnitYear |
                                                                          NSCalendarUnitMonth |
                                                                          NSCalendarUnitDay |
                                                                          NSCalendarUnitHour |
                                                                          NSCalendarUnitMinute |
                                                                          NSCalendarUnitSecond) // not timezone
                                                                fromDate:components.date];
        if (![newComponents isEqual:components])
            return NO;
    }
    @catch (NSException *exception) {
        return NO;
    }
    return YES;
#endif
}

#if DATETIME_WITH_EASY_WAY
- (NSDate *)dateForRFC3339DateTimeString:(NSString *)dateString
{
    static NSDateFormatter * rfc3339_1 = nil;
    static NSDateFormatter * rfc3339_2 = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLocale * posixLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];

        rfc3339_1 = [[NSDateFormatter alloc] init];
        rfc3339_1.locale = posixLocale;
        rfc3339_1.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
        rfc3339_1.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];

        rfc3339_2 = [[NSDateFormatter alloc] init];
        rfc3339_2.locale = posixLocale;
        rfc3339_2.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZ";
        rfc3339_2.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    });

    NSDate *date = [rfc3339_1 dateFromString:dateString];
    if (!date)
        date = [rfc3339_2 dateFromString:dateString];

    /* This would be awesome/faster, but it fails to 'fail' on invalid leap year days (Feb 29 1963 returns Mar 1)

       struct tm  sometime;
       const char *formatString = "%Y-%m-%dT%H:%M:%S %z";
       const char *cDate = [dateString cStringUsingEncoding:NSASCIIStringEncoding];
       strptime(cDate, formatString, &sometime);
       date = [NSDate dateWithTimeIntervalSince1970: mktime(&sometime)];
     */

    return date;
}


#else

- (NSCalendar *)isoCalendar
{
    static NSCalendar *isoCalendar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isoCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSISO8601Calendar];
    });
    return isoCalendar;
}

- (BOOL)isValidDay:(NSUInteger)day forMonth:(NSUInteger)month year:(NSUInteger)year
{
    NSCalendar *isoCalendar = [self isoCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = year;
    components.month = month;
    components.calendar = isoCalendar;
    components.day = 1;
    NSDate *date = [components date];
    NSRange range = [isoCalendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return NSLocationInRange(day, range);
}

- (NSInteger)componentForDate:(NSString *)dateString index:(unsigned int)index match:(NSTextCheckingResult *)dateResult
{
    if (dateResult.numberOfRanges <= index)
        return -1;
    NSRange matchRange = [dateResult rangeAtIndex:index];
    if (matchRange.location == NSNotFound ||
        matchRange.length == 0)
        return 0;
    NSString *componentString = [dateString substringWithRange:matchRange];
    return [componentString integerValue];
}

#endif

@end
