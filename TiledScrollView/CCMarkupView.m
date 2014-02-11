//
//  CCMarkupTileView.m
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/11/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCMarkupView.h"

CGFloat const kCCMarkupViewLineWidth = 10.f;

static CGRect CGRectForPoints(CGPoint point1, CGPoint point2)
{
    CGFloat pointRectSize = kCCMarkupViewLineWidth * 2;
    CGRect fromRect = CGRectMake(point1.x - kCCMarkupViewLineWidth/2, point1.y - kCCMarkupViewLineWidth/2, pointRectSize, pointRectSize);
    CGRect toRect = CGRectMake(point2.x - kCCMarkupViewLineWidth/2, point2.y - kCCMarkupViewLineWidth/2, pointRectSize, pointRectSize);
    return CGRectUnion(fromRect, toRect);
}

@interface CCMarkupView ()

@property (nonatomic) BOOL touchesMoved;
@property (nonatomic) CGPoint lastPoint;
@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, strong) NSMutableArray *completedPaths;
@property (nonatomic, strong) UIBezierPath *currentPath;
@end



@implementation CCMarkupView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _points = [NSMutableArray new];
        _completedPaths = [NSMutableArray new];
    }
    
    return self;
}

- (void)beginNewPath
{
    _currentPath = [UIBezierPath bezierPath];
    _currentPath.lineCapStyle = kCGLineCapRound;
    _currentPath.lineJoinStyle = kCGLineJoinRound;
    
    [_points removeAllObjects];
}

- (void)addPoint:(CGPoint)point toPath:(UIBezierPath *)path
{
    [_points addObject:[NSValue valueWithCGPoint:point]];
    
    if (_points.count == 1) {
        [path moveToPoint:point];
    }
    else {
        // Check mark type
        [path addLineToPoint:point];
    }
}

- (void)endPath:(UIBezierPath *)path atPoint:(CGPoint)point
{
    [self addPoint:point toPath:path];
    
    // Check mark type
    [_completedPaths addObject:path];
}

#pragma mark - UIResponder methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    UITouch *touch = [touches anyObject];
    _lastPoint = [touch locationInView:self];
    
    [self beginNewPath];
    [self addPoint:_lastPoint toPath:_currentPath];
    
    _touchesMoved = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    UITouch *touch = [touches anyObject];
    CGPoint newPoint = [touch locationInView:self];
    [self addPoint:newPoint toPath:_currentPath];

    [self setNeedsDisplayInRect:CGRectForPoints(_lastPoint, newPoint)];
    _lastPoint = newPoint;
    _touchesMoved = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    CGPoint endPoint = (_touchesMoved) ? [_points.lastObject CGPointValue] : _lastPoint;
    [self endPath:_currentPath atPoint:endPoint];
    [self setNeedsDisplayInRect:CGRectForPoints(_lastPoint, endPoint)];
}

#pragma mark - UIView methods

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, kCCMarkupViewLineWidth);

    [[UIColor orangeColor] setStroke];
    [self.completedPaths enumerateObjectsUsingBlock:^(UIBezierPath *path, NSUInteger idx, BOOL *stop) {
        if (CGRectIntersectsRect(rect, path.bounds)) {
            NSLog(@"STROKING PATH");
            CGContextAddPath(context, path.CGPath);
            CGContextStrokePath(context);
        }
    }];
    
    CGPoint firstPoint = [_points.firstObject CGPointValue];
    NSLog(@"MOVING TO POINT (%f, %f)", firstPoint.x, firstPoint.y);
    CGContextMoveToPoint(context, firstPoint.x, firstPoint.y);
    [self.points enumerateObjectsUsingBlock:^(NSValue *value, NSUInteger idx, BOOL *stop) {
        CGPoint point = [value CGPointValue];
        if (CGRectContainsPoint(rect, point)) {
            if (idx != 0) {
                NSLog(@"ADDING LINE POINT (%f, %f)", point.x, point.y);
                CGContextAddLineToPoint(context, point.x, point.y);
            }
        }
    }];
    CGContextStrokePath(context);

}

@end

