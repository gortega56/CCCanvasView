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

+ (instancetype)straightStrokeWithPoints:(NSArray *)points
{
    return [[CCStroke alloc] initWithType:CCStrokeTypeStraight points:points];
}

+ (instancetype)curvedStrokeWithPoints:(NSArray *)points
{
    return [[CCStroke alloc] initWithType:CCStrokeTypeQuadCurve points:points];
}

+ (instancetype)rectagularStrokeWithPoints:(NSArray *)points
{
    return [[CCStroke alloc] initWithType:CCStrokeTypeRectangle points:points];
}

+ (instancetype)circularStrokeWithPoints:(NSArray *)points
{
    return [[CCStroke alloc] initWithType:CCStrokeTypeCircular points:points];
}

- (id)initWithType:(CCStrokeType)type points:(NSArray *)points
{
    self = [super init];
    if (self) {
        _type = type;
        _points = points;
    }
    
    return self;
}

- (id)init
{
    return [self initWithType:CCStrokeTypeQuadCurve points:nil];
}

- (UIBezierPath *)path
{
    switch (_type) {
        case CCStrokeTypeQuadCurve:
            return [UIBezierPath curvePathForPoints:_points];
        case CCStrokeTypeStraight:
            return [UIBezierPath straightPathForPoints:_points];
        case CCStrokeTypeRectangle:
            return [UIBezierPath rectanglePathForPoints:_points];
        case CCStrokeTypeCircular:
            return [UIBezierPath circularPathForPoints:_points];
        default:
            break;
    }
}

- (CGPoint)startPoint
{
    return [_points.firstObject CGPointValue];
}

- (CGPoint)endPoint
{
    return [_points.lastObject CGPointValue];
}

@end
