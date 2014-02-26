//
//  UIBezierPath+CCAdditions.m
//  CCCanvasSample
//
//  Created by Gabriel Ortega on 2/26/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "UIBezierPath+CCAdditions.h"

static CGPoint CGMidpointForPoints(CGPoint point1, CGPoint point2)
{
    return (CGPoint){(point1.x + point2.x) * 0.5f, (point1.y + point2.y) * 0.5f};
}

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


@end
