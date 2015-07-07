//
//  CCShapeView.m
//  CCCanvasSample
//
//  Created by Gabriel Ortega on 2/26/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCShapeView.h"

@implementation CCShapeView

#pragma mark - CALayer

- (CAShapeLayer *)shapeLayer
{
    return (CAShapeLayer *)self.layer;
}

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

#pragma mark - Accessor Methods

- (UIColor *)strokeColor
{

    return [UIColor colorWithCGColor:self.shapeLayer.strokeColor];
}

- (UIColor *)fillColor
{
    return [UIColor colorWithCGColor:self.shapeLayer.fillColor];
}

- (CGFloat)lineWidth
{
    return self.shapeLayer.lineWidth;
}

- (CGLineJoin)lineJoinStyle
{
    if ([self.shapeLayer.lineJoin isEqualToString:kCALineJoinBevel]) {
        return kCGLineJoinBevel;
    }
    else if ([self.shapeLayer.lineJoin isEqualToString:kCALineJoinRound]) {
        return kCGLineJoinRound;
    }
    else  { // ([self.shapeLayer.lineJoin isEqualToString:kCALineJoinMiter])
        return kCGLineJoinMiter;
    }
}

- (CGLineCap)lineCapStyle
{
    if ([self.shapeLayer.lineCap isEqualToString:kCALineCapButt]) {
        return kCGLineCapButt;
    }
    else if ([self.shapeLayer.lineCap isEqualToString:kCALineCapRound]) {
        return kCGLineCapRound;
    }
    else  { // ([self.shapeLayer.lineCap isEqualToString:kCALineCapSquare])
        return kCGLineCapSquare;
    }
}

- (UIBezierPath *)path
{
    UIBezierPath *path = [UIBezierPath bezierPathWithCGPath:self.shapeLayer.path];
    path.lineCapStyle = self.lineCapStyle;
    path.lineJoinStyle = self.lineJoinStyle;
    path.lineWidth = self.lineWidth;
    return path;
}

#pragma mark - Mutator Methods

- (void)setStrokeColor:(UIColor *)strokeColor
{
    self.shapeLayer.strokeColor = strokeColor.CGColor;
}

- (void)setFillColor:(UIColor *)fillColor
{
    self.shapeLayer.fillColor = fillColor.CGColor;
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    self.shapeLayer.lineWidth = lineWidth;
}

- (void)setLineJoinStyle:(CGLineJoin)lineJoinStyle
{
    switch (lineJoinStyle) {
        case kCGLineJoinMiter:
            self.shapeLayer.lineJoin = kCALineJoinMiter;
            break;
        case kCGLineJoinRound:
            self.shapeLayer.lineJoin = kCALineJoinRound;
            break;
        case kCGLineJoinBevel:
            self.shapeLayer.lineJoin = kCALineJoinBevel;
            break;
    }
}

- (void)setLineCapStyle:(CGLineCap)lineCapStyle
{
    switch (lineCapStyle) {
        case kCGLineCapButt:
            self.shapeLayer.lineCap = kCALineCapButt;
            break;
        case kCGLineCapRound:
            self.shapeLayer.lineCap = kCALineCapRound;
            break;
        case kCGLineCapSquare:
            self.shapeLayer.lineCap = kCALineCapSquare;
            break;
    }
}

- (void)setPath:(UIBezierPath *)path
{
    self.lineCapStyle = path.lineCapStyle;
    self.lineJoinStyle = path.lineJoinStyle;
    self.shapeLayer.path = path.CGPath;
}


@end
