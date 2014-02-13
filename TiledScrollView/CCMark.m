//
//  CCMark.m
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/13/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCMark.h"

#pragma mark - CCMark

@interface CCMark ()

@end

@implementation CCMark

+ (instancetype)markWithStrokes:(NSArray *)strokes
{
    return [[CCMark alloc] initWithStrokes:strokes];
}

- (id)initWithStrokes:(NSArray *)strokes
{
    self = [super init];
    if (self) {
        _strokes = strokes;
    }
    
    return self;
}

- (id)init
{
    return [self initWithStrokes:nil];
}

@end

#pragma mark - CCStroke

@interface CCStroke ()

@end

@implementation CCStroke

- (instancetype)strokeWithPoints:(NSArray *)points
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

@end