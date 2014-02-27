//
//  DoubleLineGraphVC.m
//
//  Created by Andrew McKinleyon 11/26/13.
//
//

#import "DoubleLineGraphView.h"
#import "NSObject+ConversionTools.h"

@interface DoubleLineGraphView ()

// array of all keys in data
@property (strong, nonatomic) NSArray *allKeysOne;

// array of all keys in data
@property (strong, nonatomic) NSArray *allKeysTwo;

@property (strong, nonatomic) NSMutableArray *cumuKeys;

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

// When isCumulative is set to YES, this is the current value added to all previous values for the plot
@property (readwrite, assign) NSUInteger cumulativeValue2;

// When isCumulative is set to YES, this is the current value added to all previous values for the annotations
@property (readwrite, assign) NSUInteger cumulativeLabel2;

// since the plots count backwards plotIndex starts with the last value (for the annotations)
@property (readwrite, assign) NSUInteger labelReference;

// Amount of data annotations to skip to maintain approx xLabelCount
@property (readwrite, assign) NSUInteger labelSkipReference;

@property (readwrite, assign) NSUInteger labelCounter1;

@property (readwrite, assign) NSUInteger labelCounter2;

@property (readwrite, assign) NSUInteger indexCounter1;

@property (readwrite, assign) NSUInteger indexCounter2;

@property (readwrite, assign) NSUInteger xIndexCounter2;

// Safeguard to make sure the plot is added to the graph only once
@property (readwrite, assign) BOOL isPlotAdded;

// Safeguard to make sure the plot is added to the graph only once
@property (readwrite, assign) BOOL isSecondPlotAdded;

typedef enum plots
{
    firstPlotReference,
    secondPlotReference,
}plotEnum;

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

@implementation DoubleLineGraphView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _allKeysOne = [self reorderDates:[_dataSetOne allKeys]];
        _cumuKeys = [NSMutableArray arrayWithArray:[self reorderDates:[_dataSetOne allKeys]]];
        _allKeysTwo = [self reorderDates:[_dataSetTwo allKeys]];
        for (NSString *key in _allKeysTwo)
        {
            if (![_allKeysOne containsObject:key])
            {
                [_cumuKeys addObject:key];
            }
        }
        _plotIndex = _cumuKeys.count;
        _isPlotAdded = NO;
        _isSecondPlotAdded = NO;
        _changeLablesOnClick = YES;
        if (!_xLabelCount)
        {
            _xLabelCount = 4;
        }
        if (!_firstLineColor)
        {
            _firstLineColor = [CPTColor redColor];
        }
        if (!_secondLineColor)
        {
            _secondLineColor = [CPTColor yellowColor];
        }
        if (!_titleColor)
        {
            _titleColor = [CPTColor redColor];
        }
        if (!_yLabelCount)
        {
            _yLabelCount = 3;
        }
        _labelSkipReference = (_dataSetOne.count - (_dataSetOne.count%_xLabelCount))/_xLabelCount;
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
        _labelCounter1 = 0;
        _labelCounter2 = 0;
        _indexCounter1 = 0;
        _indexCounter2 = 0;
        _xIndexCounter2 = 0;
        _cumulativeValue = 0;
        _cumulativeValue2 = 0;
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
        titleStyle.color = _titleColor;
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
    _labelCounter1 = 0;
    _labelCounter2 = 0;
    _indexCounter1 = 0;
    _indexCounter2 = 0;
    _xIndexCounter2 = 0;
    if (_isCumulative)
    {
        for (NSString *value in _cumuKeys)
        {
            if ([_dataSetOne objectForKey:value] && ![_dataSetTwo objectForKey:value])
            {
                _highestYValue = _highestYValue + [[_dataSetOne objectForKey:value] intValue];
            }
            else if (![_dataSetOne objectForKey:value] && [_dataSetTwo objectForKey:value])
            {
                _highestYValue = _highestYValue + [[_dataSetTwo objectForKey:value] intValue];
            }
            else
            {
                if ([[_dataSetTwo objectForKey:value] intValue] > [[_dataSetOne objectForKey:value] intValue])
                {
                    _highestYValue = _highestYValue + [[_dataSetTwo objectForKey:value] intValue];
                }
                else
                {
                    _highestYValue = _highestYValue + [[_dataSetOne objectForKey:value] intValue];
                }
            }
        }
    }
    else
    {
        for (int i=0; i<_cumuKeys.count; i++)
        {
            // Calculate the highest Y value
            NSArray *keys = [self lastIsFirst:[_dataSetOne allKeys]];
            keys = [[keys reverseObjectEnumerator] allObjects];
            NSString *theKey = [keys objectAtIndex:i];
            CGFloat maxY = [[_dataSetOne objectForKey:theKey] intValue];
            if (maxY > _highestYValue && !_isCumulative)
            {
                _highestYValue = maxY;
            }
        }
        
        for (int i=0; i<_cumuKeys.count; i++)
        {
            // Calculate the highest Y value
            NSArray *keys = [self lastIsFirst:[_dataSetTwo allKeys]];
            keys = [[keys reverseObjectEnumerator] allObjects];
            NSString *theKey = [keys objectAtIndex:i];
            CGFloat maxY = [[_dataSetTwo objectForKey:theKey] intValue];
            if (maxY > _highestYValue && !_isCumulative)
            {
                _highestYValue = maxY;
            }
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
    
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.5) length:CPTDecimalFromFloat((_dataSetOne.count+(_dataSetOne.count*0.2)))];
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
    
    // !!!! first Plot
    CPTScatterPlot *firstScatterPlot;
    if (!firstScatterPlot)
    {
        firstScatterPlot = [[CPTScatterPlot alloc] init];
    }
    firstScatterPlot.dataSource = self;
    firstScatterPlot.identifier = [NSNumber numberWithInteger:firstPlotReference];

    NSNumberFormatter *labelFormatter;
    if (!labelFormatter)
    {
        labelFormatter = [[NSNumberFormatter alloc] init];
    }
    labelFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    CPTColor *aaplColor = _firstLineColor;
    
    CPTMutableLineStyle *lineStyle = [firstScatterPlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth = 2.f;
    lineStyle.lineColor = aaplColor;
    firstScatterPlot.dataLineStyle = lineStyle;
    firstScatterPlot.opacity = 1.0f;
    
    if (_isPlotAdded == NO)
    {
        _isPlotAdded = YES;
        [_graph addPlot:firstScatterPlot];
    }
    
    // !!! second plot
    CPTScatterPlot *secondScatterPlot;
    if (!secondScatterPlot)
    {
        secondScatterPlot = [[CPTScatterPlot alloc] init];
    }
    secondScatterPlot.dataSource = self;
    secondScatterPlot.identifier = [NSNumber numberWithInteger:secondPlotReference];
    NSNumberFormatter *secondLabelFormatter;
    if (!secondLabelFormatter)
    {
        secondLabelFormatter = [[NSNumberFormatter alloc] init];
    }
    secondLabelFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    CPTColor *secondColor = _secondLineColor;
    
    CPTMutableLineStyle *secondLineStyle = [firstScatterPlot.dataLineStyle mutableCopy];
    secondLineStyle.lineWidth = 2.f;
    secondLineStyle.lineColor = secondColor;
    secondScatterPlot.dataLineStyle = secondLineStyle;
    secondScatterPlot.opacity = 1.0f;
    
    if (_isSecondPlotAdded == NO)
    {
        _isSecondPlotAdded = YES;
        [_graph addPlot:secondScatterPlot];
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
    
    CGFloat dateCount = [_dataSetOne count];
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
    for (int i=0; i<_cumuKeys.count;i++)
    {
        if (i%_labelSkipReference == _labelReference)
        {
            CPTAxisLabel *label;
            if (i == (_cumuKeys.count -1))
            {
                //extra space for the last label
                label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%@   ",[_cumuKeys objectAtIndex:i]]  textStyle:x.labelTextStyle];
            }
            else
            {
                label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%@",[_cumuKeys objectAtIndex:i]]  textStyle:x.labelTextStyle];
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
    return [_dataSetOne count];
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSInteger valueCount = [_dataSetOne count];
 //   NSInteger valueCount2 = [_dataSetTwo count];
    NSNumber *num = nil;
    if (index == 0)
    {
        _indexCounter1 = 0;
        _indexCounter2 = 0;
        _xIndexCounter2 = 0;
    }
    if ([plot.identifier isEqual:[NSNumber numberWithInteger:firstPlotReference]])
    {
        if ([_dataSetOne objectForKey:[_cumuKeys objectAtIndex:index]])
        {
            switch (fieldEnum)
            {
                case CPTScatterPlotFieldX:
                    if (_indexCounter1 < valueCount)
                    {
                        num = [NSNumber numberWithUnsignedInteger:_indexCounter1];
                        if (_plotIndex > 0)
                        {
                            _plotIndex = _plotIndex-1;
                        }
                        _indexCounter1++;
          //              NSLog(@"1 x return %lu for plot.identifier %@ with index %i",(unsigned long)_indexCounter1,plot.identifier, index);
                        return [NSNumber numberWithUnsignedInteger:_indexCounter1];
                    }
                    break;
                case CPTScatterPlotFieldY:
                    if (!_isCumulative)
                    {
                        _indexCounter1++;
        //                NSLog(@"1y cumu return %@ for plot.identifier %@ with index %i",[_allKeysTwo objectAtIndex:_indexCounter1] ,plot.identifier, index);
                        return [_dataSetOne objectForKey:[_allKeysOne objectAtIndex:_indexCounter1]];
                    }
                    else
                    {
                        _cumulativeValue = _cumulativeValue + [[_dataSetOne objectForKey:[_allKeysOne objectAtIndex:_indexCounter1]] intValue];
                        _indexCounter1++;
         //               NSLog(@"1y not cumu return 0 for plot.identifier %@ with index %i",plot.identifier, index);
                        return [NSNumber numberWithInt:_cumulativeValue];
                    }
                    break;
                default:
                    _indexCounter1++;
       //             NSLog(@"1xy default return 0 for plot.identifier %@ with index %i",plot.identifier, index);
                    return [NSDecimalNumber zero];
            }
        }
    }
    else
    {
        if ([_dataSetTwo objectForKey:[_cumuKeys objectAtIndex:index]])
        {
            switch (fieldEnum)
            {
                case CPTScatterPlotFieldX:
     //               if (_indexCounter2 < valueCount2)
     //               {
                        num = [NSNumber numberWithUnsignedInteger:_indexCounter2];
                        if (_plotIndex > 0)
                        {
                            _plotIndex = _plotIndex-1;
                        }
                        _xIndexCounter2++;
           //             NSLog(@"2 x return %lu for plot.identifier %@ with index %i",(unsigned long)_indexCounter2 ,plot.identifier, index);
                        return [NSNumber numberWithUnsignedInteger:_xIndexCounter2];
 //                   }
                    break;
                case CPTScatterPlotFieldY:
                    if (!_isCumulative)
                    {
                        _indexCounter2++;
           //             NSLog(@"2y cumu return %@ for plot.identifier %@ with index %i",[_allKeysTwo objectAtIndex:_indexCounter2] ,plot.identifier, index);
                        return [_dataSetTwo objectForKey:[_allKeysTwo objectAtIndex:_indexCounter2]];
                    }
                    else
                    {
                        _cumulativeValue2 = _cumulativeValue2 + [[_dataSetTwo objectForKey:[_allKeysTwo objectAtIndex:_indexCounter2]] intValue];
                        _indexCounter2++;
           //             NSLog(@"2y not cumu return 0 for plot.identifier %@ with index %i",plot.identifier, index);
                        return [NSNumber numberWithInt:_cumulativeValue2];
                    }
                    break;
                default:
                    _indexCounter2++;
           //         NSLog(@"2xy default return 0 for plot.identifier %@ with index %i",plot.identifier, index);
                    return [NSNumber numberWithInt:0];
            }
        }
        else
        {
            _xIndexCounter2++;
    //        NSLog(@"2 x return %lu for plot.identifier %@ with index %i",(unsigned long)_indexCounter2 ,plot.identifier, index);
            return [NSNumber numberWithUnsignedInteger:_xIndexCounter2];
        }
    }
//  NSLog(@"2 end return 0 for plot.identifier %@ with index %i",plot.identifier, index);
    return [NSNumber numberWithInt:0];
}

- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    CPTTextLayer *label;
    if (index == 0)
    {
        _cumulativeLabel = 0;
        _cumulativeLabel2 = 0;
    }
    if ([plot.identifier isEqual:[NSNumber numberWithInteger:firstPlotReference]])
    {
        if ([_allKeysOne containsObject:[_cumuKeys objectAtIndex:index]])
        {
            NSString *labelText;
            _cumulativeLabel = _cumulativeLabel + [[_dataSetOne objectForKey:[_allKeysOne objectAtIndex:_labelCounter1]] intValue];
            if (_labelCounter1%_labelSkipReference == _labelReference)
            {
                if (!_isCumulative)
                {
                    labelText = [NSString stringWithFormat:@"%@",[_dataSetOne objectForKey:[_allKeysOne objectAtIndex:_labelCounter1]]];
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
                plot.labelOffset = _labelOffsetDataSetOne;
                CPTMutableTextStyle *textStyle = [label.textStyle mutableCopy];
                textStyle.color = [CPTColor blackColor];
                label.textStyle = textStyle;
            }
            _labelCounter1++;
            return label;
        }
    }
    else
    {
        if ([_allKeysTwo containsObject:[_cumuKeys objectAtIndex:index]])
        {
            NSString *labelText;
            _cumulativeLabel2 = _cumulativeLabel2 + [[_dataSetTwo objectForKey:[_allKeysTwo objectAtIndex:_labelCounter2]] intValue];
            if (_labelCounter2%_labelSkipReference == _labelReference)
            {
                if (!_isCumulative)
                {
                    labelText = [NSString stringWithFormat:@"%@",[_dataSetTwo objectForKey:[_allKeysTwo objectAtIndex:_labelCounter2]]];
                }
                else
                {
                    labelText = [NSString stringWithFormat:@"%i",_cumulativeLabel2];
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
                plot.labelOffset = _labelOffsetDataSetTwo
                ;
                CPTMutableTextStyle *textStyle = [label.textStyle mutableCopy];
                textStyle.color = [CPTColor blackColor];
                label.textStyle = textStyle;
            }
            _labelCounter2++;
            return label;
        }
    }
    return nil;
}
@end