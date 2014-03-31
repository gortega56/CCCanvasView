//
//  CCMarkupTileView.m
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/11/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCCanvasView.h"
#import "UIBezierPath+CCAdditions.h"

CGFloat const kCCCanvasViewDefaultLineWidth = 10.f;
CGFloat const kCCCanvasViewAnchorPointRadius = 20.f;

@interface CCCanvasView ()

@property (nonatomic) BOOL touchesMoved;
@property (nonatomic, getter = isTrackingTouch) BOOL trackingTouch;

@property (nonatomic) CGPoint currentPoint;
@property (nonatomic) CGPoint previousPoint1;
@property (nonatomic) CGPoint previousPoint2;
@property (nonatomic, strong) NSMutableArray *points;

@property (nonatomic, strong) UIBezierPath *currentPath;

@end

@implementation CCCanvasView

#pragma mark - UIView Methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _points = [NSMutableArray new];
        _strokeColor = [UIColor orangeColor];
        _strokeWidth = kCCCanvasViewDefaultLineWidth;
        _trackType = CCCanvasViewTrackTypeFreeHand;
    }
    
    return self;
}

- (void)removeFromSuperview
{
    [self closeCurrentPath];
    [super removeFromSuperview];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self configureContext:context];
    
    if (_points.count == 0) {
        return;
    }
    
    switch (_trackType) {
        case CCCanvasViewTrackTypeFreeHand:
            [self drawFreeHandPathInRect:rect context:context];
            break;
        case CCCanvasViewTrackTypeUndefinedPolygon:
        case CCCanvasViewTrackTypePolygon:
            [self drawLineInRect:rect context:context];
            break;
        case CCCanvasViewTrackTypePin:
            // Don't draw pin just report tracked point
            break;
        case CCCanvasViewTrackTypeCircle:
            [self drawCircleInRect:rect context:context];
            break;
        case CCCanvasViewTrackTypeRectangle:
            [self drawRectangleInRect:rect context:context];
            break;
        case CCCanvasViewTrackTypeDebug:
            [self drawDebugInRect:rect context:context];
            break;
        default:
            break;
    }
}

#pragma mark - Quartz Drawing

- (void)configureContext:(CGContextRef)context
{
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, self.strokeWidth);
    [self.strokeColor setStroke];
}

- (void)drawDebugInRect:(CGRect)rect context:(CGContextRef)context
{
    CGFloat scale = CGContextGetCTM(context).a;
    CGFloat mSize = 100/scale;
    [[UIColor redColor] setFill];
    [_points enumerateObjectsUsingBlock:^(NSValue *value, NSUInteger idx, BOOL *stop) {
        CGPoint p = [value CGPointValue];
        p.x -= mSize/2;
        p.y -= mSize/2;
        CGContextFillEllipseInRect(context, (CGRect){p, .size = (CGSize){mSize, mSize}});
    }];
}

- (void)drawFreeHandPathInRect:(CGRect)rect context:(CGContextRef)context
{
    UIBezierPath *path = [UIBezierPath curvePathForPoints:_points];
    CGContextAddPath(context, path.CGPath);
    CGContextStrokePath(context);
}

- (void)drawLineInRect:(CGRect)rect context:(CGContextRef)context
{
    UIBezierPath *path = [UIBezierPath straightPathForPoints:_points];
    CGContextAddPath(context, path.CGPath);
    CGContextStrokePath(context);
}

- (void)drawCircleInRect:(CGRect)rect context:(CGContextRef)context
{
    UIBezierPath *path = [UIBezierPath circularPathForPoints:_points];
    CGContextAddPath(context, path.CGPath);
    CGContextStrokePath(context);
}

- (void)drawRectangleInRect:(CGRect)rect context:(CGContextRef)context
{
    UIBezierPath *path = [UIBezierPath rectanglePathForPoints:_points];
    CGContextAddPath(context, path.CGPath);
    CGContextStrokePath(context);
}

#pragma mark - Point Tracking

- (void)updateTrackedPointsWithCurrentPoint:(CGPoint)currentPoint previousPoint:(CGPoint)previousPoint trackingTouch:(BOOL)trackingTouch
{
    switch (_trackType) {
        case CCCanvasViewTrackTypeFreeHand:
        {
            _previousPoint2 =  (trackingTouch) ? _previousPoint1 : previousPoint;
            _previousPoint1 = previousPoint;
            _currentPoint = currentPoint;
            break;
        }
        case CCCanvasViewTrackTypeUndefinedPolygon:
        case CCCanvasViewTrackTypePolygon:
        {
            _previousPoint2 =  (_points.count == 0) ? currentPoint : _previousPoint2 ; // Set Close path Point
            _previousPoint1 = (trackingTouch) ? previousPoint : _previousPoint2;
            _currentPoint = currentPoint;
            if (CGFloatDistanceBetweenPoints(_currentPoint, _previousPoint2) < kCCCanvasViewAnchorPointRadius) {
                _currentPoint = _previousPoint2;
            }
            break;
        }
        case CCCanvasViewTrackTypeCircle:
        case CCCanvasViewTrackTypeRectangle:
            _previousPoint1 = (_points.count == 0) ? currentPoint : _previousPoint1;
            _currentPoint = currentPoint;
            break;
        case CCCanvasViewTrackTypePin:
        {
            _currentPoint = currentPoint;
            break;
        }
        case CCCanvasViewTrackTypeDebug:
        {
            _previousPoint2 =  (trackingTouch) ? [_points.firstObject CGPointValue] : currentPoint;
            _previousPoint1 = (trackingTouch) ? previousPoint : _previousPoint2;
            _currentPoint = currentPoint;
            
        }
        default:
            break;
    }
    
    if ([_delegate respondsToSelector:@selector(canvasView:didTrackPoint:)]) {
        [_delegate canvasView:self didTrackPoint:_currentPoint];
    }
}

- (void)addTrackedPoint:(CGPoint)point
{
    switch (_trackType) {
        case CCCanvasViewTrackTypeFreeHand:
        {
            [_points addObject:[NSValue valueWithCGPoint:point]];
            break;
        }
        case CCCanvasViewTrackTypeCircle:
        case CCCanvasViewTrackTypeRectangle:
        case CCCanvasViewTrackTypeUndefinedPolygon:
        case CCCanvasViewTrackTypePolygon:
        {
            if (_points.count < 2) {
                [_points addObject:[NSValue valueWithCGPoint:point]];
            }
            else if (_points.count == 2) {
                [_points removeLastObject];
                [_points addObject:[NSValue valueWithCGPoint:point]];
            }
            break;
        }
        case CCCanvasViewTrackTypePin:
        {
            [_points removeAllObjects];
            [_points addObject:[NSValue valueWithCGPoint:point]];
            break;
        }
        case CCCanvasViewTrackTypeDebug:
        default:
            break;
    }
}

- (void)finishTrackingPoints
{
    if ([_delegate respondsToSelector:@selector(canvasView:didFinishTrackingPoints:)]) {
        [_delegate canvasView:self didFinishTrackingPoints:_points];
    }
    
    [self finalizeCurrentPath];
}

- (void)finalizeCurrentPath
{
    switch (_trackType) {
        case CCCanvasViewTrackTypeFreeHand:
        {
            _currentPath = [UIBezierPath curvePathForPoints:_points];
            [_points removeAllObjects];
            break;
        }
        case CCCanvasViewTrackTypeUndefinedPolygon:
        case CCCanvasViewTrackTypePolygon:
        {
            [_currentPath appendPath:[UIBezierPath straightPathForPoints:_points]];
            (CGPointEqualToPoint(_currentPoint, _previousPoint2)) ? [_points removeAllObjects] : [_points removeObjectsInRange:NSMakeRange(0, _points.count-1)]; // Should leave last point in the array to be the anchor of next point
            break;
        }
        case CCCanvasViewTrackTypeCircle:
        {
            _currentPath = [UIBezierPath circularPathForPoints:_points];
            [_points removeAllObjects];
            break;
        }
        case CCCanvasViewTrackTypeRectangle:
        {
            _currentPath = [UIBezierPath rectanglePathForPoints:_points];
            [_points removeAllObjects];
            break;
        }
        case CCCanvasViewTrackTypePin:
        {
            _currentPath = [UIBezierPath straightPathForPoints:_points];
            [_points removeAllObjects];
            break;
        }
        case CCCanvasViewTrackTypeDebug:
            break;
        default:
            break;
    }
    
    if ([_delegate respondsToSelector:@selector(canvasView:didFinishPath:)]) {
        [_delegate canvasView:self didFinishPath:_currentPath];
    }
}

- (void)closeCurrentPath
{
    if (CGPointEqualToPoint(_currentPoint, _previousPoint2)) {
        return;
    }
    
    if (_trackType == CCCanvasViewTrackTypeUndefinedPolygon || _trackType == CCCanvasViewTrackTypePolygon) {
        [self updateTrackedPointsWithCurrentPoint:_previousPoint2 previousPoint:_currentPoint trackingTouch:YES];
        [self addTrackedPoint:_currentPoint];
        [self finishTrackingPoints];
        [self setNeedsDisplay];
    }
}

- (void)clearCurrentPathPoints
{
    [_points removeAllObjects];
    [_currentPath removeAllPoints];
    _currentPoint = CGPointZero;
    _previousPoint1 = CGPointZero;
    _previousPoint2 = CGPointZero;
    [self setNeedsDisplay];
}

#pragma mark - Accessor Methods

#pragma mark - UIResponder methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    [self updateTrackedPointsWithCurrentPoint:[touch locationInView:self] previousPoint:[touch previousLocationInView:self] trackingTouch:NO];
    [self addTrackedPoint:_currentPoint];
    _touchesMoved = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    [self updateTrackedPointsWithCurrentPoint:[touch locationInView:self] previousPoint:[touch previousLocationInView:self] trackingTouch:YES];
    [self addTrackedPoint:_currentPoint];
    [self setNeedsDisplay];
    _touchesMoved = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    [self updateTrackedPointsWithCurrentPoint:[touch locationInView:self] previousPoint:[touch previousLocationInView:self] trackingTouch:YES];
    [self addTrackedPoint:_currentPoint];
    [self finishTrackingPoints];
    [self setNeedsDisplay];
}

@end

