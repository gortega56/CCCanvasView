//
//  CCTileScrollView.m
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/7/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCTiledView.h"

static const CGFloat kCCTileScrollViewDefaultTileSize = 256.f;

@interface CCTiledView ()

@end

@implementation CCTiledView

#pragma mark - UIView Methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.tiledLayer.levelsOfDetail = 2;
    }
    return self;
}

- (void)setContentScaleFactor:(CGFloat)contentScaleFactor
{
    [super setContentScaleFactor:1.f];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat scale = CGContextGetCTM(context).a;
    CGSize tileSize =  self.tiledLayer.tileSize;
    tileSize.width /= scale;
    tileSize.height /= scale;
    
    NSInteger firstColumn = floorf(CGRectGetMinX(rect) / tileSize.width);
    NSInteger lastColumn = floorf((CGRectGetMaxX(rect) - 1) / tileSize.width);
    NSInteger firstRow = floorf(CGRectGetMinY(rect) / tileSize.height);
    NSInteger lastRow = floorf((CGRectGetMaxY(rect) - 1) / tileSize.height);
    
    
    for (NSInteger row = firstRow; row <= lastRow; row++) {
        for (NSInteger column = firstColumn; column <= lastColumn; column++) {
            CGRect tileRect = CGRectMake((tileSize.width * column), (tileSize.height * row), tileSize.width, tileSize.height);
            tileRect = CGRectIntersection(self.bounds, tileRect);
            [self.delegate tiledView:self context:context drawRect:tileRect forRow:row column:column];
        }
    }
}

#pragma mark - CATiledLayer

+ (Class)layerClass
{
    return [CATiledLayer class];
}

- (CATiledLayer *)tiledLayer
{
    return (CATiledLayer *)self.layer;
}

- (CGSize)tileSize
{
    return (CGSize){kCCTileScrollViewDefaultTileSize, kCCTileScrollViewDefaultTileSize};
}

- (size_t)numberOfZoomLevels
{
    return self.tiledLayer.levelsOfDetail;
}

- (void)setNumberOfZoomLevels:(size_t)levels
{
    self.tiledLayer.levelsOfDetail = levels;
}



@end
