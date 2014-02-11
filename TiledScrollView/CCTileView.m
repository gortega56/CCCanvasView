//
//  CCTileScrollView.m
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/7/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCTileView.h"

static const CGFloat kCCTileScrollViewDefaultTileSize = 256.;

@interface CCTileView ()

@end

@implementation CCTileView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //CGSize scaledTileSize = CGSizeApplyAffineTransform(self.tileSize, CGAffineTransformMakeScale(self.contentScaleFactor, self.contentScaleFactor));
        self.backgroundColor = [UIColor clearColor];
        self.tiledLayer.levelsOfDetail = 2;
        //self.tiledLayer.drawsAsynchronously = YES;
    }
    return self;
}

- (void)setContentScaleFactor:(CGFloat)contentScaleFactor
{
    [super setContentScaleFactor:1.f];
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
    return self.tiledLayer.levelsOfDetailBias;
}

- (void)setNumberOfZoomLevels:(size_t)levels
{
    self.tiledLayer.levelsOfDetailBias = levels;
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
            [self.drawingDelegate tileView:self drawTileRect:tileRect atRow:row column:column inBoundingRect:rect context:context];
        }
    }
}

@end
