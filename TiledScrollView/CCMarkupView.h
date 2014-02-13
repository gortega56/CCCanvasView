//
//  CCMarkupTileView.h
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/11/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const kCCMarkupViewLineWidth;

@class CCMarkupView;
@protocol CCMarkupViewDelegate <NSObject>

@optional
- (void)markView:(CCMarkupView *)markupView didTrackPoint:(CGPoint)point;
- (void)markView:(CCMarkupView *)markupView didFinishTrackingPoints:(NSArray *)points;
- (void)markView:(CCMarkupView *)markupView didFinishPath:(UIBezierPath *)path;

@end

@interface CCMarkupView : UIView

@property (nonatomic) CGFloat strokeWidth;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, weak) id<CCMarkupViewDelegate> delegate;

@end

static CGPoint CGMidpointForPoints(CGPoint point1, CGPoint point2)
{
    return (CGPoint){(point1.x + point2.x) * 0.5f, (point1.y + point2.y) * 0.5f};
}

static UIBezierPath * bezierPathForPoints(NSArray *points)
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = kCCMarkupViewLineWidth;
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






