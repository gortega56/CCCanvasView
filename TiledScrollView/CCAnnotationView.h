//
//  CCMark.h
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/13/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCShapeView.h"

@interface CCAnnotationLayer : CCShapeView

@property (nonatomic, strong) UIBezierPath *annotationPath;
@property (nonatomic, strong) NSArray *strokes;

@property (nonatomic) CGPoint annotationPosition;

+ (instancetype)annotationViewWithStrokes:(NSArray *)strokes;

- (void)applyTransformWithScale:(CGFloat)scale;
- (void)updatePositionWithScale:(CGFloat)scale;
- (void)updateCenterWithScale:(CGFloat)scale;

@end

@interface CCStroke : NSObject

@property (nonatomic, readonly) NSArray *points;
@property (nonatomic, readonly) UIBezierPath *path;
@property (nonatomic, readonly) CGRect bounds;

+ (instancetype)strokeWithPoints:(NSArray *)points;

@end