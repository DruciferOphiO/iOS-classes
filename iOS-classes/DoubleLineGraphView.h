//
//  DoubleLineGraphVC.h
//
//  Created by Andrew McKinley on 11/26/13.
//
//



#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

/*
 @abstract:
 This view controller takes a NSDictionary class and creates a line graph.
 
 */

@protocol doubleLineGraphDelegate;

@interface DoubleLineGraphView : UIView <CPTPlotDataSource, CPTPlotDelegate, CPTPlotSpaceDelegate>

@property (nonatomic, weak) id<doubleLineGraphDelegate> delegate;

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

// Optional: Change which graph labels are shown when the view is clicked. Default YES
@property (assign, nonatomic) BOOL changeLablesOnClick;

// reload the graph to accommodate any changes to the data
-(void)resetGraph;

@end

@protocol doubleLineGraphDelegate <NSObject>

@optional

// optional responses to clicking the graph
-(void)didClickGraph;

@end