//
//  CCGeometry.h
//  FieldLensIOS
//
//  Created by Gabriel Ortega on 3/19/14.
//  Copyright (c) 2014 FieldLens Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

CGRect CGRectForPoints(NSArray *points);

CGPoint CGMidpointForPoints(CGPoint point1, CGPoint point2);

CGFloat CGFloatDistanceBetweenPoints(CGPoint point1, CGPoint point2);

CGFloat CGFloatSlopeBetweenPoints(CGPoint point1, CGPoint point2);

CGFloat CGFloatYInterceptForPoints(CGPoint point1, CGPoint point2);

CGFloat CGFloatYInterceptForPointAndSlope(CGPoint point, CGFloat slope);

CGFloat CGFloatYCoordinateForLineEquation(CGFloat xCoordinate, CGFloat slope, CGFloat yIntercept);

CGPoint CGPointPerpendicularToPointsAtDistance(CGPoint point1, CGPoint point2, CGFloat distance, BOOL clockwise);

CGFloat CGFloatAngleOfLineBetweenTwoPoints(CGPoint point1, CGPoint point2);

CGPoint CGPointVectorForPoints(CGPoint point1, CGPoint point2);
CGPoint CGPointNormalVectorForCGPointVector(CGPoint vector);
CGPoint CGPointOnLineAtDistance(CGPoint linePoint1, CGPoint linePoint2, CGFloat distance);