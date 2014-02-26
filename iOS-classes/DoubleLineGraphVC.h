//
//  DoubleLineGraphVC.h
//  MockMetrics
//
//  Created by The LiRo Group on 11/26/13.
//
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface DoubleLineGraphVC : UIView <CPTPlotDataSource, CPTPlotDelegate, CPTPlotSpaceDelegate>

/*
 @abstract:
 This view controller takes a NSDictionary class and creates a line graph.
 
 */

// Required: Data for graph. Key is X axis. Value is Y axis
@property (nonatomic, strong) NSDictionary* dataSetOne;

// Required: Data for graph. Key is X axis. Value is Y axis
@property (nonatomic, strong) NSDictionary* dataSetTwo;

// Optional: Title at top of graph
@property (strong, nonatomic) NSString *graphHeader;

// Optional: Title of Y Axis
@property (strong, nonatomic) NSString *yAxisLabel;

// Optional: Title of X Axis
@property (strong, nonatomic) NSString *xAxisLabel;

// Optional: Max Y value
@property (assign, readwrite) NSUInteger setMaxYValue;

// Optional: Color of line
@property (strong, nonatomic) CPTColor *firstLineColor;

// Optional: Color of line
@property (strong, nonatomic) CPTColor *secondLineColor;

// Optional: Color of title
@property (strong, nonatomic) CPTColor *titleColor;

// Optional: Add dollar signs and commas to annotations and Y axis labels
@property (assign, nonatomic) BOOL isCurrency;

// Optional: Add all previous Y values togeather
@property (assign, nonatomic) BOOL isCumulative;

// Optional: Padding below the graph
@property (assign, readwrite) NSUInteger bottomPadding;

// Optional: Amount of X axis labels default 4
@property (assign, readwrite) NSUInteger xLabelCount;

// Optional: Amount of Y axis labels default 3
@property (assign, readwrite) NSUInteger yLabelCount;

// Optional: Move label up or down
@property (assign, readwrite) NSUInteger labelOffsetDataSetOne;

// Optional: Move label up or down
@property (assign, readwrite) NSUInteger labelOffsetDataSetTwo;

-(void)resetGraph;

@end
