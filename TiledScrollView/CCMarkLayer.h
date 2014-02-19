//
//  CCMark.h
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/13/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCMarkLayer : CAShapeLayer

@property (nonatomic, strong) NSArray *strokes;
@property (nonatomic, strong) UIBezierPath *strokePath;
@property (nonatomic) CGFloat scale;

@end

@interface CCStroke : NSObject

@property (nonatomic, readonly) NSArray *points;
@property (nonatomic, readonly) UIBezierPath *path;
@property (nonatomic, readonly) CGRect bounds;

+ (instancetype)strokeWithPoints:(NSArray *)points;

@end