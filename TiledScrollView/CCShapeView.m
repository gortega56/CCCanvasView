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
    return [UIColor colorWithCGColor:self.layer.strokeColor];
}

- (UIColor *)fillColor
{
    return [UIColor colorWithCGColor:self.layer.fillColor];
}

- (CGFloat)lineWidth
{
    return self.layer.lineWidth;
}

- (CGLineJoin)lineJoinStyle
{
    if ([self.layer.lineJoin isEqualToString:kCALineJoinBevel]) {
        return kCGLineJoinBevel;
    }
    else if ([self.layer.lineJoin isEqualToString:kCALineJoinRound]) {
        return kCGLineJoinRound;
    }
    else  { // ([self.layer.lineJoin isEqualToString:kCALineJoinMiter])
        return kCGLineJoinMiter;
    }
}

- (CGLineCap)lineCapStyle
{
    if ([self.layer.lineCap isEqualToString:kCALineCapButt]) {
        return kCGLineCapButt;
    }
    else if ([self.layer.lineCap isEqualToString:kCALineCapRound]) {
        return kCGLineCapRound;
    }
    else  { // ([self.layer.lineCap isEqualToString:kCALineCapSquare])
        return kCGLineCapSquare;
    }
}

- (UIBezierPath *)path
{
    UIBezierPath *path = [UIBezierPath bezierPathWithCGPath:self.layer.path];
    path.lineCapStyle = self.lineCapStyle;
    path.lineJoinStyle = self.lineJoinStyle;
    path.lineWidth = self.lineWidth;
    return path;
}

#pragma mark - Mutator Methods

- (void)setStrokeColor:(UIColor *)strokeColor
{
    self.layer.strokeColor = strokeColor.CGColor;
}

- (void)setFillColor:(UIColor *)fillColor
{
    self.layer.fillColor = fillColor.CGColor;
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    self.layer.lineWidth = lineWidth;
}

- (void)setLineJoinStyle:(CGLineJoin)lineJoinStyle
{
    switch (lineJoinStyle) {
        case kCGLineJoinMiter:
            self.layer.lineJoin = kCALineJoinMiter;
            break;
        case kCGLineJoinRound:
            self.layer.lineJoin = kCALineJoinRound;
            break;
        case kCGLineJoinBevel:
            self.layer.lineJoin = kCALineJoinBevel;
            break;
    }
}

- (void)setLineCapStyle:(CGLineCap)lineCapStyle
{
    switch (lineCapStyle) {
        case kCGLineCapButt:
            self.layer.lineCap = kCALineCapButt;
            break;
        case kCGLineCapRound:
            self.layer.lineCap = kCALineCapRound;
            break;
        case kCGLineCapSquare:
            self.layer.lineCap = kCALineCapSquare;
            break;
    }
}

- (void)setPath:(UIBezierPath *)path
{
    self.lineCapStyle = path.lineCapStyle;
    self.lineJoinStyle = path.lineJoinStyle;
    self.layer.path = path.CGPath;
}


@end
