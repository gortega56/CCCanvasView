//
//  CCMarkupController.m
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/10/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCMarkupViewController.h"

NSString * const kCCBezierPathBuilderPointsKey = @"points";
NSString * const kCCBezierPathBuilderTypeKey = @"type";

CGFloat const kCCMarkupControllerTouchPointSize = 30.f;

@interface CCMarkupViewController () <CCBezierPathBuilderDelegate>

@property (nonatomic, strong) CCBezierPathBuilder *bezierPathBuilder;
@property (nonatomic, getter = isTrackingTouch) BOOL trackingTouch;
@property (nonatomic, strong) NSMutableArray *bezierPaths;
@property (nonatomic, strong) NSMutableArray *touchPoints;
@property (nonatomic) CGPoint lastPoint;


@end

@implementation CCMarkupViewController

- (id)init
{
    self = [super init];
    if (self) {
        
        _bezierPathBuilder = [[CCBezierPathBuilder alloc] init];
        _bezierPathBuilder.delegate = self;
        _trackingTouch = NO;
        
        _bezierPaths = [NSMutableArray new];
        _touchPoints = [NSMutableArray new];
        
    }

    return self;
}


- (void)panGestureRecognizedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGPoint touchPoint = [recognizer locationInView:recognizer.view];
    
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            _trackingTouch = YES;
            [_bezierPathBuilder beginPathAtPoint:touchPoint];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            [_bezierPathBuilder modifyCurrentPathWithPoint:touchPoint];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            _trackingTouch = NO;
            [_bezierPathBuilder finalizeCurrentPathWithPoint:touchPoint];
        }
            break;
        default:
            break;
    }
    [self.touchPoints addObject:[NSValue valueWithCGPoint:touchPoint]];
        _lastPoint = touchPoint;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return _shouldReceiveTouch;
}

#pragma mark - CCBezierPathBuilderDelegate

- (void)bezierPathBuilder:(CCBezierPathBuilder *)bezierPathBuilder didFinalizeCurrentPath:(UIBezierPath *)currentPath
{
    [_bezierPaths addObject:currentPath];
}

@end

@interface CCBezierPathBuilder ()


@end

@implementation CCBezierPathBuilder

- (id)initWithDelegate:(id<CCBezierPathBuilderDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    
    return self;
}

- (id)init
{
    return [self initWithDelegate:nil];
}

- (UIBezierPath *)newPath
{
    UIBezierPath *newPath = [UIBezierPath bezierPath];
    newPath.lineJoinStyle = kCGLineJoinRound;
    newPath.lineCapStyle = kCGLineCapRound;
    return newPath;
}

- (void)beginPathAtPoint:(CGPoint)point
{
    _currentPath = [self newPath];
    [_currentPath moveToPoint:point];
}

- (void)modifyCurrentPathWithPoint:(CGPoint)point
{
    [_currentPath addLineToPoint:point];
}

- (void)finalizeCurrentPathWithPoint:(CGPoint)point
{
    // Perform any finalizing operations based on the type of markup tool being used.
    [_currentPath addLineToPoint:point];
    [self.delegate bezierPathBuilder:self didFinalizeCurrentPath:_currentPath];
    
}

@end

static void CGPathPointsApplierFunc (void *info, const CGPathElement *element)
{
    NSMutableArray *bezierPoints = (NSMutableArray *)CFBridgingRelease(info);
    CGPoint *points = element->points;
    CGPathElementType type = element->type;
    
    
    NSMutableDictionary *elementDictionary = [NSMutableDictionary new];
    elementDictionary[kCCBezierPathBuilderPointsKey] = (NSArray *)CFBridgingRelease(points);
    elementDictionary[kCCBezierPathBuilderTypeKey] = @(type);
    [bezierPoints addObject:elementDictionary];
}




