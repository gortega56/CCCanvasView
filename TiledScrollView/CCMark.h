//
//  CCMark.h
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/13/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCMark : NSObject

@property (nonatomic, readonly) NSArray *strokes;

@end

@interface CCStroke : NSObject

@property (nonatomic, readonly) NSArray *points;
@property (nonatomic, readonly) UIBezierPath *path;
@property (nonatomic, readonly) CGRect bounds;

@end