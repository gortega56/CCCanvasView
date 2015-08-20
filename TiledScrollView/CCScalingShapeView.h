//
//  CCMark.h
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/13/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCShapeView.h"
#import "CCStroke.h"
#import "CCScalingWebView.h"

@interface CCScalingShapeView : CCShapeView<CCWebViewScaling>

@property (nonatomic, readonly) UIBezierPath *boundedPathClosed;
@property (nonatomic, readonly) UIBezierPath *boundedPath;
@property (nonatomic, readonly) NSArray *strokes;
@property (nonatomic, readonly) NSArray *boundedStrokes;
@property (nonatomic, readonly) CGPoint startPoint;
@property (nonatomic, readonly) CGPoint endPoint;
@property (nonatomic) CGPoint absoluteCenter;
@property (nonatomic) CGFloat absoluteLineWidth;

- (instancetype)initWithStrokes:(NSArray *)strokes;
- (void)setLayerImage:(UIImage *)image;

@end