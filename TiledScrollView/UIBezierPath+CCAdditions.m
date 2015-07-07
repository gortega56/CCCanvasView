//
//  UIBezierPath+CCAdditions.m
//  CCCanvasSample
//
//  Created by Gabriel Ortega on 2/26/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "UIBezierPath+CCAdditions.h"

@implementation UIBezierPath (CCAdditions)

+ (UIBezierPath *)curvePathForPoints:(NSArray *)points
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    
    CGPoint currentPoint = [points.firstObject CGPointValue];
    CGPoint previousPoint1 = currentPoint;
    CGPoint previousPoint2;
    for (NSValue *value in points) {
        previousPoint2 = previousPoint1;
        previousPoint1 = currentPoint;
        currentPoint = [value CGPointValue];
        
        CGPoint midPoint1 = CGMidpointForPoints(previousPoint1, previousPoint2);
        CGPoint midPoint2 = CGMidpointForPoints(currentPoint, previousPoint1);
        
        [path moveToPoint:midPoint1];
        [path addQuadCurveToPoint:midPoint2 controlPoint:previousPoint1];
    }
    
    return path;
}

+ (UIBezierPath *)straightPathForPoints:(NSArray *)points
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    
    CGPoint anchorPoint = [points.firstObject CGPointValue];
    [path moveToPoint:anchorPoint];
    
    CGPoint endPoint = [points.lastObject CGPointValue];
    [path addLineToPoint:endPoint];
    
    return path;
}

+ (UIBezierPath *)rectanglePathForPoints:(NSArray *)points
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    
    CGPoint corner1 = [points.firstObject CGPointValue];
    CGPoint corner2 = [points.lastObject CGPointValue]; // corner 2 always opposite of corner 1
    CGPoint corner3 = CGPointMake(corner1.x, corner2.y);
    CGPoint corner4 = CGPointMake(corner2.x, corner1.y);
    
    [path moveToPoint:corner1];
    [path addLineToPoint:corner3];
    [path addLineToPoint:corner2];
    [path addLineToPoint:corner4];
    [path closePath];
    
    return path;
}

+ (UIBezierPath *)circularPathForPoints:(NSArray *)points
{
    CGPoint center = [points.firstObject CGPointValue];
    CGPoint tangentPoint = [points.lastObject CGPointValue];
    CGFloat radius = CGFloatDistanceBetweenPoints(center, tangentPoint);
    return [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
}

+ (UIBezierPath *)multiArcPathForPoints:(NSArray *)points arcDiameter:(CGFloat)arcDiameter referencePath:(UIBezierPath *)referencePath
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGPoint startPoint = [points.firstObject CGPointValue];
    CGPoint endPoint = [points.lastObject CGPointValue];
    CGFloat distance = CGFloatDistanceBetweenPoints(startPoint, endPoint);
    
    NSInteger segments = floorf(distance/arcDiameter);
    float remainer = fmodf(distance, arcDiameter);
    CGFloat adjustedDiameter = arcDiameter + (remainer/segments);
    
    
    CGPoint segmentStartPoint = startPoint;
    for (int i=1; i<segments; i++) {
        CGPoint segmentEndPoint = CGPointOnLineAtDistance(segmentStartPoint, endPoint, -(adjustedDiameter * (segments-i)));
        [path appendPath:[UIBezierPath quadCurvePathFromStartPoint:segmentStartPoint endPoint:segmentEndPoint outsideOfPath:referencePath]];
        segmentStartPoint = segmentEndPoint;
    }
    
    [path appendPath:[UIBezierPath quadCurvePathFromStartPoint:segmentStartPoint endPoint:endPoint outsideOfPath:referencePath]];
    
    return path;
}

+ (UIBezierPath *)quadCurvePathFromStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint outsideOfPath:(UIBezierPath *)path
{
    // Get perpendicular point
    CGFloat testDistance = 0.5f;
    CGPoint testPoint = CGPointPerpendicularToPointsAtDistance(startPoint, endPoint, testDistance, YES);
    
    // Test point against path
    CGFloat controlPointDistance = CGFloatDistanceBetweenPoints(startPoint, endPoint)/2;
    CGPoint controlPoint = ([path containsPoint:testPoint]) ? CGPointPerpendicularToPointsAtDistance(startPoint, endPoint, controlPointDistance, NO) : CGPointPerpendicularToPointsAtDistance(startPoint, endPoint, controlPointDistance, YES);
    
    // Add quad curve from point to point using perpendicular point as control
    UIBezierPath *quadCurvePath = [UIBezierPath bezierPath];
    [quadCurvePath moveToPoint:startPoint];
    [quadCurvePath addQuadCurveToPoint:endPoint controlPoint:controlPoint];
    return quadCurvePath;
}

@end
