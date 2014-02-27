//
//  CCStroke.m
//  CCCanvasSample
//
//  Created by Gabriel Ortega on 2/26/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCStroke.h"
#import "UIBezierPath+CCAdditions.h"

@interface CCStroke ()

@end

@implementation CCStroke

+ (instancetype)strokeWithPoints:(NSArray *)points
{
    return [[CCStroke alloc] initWithPoints:points];
}

- (id)initWithPoints:(NSArray *)points
{
    self = [super init];
    if (self) {
        _points = points;
    }
    
    return self;
}

- (id)init
{
    return [self initWithPoints:nil];
}

- (UIBezierPath *)path
{
    return [UIBezierPath curvePathForPoints:_points];
}

@end
