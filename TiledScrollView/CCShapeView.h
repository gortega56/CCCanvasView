//
//  CCShapeView.h
//  CCCanvasSample
//
//  Created by Gabriel Ortega on 2/26/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCShapeView : UIView

@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, strong) UIColor *fillColor;

@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) CGLineCap lineCapStyle;
@property (nonatomic) CGLineJoin lineJoinStyle;

@end
