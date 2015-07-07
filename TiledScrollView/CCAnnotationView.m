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

@property (nonatomic, readonly) CGFloat superviewScale;

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
    
    if (self.superview == nil) {
        return;
    }
    
    if (self.layer.contents) { // Pop Animation
        [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveLinear animations:^{
            self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        } completion:nil];
    }
    else { // Draw path
        self.path = self.boundedPath;
    }
}

#pragma mark - CGAffineTransform Methods

- (void)applyTransformWithScale:(CGFloat)scale
{
    if (!self.layer.contents) { // Don't transform pin image.
        self.transform = CGAffineTransformMakeScale(scale, scale);
    }
}

- (void)updatePositionWithScale:(CGFloat)scale
{
    // Should set the center of the view at the base zoom level
    // All other zoom calculations based on annotationPos
    CGPoint annotationPosition = self.center;
    annotationPosition.x = annotationPosition.x * scale;
    annotationPosition.y = annotationPosition.y * scale;
    self.annotationPosition = annotationPosition;
}

- (void)updateCenterWithScale:(CGFloat)scale
{
    // This will change the frame of the view relative to the superview's zoom scale
    CGPoint annotationPosition = self.annotationPosition;
    annotationPosition.x = annotationPosition.x * scale;
    annotationPosition.y = annotationPosition.y * scale;
    self.center = annotationPosition;
}


#pragma mark -  CCStroke Methods

- (NSArray *)convertStrokes:(NSArray *)strokes fromView:(UIView *)view withScale:(CGFloat)scale
{
    NSMutableArray *convertedStrokes = [NSMutableArray new];
    for (CCStroke *stroke in strokes) {
        [convertedStrokes addObject:[self convertStroke:stroke fromView:view withScale:scale]];
    }
    
    return convertedStrokes;
}

- (CCStroke *)convertStroke:(CCStroke *)stroke fromView:(UIView *)view withScale:(CGFloat)scale;
{
//    CGFloat scale = [(UIScrollView *)view zoomScale]/[(UIScrollView *)view minimumZoomScale];
    NSMutableArray *convertedPoints = [NSMutableArray new];
    for (NSValue *value in stroke.points) {
        CGPoint strokePoint = value.CGPointValue;
        CGPoint scaledPoint = CGPointMake(strokePoint.x * scale, strokePoint.y * scale);
        CGPoint convertedPoint = [self convertPoint:scaledPoint fromView:view];
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
- (UIBezierPath *)closedPathForStrokes:(NSArray *)strokes convertedFromView:(UIView *)view withScale:(CGFloat)scale
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineJoinStyle = self.lineJoinStyle;
    path.lineCapStyle = self.lineCapStyle;
    path.lineWidth = self.lineWidth;
    path.usesEvenOddFillRule = YES;
    
    NSArray *convertedStrokes = [self convertStrokes:strokes fromView:view withScale:scale];
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

- (UIBezierPath *)pathForStrokes:(NSArray *)strokes convertedFromView:(UIView *)view withScale:(CGFloat)scale
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineJoinStyle = self.lineJoinStyle;
    path.lineCapStyle = self.lineCapStyle;
    path.lineWidth = self.lineWidth;

    NSArray *convertedStrokes = [self convertStrokes:strokes fromView:view withScale:scale];
    for (CCStroke *stroke in convertedStrokes) {
        [path appendPath:stroke.path];
    }
    
    return path;
}

#pragma mark - Accessor Methods

- (CGFloat)superviewScale
{
    return (![self.superview isKindOfClass:[UIScrollView class]]) ? 1.f : [(UIScrollView *)self.superview zoomScale]/[(UIScrollView *)self.superview minimumZoomScale];
}

- (UIBezierPath *)boundedPathClosed
{
    return [self closedPathForStrokes:_strokes convertedFromView:self.superview withScale:self.superviewScale];
}

- (UIBezierPath *)boundedPath
{
    return [self pathForStrokes:_strokes convertedFromView:self.superview withScale:self.superviewScale];
}

- (NSArray *)boundedStrokes
{
     return [self convertStrokes:_strokes fromView:self.superview withScale:self.superviewScale];
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

