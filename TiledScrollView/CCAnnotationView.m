//
//  CCMark.m
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/13/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCAnnotationView.h"
#import "CCStroke.h"
#import "UIBezierPath+CCAdditions.h"

static CGRect CGRectForPoints(NSArray *points)
{
    if (points.count == 0) {
        return CGRectZero;
    }
    
    CGPoint firstPoint = [points[0] CGPointValue];
    __block CGFloat minX = firstPoint.x;
    __block CGFloat minY = firstPoint.y;
    __block CGFloat maxX = firstPoint.x;
    __block CGFloat maxY = firstPoint.y;
    [points enumerateObjectsUsingBlock:^(NSValue *value, NSUInteger idx, BOOL *stop) {
        CGPoint point = [value CGPointValue];
        minX = MIN(minX, point.x);
        minY = MIN(minY, point.y);
        maxX = MAX(maxX, point.x);
        maxY = MAX(maxY, point.y);
    }];
    
    CGRect rect = CGRectMake(minX, minY, maxX - minX, maxY - minY);
    return rect;
}

#pragma mark - CCAnnotation

@interface CCAnnotationView ()

@property (nonatomic, strong) UIBezierPath *path;

@end

@implementation CCAnnotationView

- (void)applyTransformWithScale:(CGFloat)scale
{
    self.transform = CGAffineTransformMakeScale(scale, scale);
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
        self.strokeColor = [UIColor orangeColor];
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

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    self.path = self.annotationPath;
}

#pragma mark -

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
    
    return [CCStroke strokeWithPoints:convertedPoints];
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


- (UIBezierPath *)annotationPath
{
    UIBezierPath *annotationPath = [UIBezierPath bezierPath];
    annotationPath.lineJoinStyle = self.lineJoinStyle;
    annotationPath.lineCapStyle = self.lineCapStyle;
    annotationPath.lineWidth = self.lineWidth;
    NSArray *convertedStrokes = [self convertStrokes:_strokes fromView:self.superview];
    for (CCStroke *stroke in convertedStrokes) {
        [annotationPath appendPath:stroke.path];
    }
    
    return annotationPath;
}

@end

@interface CCAnnotationPinView ()

@property (nonatomic) CGRect startRect;
@property (nonatomic) CGRect endRect;

@end

@implementation CCAnnotationPinView

#pragma mark - Mutator

- (void)setAnnotationImage:(UIImage *)annotationImage
{
    self.layer.contents = (id)annotationImage.CGImage;
}

- (void)applyTransformWithScale:(CGFloat)scale
{
    self.transform = CGAffineTransformIdentity;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    self.transform = CGAffineTransformMakeScale(0, 0);
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    self.layer.strokeColor = [UIColor clearColor].CGColor;
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

@end

