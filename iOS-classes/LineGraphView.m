//
//  LineGraphVC.m
//  MockMetrics
//
//  Created by Andrew McKinley on 9/19/13.
//
//

#import "LineGraphView.h"
#import "NSObject+ConversionTools.h"

@interface LineGraphView ()

// array of all keys in data
@property (strong, nonatomic) NSArray *allKeys;

// since the plots count backwards plotIndex starts with the last value (for the plot)
@property (readwrite, assign) NSUInteger plotIndex;

// The largest value present in the data
@property (readwrite, assign) CGFloat highestYValue;

// The largest value +12%
@property (readwrite, assign) CGFloat maxGraphYWithPadding;

// The graph itself
@property (strong, nonatomic) CPTXYGraph *graph;

// The view layer that hosts the graph
@property (nonatomic, strong) CPTGraphHostingView *hostView;

// When isCumulative is set to YES, this is the current value added to all previous values for the plot
@property (readwrite, assign) NSUInteger cumulativeValue;

// When isCumulative is set to YES, this is the current value added to all previous values for the annotations
@property (readwrite, assign) NSUInteger cumulativeLabel;

// since the plots count backwards plotIndex starts with the last value (for the annotations)
@property (readwrite, assign) NSUInteger labelReference;

// Amount of data annotations to skip to maintain approx xLabelCount
@property (readwrite, assign) NSUInteger labelSkipReference;

// Safeguard to make sure the plot is added to the graph only once
@property (readwrite, assign) BOOL isPlotAdded;

// Create graph and hostview and added them to the main view
- (void)initializeComponents;

// Congigure graph dimensions and graph title if needed
- (void)configureGraph;

// Calculate all necessary data derivatives 
- (void)analyzeData;

// set all necessary parameters to plot data 
- (void)configurePlotSpace;

- (void)configureXAxis:(CPTMutableTextStyle*)axisTextStyle axisLineStyle:(CPTMutableLineStyle*)axisLineStyle axisTitleStyle:(CPTMutableTextStyle*)axisTitleStyle;

- (void)configureYAxis:(CPTMutableTextStyle*)axisTextStyle axisLineStyle:(CPTMutableLineStyle*)axisLineStyle axisTitleStyle:(CPTMutableTextStyle*)axisTitleStyle;

@end

@implementation LineGraphView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _allKeys = [self reorderDates:[_data allKeys]];
        _plotIndex = _allKeys.count;
        _isPlotAdded = NO;
        _changeLablesOnClick = YES;
        if (!_xLabelCount)
        {
            _xLabelCount = 4;
        }
        if (!_lineColor)
        {
            _lineColor = [CPTColor redColor];
        }
        if (!_headerColor)
        {
            _headerColor = [CPTColor redColor];
        }
        if (!_yLabelCount)
        {
            _yLabelCount = 3;
        }
        _labelSkipReference = (_data.count - (_data.count%_xLabelCount))/_xLabelCount;
        _labelReference = 0;
        [self analyzeData];
        [self initializeComponents];
        [self configureGraph];
        [self configurePlotSpace];
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTapGesture)];
        
        // Specify that the gesture must be a single tap
        tapRecognizer.numberOfTapsRequired = 1;
        
        // Add the tap gesture recognizer to the view
        [self addGestureRecognizer:tapRecognizer];

    }
    return self;
}

-(void)resetGraph
{
    [_graph reloadData];
    [self configurePlotSpace];
}

-(void)respondToTapGesture
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickGraph)])
    {
        [self.delegate didClickGraph];
    }
    if (_changeLablesOnClick)
    {
        _cumulativeValue = 0;
        _labelReference++;
        if (_labelReference >=_labelSkipReference)
        {
            _labelReference= 0;
        }
        [_graph reloadData];
        [self configurePlotSpace];
    }
}

#pragma mark - UIViewController lifecycle methods

- (void)initializeComponents
{
    if (!_graph)
    {
        _graph = [[CPTXYGraph alloc] initWithFrame:self.bounds];
    }
    
    if (!_hostView)
    {
        _hostView = [[CPTGraphHostingView alloc] initWithFrame:self.bounds];
    }
    
    if (!_bottomPadding)
    {
        _bottomPadding = 80;
    }
    
    _hostView.hostedGraph = _graph;
    
    CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
    [_graph applyTheme:theme];
    
	[self addSubview:_hostView];

}

- (void)configureGraph
{
    _graph.paddingLeft = 0;
	_graph.paddingTop = 0;
	_graph.paddingRight = 0;
	_graph.paddingBottom = 0;
    
    _graph.plotAreaFrame.paddingLeft = 50.0 ;
    _graph.plotAreaFrame.paddingTop = 30.0 ;
    _graph.plotAreaFrame.paddingRight = 5.0 ;
    _graph.plotAreaFrame.paddingBottom = _bottomPadding ;
    
    if (_graphHeader)
    {
        // Set up styles
        CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
        titleStyle.color = _headerColor;
        titleStyle.fontName = @"Helvetica-Bold";
        titleStyle.fontSize = 16.0f;
        
        // Set up title
        _graph.title = _graphHeader;
        _graph.titleTextStyle = titleStyle;
        _graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    }
}

- (void)analyzeData
{
    _highestYValue = 0;
    for (int i=0; i<_data.count; i++)
    {
        // Calculate the highest Y value
        NSArray *keys = [self lastIsFirst:[_data allKeys]];
        keys = [[keys reverseObjectEnumerator] allObjects];
        NSString *theKey = [keys objectAtIndex:i];
        CGFloat maxY = [[_data objectForKey:theKey] intValue];
        if (maxY > _highestYValue && !_isCumulative)
        {
            _highestYValue = maxY;
        }
        else if (_isCumulative)
        {
            _highestYValue = _highestYValue + maxY;
        }
    }
    if (_highestYValue < 10)
    {
        _highestYValue = 10;
    }
    
    if (_setMaxYValue)
    {
        _highestYValue = _setMaxYValue;
    }
    _maxGraphYWithPadding = _highestYValue + (_highestYValue*0.12); // 12% space at the top of the graph
}

- (void)configurePlotSpace
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)_graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = NO;
    
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.5) length:CPTDecimalFromFloat((_data.count+(_data.count*0.2)))];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(_maxGraphYWithPadding)];
    
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor blackColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor blackColor];
    
    CPTMutableTextStyle *axisTextStyle;
    if (!axisTextStyle)
    {
        axisTextStyle = [[CPTMutableTextStyle alloc] init];
    }
    axisTextStyle.color = [CPTColor blackColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 11.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 1.0f;
    
    CPTScatterPlot *scatterPlot;
    if (!scatterPlot)
    {
        scatterPlot = [[CPTScatterPlot alloc] init];
    }
    scatterPlot.dataSource = self;
    scatterPlot.identifier = @"data";
    NSNumberFormatter *labelFormatter;
    if (!labelFormatter)
    {
        labelFormatter = [[NSNumberFormatter alloc] init];
    }
    labelFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    CPTColor *aaplColor = _lineColor;
    
    CPTMutableLineStyle *lineStyle = [scatterPlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth = 2.f;
    lineStyle.lineColor = aaplColor;
    scatterPlot.dataLineStyle = lineStyle;
    scatterPlot.opacity = 1.0f;
    
    if (_isPlotAdded == NO)
    {
        _isPlotAdded = YES;
        [_graph addPlot:scatterPlot];
    }
    
    [self configureXAxis:axisTextStyle axisLineStyle:axisLineStyle axisTitleStyle:axisTitleStyle];
    [self configureYAxis:axisTextStyle axisLineStyle:axisLineStyle axisTitleStyle:axisTitleStyle];
}

- (void)configureXAxis:(CPTMutableTextStyle*)axisTextStyle axisLineStyle:(CPTMutableLineStyle*)axisLineStyle  axisTitleStyle:(CPTMutableTextStyle*)axisTitleStyle
{
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    
    CPTXYAxis *x = axisSet.xAxis ;
    x.minorTickLineStyle = nil ;
    x.majorIntervalLength = CPTDecimalFromString (@"50");
    x.orthogonalCoordinateDecimal = CPTDecimalFromString ( @"0" );
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = 15.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;
    x.title = _xAxisLabel;
    
    CGFloat dateCount = [_data count];
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
    for (int i=0; i<_allKeys.count;i++)
    {
        if (i%_labelSkipReference == _labelReference)
        {
            CPTAxisLabel *label;
            if (i == (_allKeys.count -1))
            {
                //extra space for the last label
                 label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%@   ",[_allKeys objectAtIndex:i]]  textStyle:x.labelTextStyle];
            }
            else
            {
                 label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%@",[_allKeys objectAtIndex:i]]  textStyle:x.labelTextStyle];
            }
            label.tickLocation = CPTDecimalFromCGFloat(i);
            label.offset = x.majorTickLength;
            if (label)
            {
                [xLabels addObject:label];
                [xLocations addObject:[NSNumber numberWithFloat:i]];
            }
        }
    }
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
}

- (void)configureYAxis:(CPTMutableTextStyle*)axisTextStyle axisLineStyle:(CPTMutableLineStyle*)axisLineStyle  axisTitleStyle:(CPTMutableTextStyle*)axisTitleStyle
{
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    CPTXYAxis *y = axisSet.yAxis ;
    
    y.minorTickLineStyle = nil ;
    
    y.majorIntervalLength = CPTDecimalFromString ( @"50" );
    
    y.orthogonalCoordinateDecimal = CPTDecimalFromString (@"0");
    
    // 4 - Configure y-axis
    y.title = _yAxisLabel;
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = -40.0f;
    y.axisLineStyle = axisLineStyle;
    //    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 16.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    y.labelAlignment = CPTAlignmentRight;
    NSInteger majorIncrement = _highestYValue/_yLabelCount;
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    for (int i =0; i<=_yLabelCount; i++)
    {
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", (majorIncrement*i)] textStyle:y.labelTextStyle];
        if (_isCurrency)
        {
            label = [[CPTAxisLabel alloc] initWithText:[ self numbersToDollars:[NSString stringWithFormat:@"%i", (majorIncrement*i)]] textStyle:y.labelTextStyle];
        }
        NSDecimal location = CPTDecimalFromInteger(majorIncrement*i);
        label.tickLocation = location;
        label.offset = -50;
        if (label)
        {
            [yLabels addObject:label];
        }
        [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
    }
    y.axisLabels = yLabels;
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations;
}

#pragma mark - CPTPlotDataSource methods
- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [_data count];
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSInteger valueCount = [_data count];
    NSNumber *num = nil;
    switch (fieldEnum)
    {
        case CPTScatterPlotFieldX:
            if (index < valueCount)
            {
                num = [NSNumber numberWithUnsignedInteger:index];
                if (_plotIndex > 0)
                {
                    _plotIndex = _plotIndex-1;
                }
                return [NSNumber numberWithUnsignedInteger:index];
            }
            break;
        case CPTScatterPlotFieldY:
            if (!_isCumulative)
            {
                return [_data objectForKey:[_allKeys objectAtIndex:index]];
            }
            else
            {
                _cumulativeValue = _cumulativeValue + [[_data objectForKey:[_allKeys objectAtIndex:index]] intValue];
                return [NSNumber numberWithInt:_cumulativeValue];
            }
            break;
        default:
            return [NSDecimalNumber zero];
    }
    return [NSDecimalNumber zero];
}

- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    CPTTextLayer *label;
    NSString *labelText;
    if (index == 0)
    {
        _cumulativeLabel = 0;
    }
    _cumulativeLabel = _cumulativeLabel + [[_data objectForKey:[_allKeys objectAtIndex:index]] intValue];
    if (index%_labelSkipReference == _labelReference)
    {
        if (!_isCumulative)
        {
            labelText = [NSString stringWithFormat:@"%@",[_data objectForKey:[_allKeys objectAtIndex:index]]];
        }
        else
        {
            labelText = [NSString stringWithFormat:@"%i",_cumulativeLabel];
        }
        if (!label)
        {
            label = [[CPTTextLayer alloc] initWithText:labelText];
        }
        else
        {
            label.text = labelText;
        }
        if (_isCurrency)
        {
            label.text = [self numbersToDollars:labelText];
        }
        plot.labelRotation = 0.52;
        CPTMutableTextStyle *textStyle = [label.textStyle mutableCopy];
        textStyle.color = [CPTColor blackColor];
        label.textStyle = textStyle;
    }
    return label;
}

@end