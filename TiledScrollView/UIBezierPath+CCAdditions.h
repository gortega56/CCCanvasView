//
//  UIBezierPath+CCAdditions.h
//  CCCanvasSample
//
//  Created by Gabriel Ortega on 2/26/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CCBezierPathType)
{
    CCBezierPathTypeCurve,
    CCBezierPathTypeStraight
};

static CGPoint CGMidpointForPoints(CGPoint point1, CGPoint point2);

@interface UIBezierPath (CCAdditions)

+ (UIBezierPath *)curvePathForPoints:(NSArray *)points;
+ (UIBezierPath *)straightPathForPoints:(NSArray *)points;

@end
