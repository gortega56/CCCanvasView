//
//  CCMark.h
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/13/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCShapeView.h"
#import "CCStroke.h"

@interface CCAnnotationView : CCShapeView

@property (nonatomic, readonly) UIBezierPath *boundedPathClosed;
@property (nonatomic, readonly) UIBezierPath *boundedPath;
@property (nonatomic, readonly) NSArray *strokes;
@property (nonatomic, readonly) NSArray *boundedStrokes;
@property (nonatomic, readonly) CGPoint startPoint;
@property (nonatomic, readonly) CGPoint endPoint;
@property (nonatomic) CGPoint annotationPosition;
@property (nonatomic) CGFloat constantLineWidth;
@property (nonatomic, strong) UIImage *annotationImage;

+ (instancetype)annotationViewWithStrokes:(NSArray *)strokes;

- (void)applyTransformWithScale:(CGFloat)scale;
- (void)updatePositionWithScale:(CGFloat)scale;
- (void)updateCenterWithScale:(CGFloat)scale;

@end