//
//  CCGeometry.m
//  FieldLensIOS
//
//  Created by Gabriel Ortega on 3/19/14.
//  Copyright (c) 2014 FieldLens Inc. All rights reserved.
//

#import "CCGeometry.h"
#import <math.h>

CGFloat const kCCGeometryPerpendicularityCheckDistance = 5.f;

CGRect CGRectForPoints(NSArray *points)
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

CGPoint CGMidpointForPoints(CGPoint point1, CGPoint point2)
{
    return (CGPoint){(point1.x + point2.x) * 0.5f, (point1.y + point2.y) * 0.5f};
}

CGFloat CGFloatDistanceBetweenPoints(CGPoint point1, CGPoint point2)
{
    CGFloat deltaX = point2.x - point1.x;
    CGFloat deltaY = point2.y - point1.y;
    return sqrtf(deltaX * deltaX + deltaY * deltaY);
}

CGFloat CGFloatSlopeBetweenPoints(CGPoint point1, CGPoint point2)
{
    CGFloat deltaX = point2.x - point1.x;
    CGFloat deltaY = point2.y - point1.y;
    return (point1.y == point2.y) ? 0.f : deltaY/deltaX;
}

CGFloat CGFloatYInterceptForPoints(CGPoint point1, CGPoint point2)
{
    return CGFloatYInterceptForPointAndSlope(point1, CGFloatSlopeBetweenPoints(point1, point2));
}

CGFloat CGFloatYInterceptForPointAndSlope(CGPoint point, CGFloat slope)
{
    return (point.y - slope * point.x == INFINITY) ? 0 : point.y - slope * point.x;
}

CGFloat CGFloatYCoordinateForLineEquation(CGFloat xCoordinate, CGFloat slope, CGFloat yIntercept)
{
    return (isnan(slope * xCoordinate + yIntercept)) ? 0.f : slope * xCoordinate + yIntercept;
}

CGPoint CGPointPerpendicularToPointsAtDistance(CGPoint point1, CGPoint point2, CGFloat distance, BOOL clockwise)
{
    // Get midpoint
    CGPoint midPoint = CGMidpointForPoints(point1, point2);
    
    // Get vector from midpoint to endpoint
    CGPoint vector = CGPointVectorForPoints(midPoint, point2);
    
    // Get perpendicular vector
    CGPoint perpendicularVector = (clockwise) ? CGPointMake(-vector.y, vector.x) : CGPointMake(vector.y, -vector.x); // Counterclockwise
    
    // Get point on perpendicular vector by adding the perpendicular vector to the midpoint
    CGPoint perpendicularPoint = CGPointMake(midPoint.x + perpendicularVector.x, midPoint.y + perpendicularVector.y);
    
    // Return a point on this line that is a shorter distance away from the original midpoint i.e 2?
    return CGPointOnLineAtDistance(midPoint, perpendicularPoint, -(CGFloatDistanceBetweenPoints(midPoint, perpendicularPoint)-distance));
}

CGFloat CGFloatAngleOfLineBetweenTwoPoints(CGPoint point1, CGPoint point2)
{
    CGFloat deltaX = point2.x - point1.x;
    CGFloat deltaY = point2.y - point1.y;
    return atan2f(deltaY, deltaX);
}

CGPoint CGPointVectorForPoints(CGPoint point1, CGPoint point2)
{
    return CGPointMake(point2.x - point1.x, point2.y - point1.y);
}

CGPoint CGPointNormalVectorForCGPointVector(CGPoint vector)
{
    CGFloat length = sqrtf((vector.x * vector.x) + (vector.y * vector.y));
    return CGPointMake(vector.x/length, vector.y/length);
}

// This method gives you Point C that is a distance away from Point B on Line AB
// Negative distance < length of Line AB gives you a Point C that lies between Point A and Point B
CGPoint CGPointOnLineAtDistance(CGPoint linePoint1, CGPoint linePoint2, CGFloat distance)
{
    CGPoint normalVector = CGPointNormalVectorForCGPointVector(CGPointVectorForPoints(linePoint1, linePoint2));
    return CGPointMake(linePoint2.x + (distance * normalVector.x), linePoint2.y + (distance * normalVector.y));
    
}