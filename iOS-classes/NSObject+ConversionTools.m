//
//  NSObject+ConversionTools.m
//  MockMetrics
//
//  Created by Andrew McKinley on 12/2/13.
//
//

#import "NSObject+ConversionTools.h"

@implementation NSObject (ConversionTools)


-(NSString*)numbersToDollars:(NSString*)number
{
    NSString *convertedValue;
    if ([number length] <=3)
    {
        convertedValue = [NSString stringWithFormat:@"$%@",number];
        return convertedValue;
    }
    else if ([number length] > 3 && [number length] <= 6)
    {
        NSRange rangeOne = {([number length]-3),3};
        if ([number length] == 6)
        {
            NSRange rangeTwo = {0,3};
            convertedValue = [NSString stringWithFormat:@"$%@,%@", [number substringWithRange:rangeTwo], [number substringWithRange:rangeOne]];
        }
        if ([number length] == 5)
        {
            NSRange rangeTwo = {0,2};
            convertedValue = [NSString stringWithFormat:@"$%@,%@", [number substringWithRange:rangeTwo], [number substringWithRange:rangeOne]];
        }
        if ([number length] == 4)
        {
            NSRange rangeTwo = {0,1};
            convertedValue = [NSString stringWithFormat:@"$%@,%@", [number substringWithRange:rangeTwo], [number substringWithRange:rangeOne]];
        }
        return convertedValue;
    }
    else if ([number length] > 6 && [number length] <= 9)
    {
        NSRange rangeOne = {([number length]-3),3};
        NSRange rangeTwo = {([number length]-6),3};
        
        if ([number length] == 9)
        {
            NSRange rangeThree = {0, 3};
            convertedValue = [NSString stringWithFormat:@"$%@,%@,%@", [number substringWithRange:rangeThree], [number substringWithRange:rangeTwo], [number substringWithRange:rangeOne]];
        };
        if ([number length] == 8)
        {
            NSRange rangeThree = {0, 2};
            convertedValue = [NSString stringWithFormat:@"$%@,%@,%@", [number substringWithRange:rangeThree], [number substringWithRange:rangeTwo], [number substringWithRange:rangeOne]];
            
        }
        if ([number length] == 7)
        {
            NSRange rangeThree = {0, 1};
            convertedValue = [NSString stringWithFormat:@"$%@,%@,%@", [number substringWithRange:rangeThree], [number substringWithRange:rangeTwo], [number substringWithRange:rangeOne]];
            
        }
        return convertedValue;
    }
    
    else if ([number length] > 9 && [number length] <= 12)
    {
        NSRange rangeOne = {([number length]-3),3};
        NSRange rangeTwo = {([number length]-6),3};
        NSRange rangeThree = {([number length]-9),3};
        
        if ([number length] == 12)
        {
            NSRange rangeFour = {0, 3};
            convertedValue = [NSString stringWithFormat:@"$%@,%@,%@,%@", [number substringWithRange:rangeFour], [number substringWithRange:rangeThree], [number substringWithRange:rangeTwo], [number substringWithRange:rangeOne]];
        };
        if ([number length] == 11)
        {
            NSRange rangeFour = {0, 2};
            convertedValue = [NSString stringWithFormat:@"$%@,%@,%@,%@", [number substringWithRange:rangeFour], [number substringWithRange:rangeThree], [number substringWithRange:rangeTwo], [number substringWithRange:rangeOne]];
            
        }
        if ([number length] == 10)
        {
            NSRange rangeFour = {0, 1};
            convertedValue = [NSString stringWithFormat:@"$%@,%@,%@,%@", [number substringWithRange:rangeFour], [number substringWithRange:rangeThree], [number substringWithRange:rangeTwo], [number substringWithRange:rangeOne]];
            
        }
        return convertedValue;
    }
    
    return nil;
}

-(NSString*)numbersToDollarsAndChange:(NSString*)number
{
    NSString *convertedValue;
    NSArray *numberArray = [number componentsSeparatedByString:@"."];
    NSString *newNumber = [numberArray objectAtIndex:0];
    if ([newNumber length] <=3)
    {
        convertedValue = [NSString stringWithFormat:@"$%@",newNumber];
        return [NSString stringWithFormat:@"%@.%@",convertedValue, [numberArray objectAtIndex:1]];
    }
    else if ([newNumber length] > 3 && [newNumber length] <= 6)
    {
        NSRange rangeOne = {([newNumber length]-3),3};
        if ([newNumber length] == 6)
        {
            NSRange rangeTwo = {0,3};
            convertedValue = [NSString stringWithFormat:@"$%@,%@", [newNumber substringWithRange:rangeTwo], [newNumber substringWithRange:rangeOne]];
        }
        if ([newNumber length] == 5)
        {
            NSRange rangeTwo = {0,2};
            convertedValue = [NSString stringWithFormat:@"$%@,%@", [newNumber substringWithRange:rangeTwo], [newNumber substringWithRange:rangeOne]];
        }
        if ([newNumber length] == 4)
        {
            NSRange rangeTwo = {0,1};
            convertedValue = [NSString stringWithFormat:@"$%@,%@", [newNumber substringWithRange:rangeTwo], [newNumber substringWithRange:rangeOne]];
        }
        if ([[numberArray objectAtIndex:1] length] == 1)
        {
            return [NSString stringWithFormat:@"%@.%@0",convertedValue, [numberArray objectAtIndex:1]];
        }
        else
        {
            return [NSString stringWithFormat:@"%@.%@",convertedValue, [numberArray objectAtIndex:1]];
        }
        
    }
    else if ([newNumber length] > 6 && [newNumber length] <= 9)
    {
        NSRange rangeOne = {([newNumber length]-3),3};
        NSRange rangeTwo = {([newNumber length]-6),3};
        
        if ([newNumber length] == 9)
        {
            NSRange rangeThree = {0, 3};
            convertedValue = [NSString stringWithFormat:@"$%@,%@,%@", [newNumber substringWithRange:rangeThree], [newNumber substringWithRange:rangeTwo], [newNumber substringWithRange:rangeOne]];
        };
        if ([newNumber length] == 8)
        {
            NSRange rangeThree = {0, 2};
            convertedValue = [NSString stringWithFormat:@"$%@,%@,%@", [newNumber substringWithRange:rangeThree], [newNumber substringWithRange:rangeTwo], [newNumber substringWithRange:rangeOne]];
            
        }
        if ([newNumber length] == 7)
        {
            NSRange rangeThree = {0, 1};
            convertedValue = [NSString stringWithFormat:@"$%@,%@,%@", [newNumber substringWithRange:rangeThree], [newNumber substringWithRange:rangeTwo], [newNumber substringWithRange:rangeOne]];
            
        }
        if ([[numberArray objectAtIndex:1] length] == 1)
        {
            return [NSString stringWithFormat:@"%@.%@0",convertedValue, [numberArray objectAtIndex:1]];
        }
        else
        {
            return [NSString stringWithFormat:@"%@.%@",convertedValue, [numberArray objectAtIndex:1]];
        }
    }
    
    else if ([newNumber length] > 9 && [newNumber length] <= 12)
    {
        NSRange rangeOne = {([newNumber length]-3),3};
        NSRange rangeTwo = {([newNumber length]-6),3};
        NSRange rangeThree = {([newNumber length]-9),3};
        
        if ([newNumber length] == 12)
        {
            NSRange rangeFour = {0, 3};
            convertedValue = [NSString stringWithFormat:@"$%@,%@,%@,%@", [newNumber substringWithRange:rangeFour], [newNumber substringWithRange:rangeThree], [newNumber substringWithRange:rangeTwo], [newNumber substringWithRange:rangeOne]];
        };
        if ([newNumber length] == 11)
        {
            NSRange rangeFour = {0, 2};
            convertedValue = [NSString stringWithFormat:@"$%@,%@,%@,%@", [newNumber substringWithRange:rangeFour], [newNumber substringWithRange:rangeThree], [newNumber substringWithRange:rangeTwo], [newNumber substringWithRange:rangeOne]];
            
        }
        if ([newNumber length] == 10)
        {
            NSRange rangeFour = {0, 1};
            convertedValue = [NSString stringWithFormat:@"$%@,%@,%@,%@", [newNumber substringWithRange:rangeFour], [newNumber substringWithRange:rangeThree], [newNumber substringWithRange:rangeTwo], [newNumber substringWithRange:rangeOne]];
            
        }
        if ([[numberArray objectAtIndex:1] length] == 1)
        {
            return [NSString stringWithFormat:@"%@.%@0",convertedValue, [numberArray objectAtIndex:1]];
        }
        else
        {
            return [NSString stringWithFormat:@"%@.%@",convertedValue, [numberArray objectAtIndex:1]];
        }
    }
    
    return nil;
}

-(NSString*)formatMoney:(NSString*)number
{
    NSArray *numberArray = [number componentsSeparatedByString:@"."];
    if (numberArray.count == 1)
    {
        return [self numbersToDollars:number];
    }
    else
    {
        return [self numbersToDollarsAndChange:number];
    }
}

-(NSArray*)lastIsFirst:(NSArray*)array
{
    NSMutableArray *newArray;
    if (!newArray)
    {
        newArray = [[NSMutableArray alloc] initWithArray:array];
    }
    else
    {
        [newArray removeAllObjects];
        newArray = [NSMutableArray arrayWithArray:array];
    }
    id tmp = [newArray objectAtIndex:([newArray count]-1)];
    [newArray removeObjectAtIndex:([newArray count]-1)];

    return [NSArray arrayWithArray:[[NSArray arrayWithObject:tmp] arrayByAddingObjectsFromArray:newArray]];
}

-(NSArray*)reorderDates:(NSArray*)array
{
    NSMutableArray *mutatedArray;
    if (!mutatedArray)
    {
        mutatedArray = [[NSMutableArray alloc] initWithArray:array];
    }
    else
    {
        mutatedArray = [NSMutableArray arrayWithArray:array];
    }
    
    for (int i=0;i<array.count; i++)
    {
        NSString *unformatedDate = [[mutatedArray objectAtIndex:i] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [mutatedArray replaceObjectAtIndex:i withObject:unformatedDate];
    }
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES comparator:^(id obj1, id obj2)
                                    {
                                        return [obj1 compare:obj2 options:NSNumericSearch];
                                    }];
    
    mutatedArray = [NSMutableArray arrayWithArray:[mutatedArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]]];
    
    for (int i=0;i<mutatedArray.count; i++)
    {
        NSMutableString *newString = [NSMutableString stringWithString:[mutatedArray objectAtIndex:i]];
        [newString insertString:@"-" atIndex:2];
        [mutatedArray replaceObjectAtIndex:i withObject:newString];
    }
    
    return [NSArray arrayWithArray:mutatedArray];
}

- (NSString*)abbreviateDate:(NSString *)string
{
    NSArray *stringArray = [string componentsSeparatedByString:@"-"];
    NSString *abbreviatedDate = [NSString stringWithFormat:@"%@-%@",[stringArray objectAtIndex:1], [stringArray objectAtIndex:2]];
    return abbreviatedDate;
}

- (NSString *)fromCamelCaseToCapital:(NSString*)string {
    
    NSScanner *scanner = [NSScanner scannerWithString:string];
    scanner.caseSensitive = YES;
    
    NSString *builder = [NSString string];
    NSString *buffer = nil;
    NSUInteger lastScanLocation = 0;
    
    while ([scanner isAtEnd] == NO) {
        
        if ([scanner scanCharactersFromSet:[NSCharacterSet lowercaseLetterCharacterSet] intoString:&buffer]) {
            
            builder = [builder stringByAppendingString:buffer];
            
            if ([scanner scanCharactersFromSet:[NSCharacterSet uppercaseLetterCharacterSet] intoString:&buffer]) {
                
                builder = [builder stringByAppendingString:@" "];
                builder = [builder stringByAppendingString:[buffer lowercaseString]];
                builder = [builder capitalizedString];
            }
        }
        
        // If the scanner location has not moved, there's a problem somewhere.
        if (lastScanLocation == scanner.scanLocation) return nil;
        lastScanLocation = scanner.scanLocation;
    }
    
    return builder;
}

@end