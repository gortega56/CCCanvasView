//
//  CCMark.m
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/13/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCMarkLayer.h"
#import "CCCanvasView.h"

#pragma mark - CCMark

@interface CCMarkLayer ()

@end

@implementation CCMarkLayer

#pragma mark - CALayer Methods

- (id)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    if (self) {
        if ([layer isKindOfClass:[CCMarkLayer class]]) {
            CCMarkLayer *markLayer = (CCMarkLayer *)layer;
            self.strokes = markLayer.strokes;
            self.lineCap = markLayer.lineCap;
            self.lineJoin = markLayer.lineJoin;
            self.strokeColor = markLayer.strokeColor;
            self.fillColor = markLayer.fillColor;
            self.path = markLayer.path;
        }
    }
    
    return self;
}

- (void)display
{
    self.path = self.strokePath.CGPath;
    self.lineWidth = kCCMarkupViewLineWidth/_scale;
}

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:@"scale"]) {
        return YES;
    }
    
    return [super needsDisplayForKey:key];
}

- (UIBezierPath *)strokePath
{
    UIBezierPath *strokePath = [UIBezierPath bezierPath];
    for (CCStroke *stroke in _strokes) {
        [strokePath appendPath:stroke.path];
    }
    
    return strokePath;
}

@end

#pragma mark - CCStroke

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
    return curvedPathForPoints(_points);
}

@end