//
//  GraphView.h
//
//  Created by Andrew McKinley on 8/2/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "PieChartVC.h"

/*
 @abstract:
 This view controller takes a NSDictionary class and creates a bar graph.
 
 */

@protocol barGraphDelegate;

@interface BarGraphView : UIView <CPTBarPlotDataSource, CPTBarPlotDelegate>

@property (nonatomic, weak) id<barGraphDelegate> delegate;

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

// change the data the graph displays
- (void)refreshGraphWithDic:(NSMutableDictionary*)dic;

@end

@protocol barGraphDelegate <NSObject>

@optional

-(void)didClickplot:(CPTPlot*)plot atIndex:(NSUInteger)index;

@end