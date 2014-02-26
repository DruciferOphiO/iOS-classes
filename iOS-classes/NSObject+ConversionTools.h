//
//  NSObject+ConversionTools.h
//  MockMetrics
//
//  Created by The LiRo Group on 12/2/13.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (ConversionTools)

-(NSString*)numbersToDollars:(NSString*)number;

-(NSArray*)lastIsFirst:(NSArray*)array;

-(NSArray*)reorderDates:(NSArray*)array;

-(NSString*)abbreviateDate:(NSString*)string;

-(NSString*)numbersToDollarsAndChange:(NSString*)number;

-(NSString*)formatMoney:(NSString*)number;

- (NSString *)fromCamelCaseToCapital:(NSString*)string;

@end
