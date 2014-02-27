//
//  GraphView.m
//
//  Created by Andrew McKinley on 8/2/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "BarGraphView.h"
#import "NSObject+ConversionTools.h"

@interface BarGraphView ()

@property (weak, nonatomic) IBOutlet CPTGraphHostingView *hostView;
@property (readwrite, assign) CGFloat maxGraphY;
@property (readwrite, assign) NSUInteger plotIndex;
@property (readwrite, assign) CGFloat barWidth;
@property (readwrite, assign) NSUInteger annotationRef;

-(NSMutableArray*)processDataIntoPlots:(NSDictionary*) data;
-(void)initPlot;
-(void)configureGraph;
-(void)configurePlots;
-(void)configureAxes;
-(void)addAnnotationToPlot:(CPTPlot*)plot atIndex:(NSUInteger)index withPlotIndex:(NSUInteger)plotIndex;
-(void)reconfigureY;

@end

@implementation BarGraphView

NSUInteger const MaxGraphX = 1000;

#pragma mark - View lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        _annotationRef = [_graphData count]-1;
        if (!_highlightColor)
        {
            _highlightColor = [CPTColor yellowColor];
        }
        if (!_amountOfyAxisLabels)
        {
            _amountOfyAxisLabels = 6;
        }
        [self initPlot];

    }
    return self;
}

#pragma mark - Chart behavior

-(NSMutableArray*)processDataIntoPlots:(NSDictionary*) data
{
    self.plotIndex = [_graphData count];
    NSMutableArray *plotArray;
    if (!plotArray)
    {
        plotArray = [[NSMutableArray alloc] init];
    }
    
    for (int i=0; i<_graphData.count; i++)
    {
        NSArray *keys = [self lastIsFirst:[_graphData allKeys]];
        keys = [[keys reverseObjectEnumerator] allObjects];
        NSString *aKey = [keys objectAtIndex:i];
        CPTBarPlot *plot;
        if (i%2 == 0)
        {
            plot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor redColor] horizontalBars:NO];
            plot.fill = [CPTFill fillWithColor:[CPTColor redColor]] ;
        }
        else
        {
            plot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];
            plot.fill = [CPTFill fillWithColor:[CPTColor blueColor]] ;
        }
        plot.identifier = [NSString stringWithFormat:@"%@",aKey];
        [plotArray addObject:plot];
    }
    return plotArray;
}

-(void)initPlot
{
    self.hostView.allowPinchScaling = YES;
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

-(void)configureGraph
{
    
    // 1 - Create the graph
    CPTGraph *graph;
    if (!graph)
    {
        graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    }
    graph.plotAreaFrame.masksToBorder = NO;
    self.hostView.hostedGraph = graph;
    
    // 2 - Configure the graph
    [graph applyTheme:[CPTTheme themeNamed:kCPTPlainBlackTheme]];
    graph.paddingBottom = (self.frame.size.height*0.12); //12% room on bottom
    graph.paddingLeft  = (self.frame.size.width*0.12); // 12% room on left
    if (_leftMargin)
    {
        graph.paddingLeft  = _leftMargin;
    }
    if (_bottomMargin)
    {
        graph.paddingBottom = _bottomMargin;
    }
    graph.paddingTop    = -1.0f; // hide lines on top of graph
    graph.paddingRight  = -5.0f; // hide lines on right of graph
    
    if (_graphHeader)
    {
        // 3 - Set up styles
        CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
        titleStyle.color = [CPTColor redColor];
        titleStyle.fontName = @"Helvetica-Bold";
        titleStyle.fontSize = 16.0f;
        
        // 4 - Set up title
        graph.title = _graphHeader;
        graph.titleTextStyle = titleStyle;
        graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    }

    // 5 - Set up plot space
    _maxGraphY = 0;
    for (int i=0; i<_graphData.count; i++)
    {
        // Calculate the highest Y value
        NSArray *keys = [self lastIsFirst:[_graphData allKeys]];
        keys = [[keys reverseObjectEnumerator] allObjects];
        NSString *theKey = [keys objectAtIndex:i];
        CGFloat maxY = [[_graphData objectForKey:theKey] intValue];
        if (maxY > _maxGraphY)
        {
            _maxGraphY = maxY;
        }
    }
    
    _maxGraphY = _maxGraphY + (_maxGraphY*0.12); // 12% space at the top of the graph

    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(MaxGraphX)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(_maxGraphY)];

}

-(void)reconfigureY
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) self.hostView.hostedGraph.defaultPlotSpace;
    _maxGraphY = 0;
    for (int i=0; i<_graphData.count; i++)
    {
        // Calculate the highest Y value
        NSArray *keys = [self lastIsFirst:[_graphData allKeys]];
        keys = [[keys reverseObjectEnumerator] allObjects];
        NSString *theKey = [keys objectAtIndex:i];
        CGFloat maxY = [[_graphData objectForKey:theKey] intValue];
        if (maxY > _maxGraphY)
        {
            _maxGraphY = maxY;
        }
    }
    
    _maxGraphY = _maxGraphY + (_maxGraphY*0.12); // 12% space at the top of the graph    
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(_maxGraphY)];

}

-(void)configurePlots
{
    
    // Set up line style
    CPTMutableLineStyle *barLineStyle;
    if (!barLineStyle)
    {
        barLineStyle = [[CPTMutableLineStyle alloc] init];
    }

    barLineStyle.lineColor = [CPTColor clearColor];
    barLineStyle.lineWidth = 1.0;
    
    // Add plots to graph
    CPTGraph *graph = self.hostView.hostedGraph;

    NSArray *plots = [self processDataIntoPlots:_graphData];
    
    _barWidth = (MaxGraphX - 30)/[plots count];
    CGFloat barX = self.barWidth/2;

    if ([graph allPlots].count)
    {
        for (CPTBarPlot *plot in [graph allPlots])
        {
            [graph removePlot:plot];
        }
    }
    for (CPTBarPlot *plot in plots)
    {
        plot.dataSource = self;
        plot.delegate = self;
        plot.barWidth = CPTDecimalFromDouble(self.barWidth);
        plot.barOffset = CPTDecimalFromDouble(barX);
        plot.lineStyle = barLineStyle;
        [graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];
        barX = barX + _barWidth + 10;
    }
}

-(void)configureAxes {
    // 1 - Configure styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:1];
    
    // 2 - Get the graph's axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    
    // 3 - Configure the x-axis
    axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    axisSet.xAxis.title = @"";
    axisSet.xAxis.titleTextStyle = axisTitleStyle;
    axisSet.xAxis.titleOffset = 10.0f;
    axisSet.xAxis.axisLineStyle = axisLineStyle;
    
    // 3.2 adding custom x-axis labels
    
    NSArray *xAxisLabels = [self lastIsFirst:[_graphData allKeys]];
    xAxisLabels = [[xAxisLabels reverseObjectEnumerator] allObjects];
    CGFloat graphWidth = MaxGraphX - 30; //800 is ths size of the grapth
    CGFloat eachXFloat = graphWidth/[xAxisLabels count];
    NSUInteger eachX = roundf(eachXFloat);
    NSMutableArray *customTickLocations;
    if (!customTickLocations)
    {
        customTickLocations = [[NSMutableArray alloc] init];
    }
    
    for (int i=0; i<[xAxisLabels count]; i++)
    {
        [customTickLocations addObject:[NSNumber numberWithInt:(((int)eachX*i)+100)]];
    }
    
    NSUInteger labelLocation = 0;
    NSMutableArray *customLabels = [NSMutableArray arrayWithCapacity:[xAxisLabels count]];
    for (NSNumber *tickLocation in customTickLocations)
    {
        NSString *labelText = [xAxisLabels objectAtIndex:labelLocation];
        NSArray *eachWord = [labelText componentsSeparatedByString:@" "];
        if ([eachWord count] > 0)
        {
            //adding line breaks
            NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@" "];
            labelText = [[labelText componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @" \n "];
        }
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText: labelText textStyle:axisSet.xAxis.labelTextStyle];
        newLabel.tickLocation = [tickLocation decimalValue];
        newLabel.offset = 0;
        [customLabels addObject:newLabel];
        labelLocation++;
    }
    axisSet.xAxis.majorTickLocations = [NSSet setWithArray:customTickLocations];
    axisSet.xAxis.axisLabels =  [NSSet setWithArray:customLabels];
    
    
    // 4 - Configure the y-axis
    axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    axisSet.yAxis.titleTextStyle = axisTitleStyle;
    axisSet.yAxis.titleOffset = 5.0f;
    axisSet.yAxis.axisLineStyle = axisLineStyle;
    NSMutableArray *yAxisLabels;
    if (!yAxisLabels)
    {
        yAxisLabels = [[NSMutableArray alloc] init];
    }

    for (int i=_amountOfyAxisLabels; i>=0; i--) {
        CGFloat yinterval = _maxGraphY/_amountOfyAxisLabels;
        NSUInteger yintervalInt = roundf(yinterval*i);
        if (i != _amountOfyAxisLabels) {
            [yAxisLabels addObject:[NSString stringWithFormat:@"%i",yintervalInt]];
        }
    
    }
    CGFloat eachYFloat = _maxGraphY/[yAxisLabels count];
    NSUInteger eachY = roundf(eachYFloat);
    NSMutableArray *customTickLocationsY;
    if (!customTickLocationsY)
    {
        customTickLocationsY = [[NSMutableArray alloc] init];
    }
    
    for (int j=0; j<[yAxisLabels count]; j++)
    {
        [customTickLocationsY addObject:[NSNumber numberWithInt:(((int)eachY*j))]];
    }
    
    NSUInteger labelLocationY = 0;
    NSMutableArray *customLabelsY = [NSMutableArray arrayWithCapacity:[yAxisLabels count]];
    NSArray* reversedArray = [[customTickLocationsY reverseObjectEnumerator] allObjects];
    for (NSNumber *tickLocationY in reversedArray)
    {
        NSString *labelText = [yAxisLabels objectAtIndex:labelLocationY];
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText: labelText textStyle:axisSet.yAxis.labelTextStyle];
        newLabel.tickLocation = [tickLocationY decimalValue];
        newLabel.offset = 0;
        [customLabelsY addObject:newLabel];
        labelLocationY++;
    }

    axisSet.yAxis.majorTickLocations = [NSSet setWithArray:customTickLocationsY];
    axisSet.yAxis.axisLabels =  [NSSet setWithArray:customLabelsY];

}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return 1;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSString * stringOfInt = [_graphData objectForKey:plot.identifier];
    NSNumber *num = nil;
    switch ( fieldEnum )
    {
        case CPTBarPlotFieldBarLocation:
            num = [NSNumber numberWithUnsignedInteger:index];
            [self addAnnotationToPlot:plot atIndex:index withPlotIndex:self.plotIndex];
            if (self.plotIndex > 0)
            {
                self.plotIndex = self.plotIndex-1;
            }
            break;
            
        case CPTBarPlotFieldBarTip:
            num = [NSNumber numberWithInteger:[stringOfInt integerValue]];
            break;
    }
    
    return num;
}

-(void)addAnnotationToPlot:(CPTPlot*)plot atIndex:(NSUInteger)index withPlotIndex:(NSUInteger)plotIndex
{
    //index in this method is not the plotIndex. Each plot can have multiple bars each with a different index
    // 1 - Is the plot hidden?
    if (plot.isHidden == YES || plotIndex == 0)
    {
        return;
    }

    // 2 - Create style, if necessary
    static CPTMutableTextStyle *style = nil;
    if (!style)
    {
        style = [CPTMutableTextStyle textStyle];
        style.color= [CPTColor yellowColor];
        style.fontSize = 16.0f;
        style.fontName = @"Helvetica-Bold";
    }
    // 3 - Create annotation, if necessary
    NSNumber *amount = [self numberForPlot:plot field:CPTBarPlotFieldBarTip recordIndex:index];
    CPTPlotSpaceAnnotation *amountAnnotation;
    if (!amountAnnotation)
    {
        NSNumber *x = [NSNumber numberWithInt:0];
        NSNumber *y = [NSNumber numberWithInt:0];
        NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
        amountAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace anchorPlotPoint:anchorPoint];
    }
    // 4 - Create number formatter, if needed
    static NSNumberFormatter *formatter = nil;
    if (!formatter)
    {
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setMaximumFractionDigits:2];
    }
    //  Create text layer for annotation
    NSString *amountValue = [formatter stringFromNumber:amount];
    if ([_graphHeader isEqualToString:@"ECR's"])
    {
        amountValue = [self numbersToDollars:[formatter stringFromNumber:amount]];
    }
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:amountValue style:style];
    amountAnnotation.contentLayer = textLayer;

     //  Get the anchor for annotation
     CGFloat x = (plotIndex * self.barWidth) - (self.barWidth/2);
     NSNumber *anchorX = [NSNumber numberWithFloat:x];
     CGFloat y = [amount floatValue];
     NSNumber *anchorY = [NSNumber numberWithFloat:y];
     amountAnnotation.anchorPlotPoint = [NSArray arrayWithObjects:anchorX, anchorY, nil];

    if ([plot.graph.plotAreaFrame.plotArea.annotations count] >= [_graphData count] && _annotationRef != -1)
    {
        CPTPlotSpaceAnnotation *oldAnnotation = [plot.graph.plotAreaFrame.plotArea.annotations objectAtIndex:_annotationRef];
        [plot.graph.plotAreaFrame.plotArea removeAnnotation:oldAnnotation];
        _annotationRef--;
    }
    [plot.graph.plotAreaFrame.plotArea addAnnotation:amountAnnotation];
}

#pragma mark - CPTBarPlotDelegate methods
-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickplot:atIndex:)])
    {
        [self.delegate didClickplot:plot atIndex:index];
    }
}

#pragma mark - Rotation

- (void)refreshGraphWithDic:(NSMutableDictionary*)dic
{
    if (!dic) {
        _annotationRef = [_graphData count]-1;
        NSArray *keys = [self lastIsFirst:[_graphData allKeys]];
        keys = [[keys reverseObjectEnumerator] allObjects];
        for (int i=0; i<keys.count; i++)
        {
            NSUInteger randomNumber = arc4random() % 5 +7;
            CGFloat smallNumber = 1.0f/randomNumber+1;
            NSString *theKey = [keys objectAtIndex:i];
            NSString *theValue = [_graphData objectForKey:theKey];
            CGFloat theNewValue = roundf([[NSNumber numberWithInteger:[theValue integerValue]] integerValue]*smallNumber);
            NSNumber *number = [NSNumber numberWithInt:theNewValue];
            [_graphData setObject:number forKey:theKey];
        }

    }
    else
    {
        _graphData = dic;
    }
    [self.hostView.hostedGraph reloadData];
    [self configurePlots];
    [self configureAxes];
    [self reconfigureY];
}

@end