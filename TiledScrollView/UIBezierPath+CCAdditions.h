//
//  UIBezierPath+CCAdditions.h
//  CCCanvasSample
//
//  Created by Gabriel Ortega on 2/26/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCGeometry.h"

@interface UIBezierPath (CCAdditions)

+ (UIBezierPath *)curvePathForPoints:(NSArray *)points;
+ (UIBezierPath *)straightPathForPoints:(NSArray *)points;
+ (UIBezierPath *)rectanglePathForPoints:(NSArray *)points;
+ (UIBezierPath *)circularPathForPoints:(NSArray *)points;
+ (UIBezierPath *)multiArcPathForPoints:(NSArray *)points
                            arcDiameter:(CGFloat)arcDiameter
                          referencePath:(UIBezierPath *)referencePath;
@end
