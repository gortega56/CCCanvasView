//
//  CCMarkupTileView.m
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/11/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCMarkupView.h"

CGFloat const kCCMarkupViewLineWidth = 10.f;

@interface CCMarkupView ()

@property (nonatomic) BOOL touchesMoved;
@property (nonatomic, getter = isTrackingTouch) BOOL trackingTouch;
@property (nonatomic) CGPoint currentPoint;
@property (nonatomic) CGPoint previousPoint1;
@property (nonatomic) CGPoint previousPoint2;

@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, strong) NSMutableArray *completedPaths;

@end

@implementation CCMarkupView

#pragma mark - UIView Methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _completedPaths = [NSMutableArray new];
        _points = [NSMutableArray new];
        _strokeColor = [UIColor orangeColor];
        _strokeWidth = kCCMarkupViewLineWidth;
        _trackingTouch = NO;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self configureContext:context];
    
    // Current path being drawn
   // NSLog(@"STROKING %lu POINTS", (unsigned long)_points.count);
    __block CGPoint currentPoint = [_points.firstObject CGPointValue];
    __block CGPoint previousPoint1 = currentPoint;
    __block CGPoint previousPoint2;
    
    [_points enumerateObjectsUsingBlock:^(NSValue *value, NSUInteger idx, BOOL *stop) {
        previousPoint2 = previousPoint1;
        previousPoint1 = currentPoint;
        currentPoint = [value CGPointValue];
        if (CGRectContainsPoint(rect, currentPoint)) {
            CGPoint midPoint1 = CGMidpointForPoints(previousPoint1, previousPoint2);
            CGPoint midPoint2 = CGMidpointForPoints(currentPoint, previousPoint1);
            CGContextMoveToPoint(context, midPoint1.x, midPoint1.y);
            CGContextAddQuadCurveToPoint(context, previousPoint1.x, previousPoint1.y, midPoint2.x, midPoint2.y);
            CGContextStrokePath(context);
        }
    }];
}

#pragma mark - Point Tracking

- (void)updateTrackedPointsWithTouch:(UITouch *)touch
{
    _previousPoint2 =  (self.isTrackingTouch) ? _previousPoint1 : [touch previousLocationInView:self];
    _previousPoint1 = [touch previousLocationInView:self];
    _currentPoint = [touch locationInView:self];
    
    if ([_delegate respondsToSelector:@selector(markView:didTrackPoint:)]) {
        [_delegate markView:self didTrackPoint:_currentPoint];
    }
}

- (void)addTrackedPoint:(CGPoint)point
{
    [_points addObject:[NSValue valueWithCGPoint:point]];
}

- (void)finishTrackingPoints
{
    if ([_delegate respondsToSelector:@selector(markView:didFinishTrackingPoints:)]) {
        [_delegate markView:self didFinishTrackingPoints:_points];
    }
    
    UIBezierPath *completedPath = bezierPathForPoints(_points);
    
    if ([_delegate respondsToSelector:@selector(markView:didFinishPath:)]) {
        [_delegate markView:self didFinishPath:completedPath];
    }
    
    [_points removeAllObjects];
    [_completedPaths addObject:completedPath];
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
    CGContextSetLineWidth(context, kCCMarkupViewLineWidth);
    [self.strokeColor setStroke];
}

@end

