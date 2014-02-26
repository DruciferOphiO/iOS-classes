//
//  GraphView.h
//  MockMetrics
//
//  Created by Andrew McKinley on 8/2/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "PieChartVC.h"

@interface BarGraphVC : UIView <CPTBarPlotDataSource, CPTBarPlotDelegate>

// key is xAxis, value is Y axis. 
@property (strong, nonatomic) NSMutableDictionary *graphData;

// Title at top of graph
@property (strong, nonatomic) NSString *graphHeader;

// Space between bottom of screen and xAxis
@property (readwrite, assign) CGFloat bottomMargin;

// Space between left border and yAxis 
@property (readwrite, assign) CGFloat leftMargin;

// Color of highlights when bar is clicked
@property (strong, nonatomic) CPTColor *highlightColor;

// Amount of labels and ticks on the yAxis
@property (readwrite, assign) NSUInteger amountOfyAxisLabels;

- (CPTBarPlot *)didClickBarPlot:(CPTBarPlot *)plot atIndex:(NSUInteger)index;

- (void)refreshGraphWithDic:(NSMutableDictionary*)dic;

@end