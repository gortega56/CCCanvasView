//
//  CCMark.m
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/13/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCAnnotationView.h"
#import "UIBezierPath+CCAdditions.h"

#pragma mark - CCAnnotation

@interface CCAnnotationView ()

@end

@implementation CCAnnotationView

#pragma mark - UIView Methods

+ (instancetype)annotationViewWithStrokes:(NSArray *)strokes
{
    return [[[self class] alloc] initWithStrokes:strokes];
}

- (id)initWithStrokes:(NSArray *)strokes
{
    NSArray *points = [self pointsForStrokes:strokes];
    self = [super initWithFrame:CGRectForPoints(points)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.strokeColor = [UIColor openStatusColor];
        self.fillColor = [UIColor clearColor];
        self.lineJoinStyle = kCGLineJoinRound;
        self.lineCapStyle = kCGLineCapRound;
        _annotationPosition = self.center;
        _strokes = strokes;
        
//        self.layer.borderColor = [UIColor blueColor].CGColor;
//        self.layer.borderWidth = 2.f;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithStrokes:nil];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (self.layer.contents) { // Scale image down for pop animation
        self.transform = CGAffineTransformMakeScale(0, 0);
    }
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    if (self.layer.contents) { // Pop Animation
        [UIView animateWithDuration:0.1 animations:^{
            self.transform = CGAffineTransformMakeScale(1.5, 1.5);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15 animations:^{
                self.transform = CGAffineTransformMakeScale(1, 1);
            }];
        }];
    }
    else { // Draw path
        self.path = self.boundedPath;
    }
}

#pragma mark - CGAffineTransform Methods

- (void)applyTransformWithScale:(CGFloat)scale
{
    if (self.layer.contents) { // Keep image the same size
        self.transform = CGAffineTransformIdentity;
    }
    else {
        self.transform = CGAffineTransformMakeScale(scale, scale);
    }
}

- (void)updatePositionWithScale:(CGFloat)scale
{
    CGPoint annotationPosition = self.center;
    annotationPosition.x = annotationPosition.x * scale;
    annotationPosition.y = annotationPosition.y * scale;
    self.annotationPosition = annotationPosition;
}

- (void)updateCenterWithScale:(CGFloat)scale
{
    CGPoint annotationPosition = self.annotationPosition;
    annotationPosition.x = annotationPosition.x * scale;
    annotationPosition.y = annotationPosition.y * scale;
    self.center = annotationPosition;
}


#pragma mark -  CCStroke Methods

- (NSArray *)convertStrokes:(NSArray *)strokes fromView:(UIView *)view
{
    NSMutableArray *convertedStrokes = [NSMutableArray new];
    for (CCStroke *stroke in strokes) {
        [convertedStrokes addObject:[self convertStroke:stroke fromView:view]];
    }
    
    return convertedStrokes;
}

- (CCStroke *)convertStroke:(CCStroke *)stroke fromView:(UIView *)view
{
    NSMutableArray *convertedPoints = [NSMutableArray new];
    for (NSValue *value in stroke.points) {
        CGPoint convertedPoint = [self convertPoint:value.CGPointValue fromView:view];
        [convertedPoints addObject:[NSValue valueWithCGPoint:convertedPoint]];
    }
    
    return [[CCStroke alloc] initWithType:stroke.type points:convertedPoints];
}

- (NSArray *)convertedPointsForStrokes:(NSArray *)strokes
{
    NSMutableArray *convertedPoints = [NSMutableArray new];
    NSArray *points = [self pointsForStrokes:_strokes];
    for (NSValue *value in points) {
        CGPoint convertedPoint = [self convertPoint:value.CGPointValue fromView:self.superview];
        [convertedPoints addObject:[NSValue valueWithCGPoint:convertedPoint]];
    }
    return convertedPoints;
}

- (NSArray *)pointsForStrokes:(NSArray *)strokes
{
    NSMutableArray *points = [NSMutableArray new];
    for (CCStroke *stroke in strokes) {
        [points addObjectsFromArray:stroke.points];
    }
    return points;
}

// Use for hit testing
- (UIBezierPath *)closedPathForStrokes:(NSArray *)strokes convertedFromView:(UIView *)view
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineJoinStyle = self.lineJoinStyle;
    path.lineCapStyle = self.lineCapStyle;
    path.lineWidth = self.lineWidth;
    path.usesEvenOddFillRule = YES;
    
    NSArray *convertedStrokes = [self convertStrokes:strokes fromView:view];
    CGPoint previousStrokeEndPoint = CGPointZero;
    for (CCStroke *stroke in convertedStrokes) {
        for (NSValue *value in stroke.points) {
            if ((path.isEmpty || (!CGPointEqualToPoint(previousStrokeEndPoint, stroke.startPoint) && !CGPointEqualToPoint(CGPointZero, previousStrokeEndPoint)))) {
                [path moveToPoint:[value CGPointValue]];
            }
            else {
                [path addLineToPoint:[value CGPointValue]];
            }
        }
        previousStrokeEndPoint = stroke.endPoint;
    }
    
    return path;
}

- (UIBezierPath *)pathForStrokes:(NSArray *)strokes convertedFromView:(UIView *)view
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineJoinStyle = self.lineJoinStyle;
    path.lineCapStyle = self.lineCapStyle;
    path.lineWidth = self.lineWidth;

    NSArray *convertedStrokes = [self convertStrokes:strokes fromView:view];
    for (CCStroke *stroke in convertedStrokes) {
        [path appendPath:stroke.path];
    }
    
    return path;
}

#pragma mark - Accessor Methods

- (UIBezierPath *)boundedPathClosed
{
    return [self closedPathForStrokes:_strokes convertedFromView:self.superview];
}

- (UIBezierPath *)boundedPath
{
    return [self pathForStrokes:_strokes convertedFromView:self.superview];
}

- (NSArray *)boundedStrokes
{
     return [self convertStrokes:_strokes fromView:self.superview];
}

- (CGPoint)startPoint
{
    return [(CCStroke *)_strokes.firstObject startPoint];
}

- (CGPoint)endPoint
{
    return [(CCStroke *)_strokes.lastObject endPoint];
}

#pragma mark - Mutator

- (void)setAnnotationImage:(UIImage *)annotationImage
{
    self.layer.contents = (id)annotationImage.CGImage;
}

@end

