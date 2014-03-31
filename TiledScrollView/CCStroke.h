//
//  CCStroke.h
//  CCCanvasSample
//
//  Created by Gabriel Ortega on 2/26/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CCStrokeType)
{
    CCStrokeTypeQuadCurve,
    CCStrokeTypeStraight,
    CCStrokeTypeRectangle,
    CCStrokeTypeCircular
};

@interface CCStroke : NSObject

@property (nonatomic, readonly) NSArray *points;
@property (nonatomic, readonly) UIBezierPath *path;
@property (nonatomic, readonly) CGRect bounds;
@property (nonatomic, readonly) CCStrokeType type;
@property (nonatomic, readonly) CGPoint startPoint;
@property (nonatomic, readonly) CGPoint endPoint;

+ (instancetype)curvedStrokeWithPoints:(NSArray *)points;
+ (instancetype)straightStrokeWithPoints:(NSArray *)points;
+ (instancetype)rectagularStrokeWithPoints:(NSArray *)points;
+ (instancetype)circularStrokeWithPoints:(NSArray *)points;
- (id)initWithType:(CCStrokeType)type points:(NSArray *)points;

@end
