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

@interface CCCanvasView ()

@property (nonatomic) BOOL touchesMoved;
@property (nonatomic, getter = isTrackingTouch) BOOL trackingTouch;

@property (nonatomic) CGPoint currentPoint;
@property (nonatomic) CGPoint previousPoint1;
@property (nonatomic) CGPoint previousPoint2;

@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, strong) NSMutableArray *completedPaths;

@property (nonatomic, readonly) NSArray *pointsTracked;

@end

@implementation CCCanvasView

#pragma mark - UIView Methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _completedPaths = [NSMutableArray new];
        _points = [NSMutableArray new];
        _strokeColor = [UIColor orangeColor];
        _strokeWidth = kCCCanvasViewDefaultLineWidth;
        _trackType = CCCanvasViewTrackTypeFreeHand;
        _trackingTouch = NO;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self configureContext:context];
    
    switch (_trackType) {
        case CCCanvasViewTrackTypeFreeHand:
            [self drawFreeHandPathInRect:rect context:context];
            break;
        case CCCanvasViewTrackTypeLine:
            [self drawLineInRect:rect context:context];
            break;
        case CCCanvasViewTrackTypePin:
            // Don't draw pin just report tracked point
            break;
        case CCCanvasViewTrackTypeShape:
            
            break;
        case CCCanvasViewTrackTypeDebug:
            [self drawDebugInRect:rect context:context];
            break;
        default:
            break;
    }
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
    // Draw previous lines
    
    // Draw new line anchored from end of last line
    CGPoint anchorPoint = [_points.firstObject CGPointValue];
    CGContextMoveToPoint(context, anchorPoint.x, anchorPoint.y);
    
    CGPoint endPoint = [_points.lastObject CGPointValue];
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    
    CGContextStrokePath(context);
}

#pragma mark - Point Tracking

- (void)updateTrackedPointsWithTouch:(UITouch *)touch
{
    switch (_trackType) {
        case CCCanvasViewTrackTypeFreeHand:
        {
            _previousPoint2 =  (self.isTrackingTouch) ? _previousPoint1 : [touch previousLocationInView:self];
            _previousPoint1 = [touch previousLocationInView:self];
            _currentPoint = [touch locationInView:self];
            break;
        }
        case CCCanvasViewTrackTypeLine:
        {
            
            break;
        }
        case CCCanvasViewTrackTypeShape:
        {
            
            break;
        }
        case CCCanvasViewTrackTypePin:
        {
            _currentPoint = [touch locationInView:self];
            break;
        }
        case CCCanvasViewTrackTypeDebug:
        {
            _previousPoint2 =  (self.isTrackingTouch) ? _previousPoint1 : [touch previousLocationInView:self];
            _previousPoint1 = [touch previousLocationInView:self];
            _currentPoint = [touch locationInView:self];
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
    [_points addObject:[NSValue valueWithCGPoint:point]];
}

- (void)finishTrackingPoints
{
    if ([_delegate respondsToSelector:@selector(canvasView:didFinishTrackingPoints:)]) {
        [_delegate canvasView:self didFinishTrackingPoints:self.pointsTracked];
    }
    
    UIBezierPath *completedPath = [self bezierPathForPoints];
    
    if ([_delegate respondsToSelector:@selector(canvasView:didFinishPath:)]) {
        [_delegate canvasView:self didFinishPath:completedPath];
    }
    
    [_points removeAllObjects];
    [_completedPaths addObject:completedPath];
}

#pragma mark - UIBezier Path Methods

- (NSArray *)pointsTracked
{
    switch (_trackType) {
        case CCCanvasViewTrackTypeFreeHand:
            return _points;
        case CCCanvasViewTrackTypeLine:
            return @[_points.firstObject, _points.lastObject];
        case CCCanvasViewTrackTypeShape:
        case CCCanvasViewTrackTypePin:
            return @[_points.lastObject];
        case CCCanvasViewTrackTypeDebug:
        default:
            break;
    }
    
    return nil;
}

- (UIBezierPath *)bezierPathForPoints
{
    switch (_trackType) {
        case CCCanvasViewTrackTypeFreeHand:
            return [UIBezierPath curvePathForPoints:_points];
        case CCCanvasViewTrackTypeLine:
            return [UIBezierPath straightPathForPoints:_points];
        case CCCanvasViewTrackTypeShape:
        case CCCanvasViewTrackTypePin:
            return [UIBezierPath straightPathForPoints:@[_points.lastObject]];
        case CCCanvasViewTrackTypeDebug:
        default:
            break;
    }
    
    return nil;
}

#pragma mark - Accessor Methods

#pragma mark - UIResponder methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    [self updateTrackedPointsWithTouch:touch];
    [self addTrackedPoint:_currentPoint];
    
    _trackingTouch = YES;
    _touchesMoved = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    [self updateTrackedPointsWithTouch:touch];
    [self addTrackedPoint:_currentPoint];
    
    [self setNeedsDisplay];
    _touchesMoved = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    [self updateTrackedPointsWithTouch:touch];
    [self addTrackedPoint:_currentPoint];
    [self finishTrackingPoints];
    
    [self setNeedsDisplay];
    _trackingTouch = NO;
}

#pragma mark - Quartz Drawing

- (void)configureContext:(CGContextRef)context
{
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, kCCCanvasViewDefaultLineWidth);
    [self.strokeColor setStroke];
}

@end

