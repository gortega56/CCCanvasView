//
//  CCTileScrollView.m
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/8/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCTileScrollView.h"
#import "CCTileView.h"

@interface CCTileScrollView () <UIScrollViewDelegate, CCTileViewDataSource, CCTileViewDrawingDelegate>

@property (nonatomic, strong) UIImageView *zoomView;
@property (nonatomic, strong) CCTileView *tileView;
@property (nonatomic, strong) NSMutableArray *bezierPaths;

@end

@implementation CCTileScrollView

- (id)initWithFrame:(CGRect)frame contentSize:(CGSize)contentSize
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentSize = contentSize;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
        
        _zoomView = [[UIImageView alloc] initWithFrame:(CGRect){.size = contentSize}];
        _zoomView.userInteractionEnabled = YES;
        [self addSubview:_zoomView];
        
        _tileView = [[CCTileView alloc] initWithFrame:_zoomView.bounds];
        _tileView.userInteractionEnabled = NO;
        _tileView.drawingDelegate = self;
        [_zoomView addSubview:_tileView];
        
        CGSize contentSize = self.contentSize;
        CGSize boundsSize = self.bounds.size;
        CGFloat scaleWidth = CGRectGetWidth(self.frame) / contentSize.width;
        CGFloat scaleHeight = CGRectGetHeight(self.frame) / contentSize.height;
        
        // fill width if the image and phone are both portrait or both landscape; otherwise take smaller scale
        BOOL imagePortrait = contentSize.height > contentSize.width;
        BOOL phonePortrait = boundsSize.height > boundsSize.width;
        CGFloat minScale = imagePortrait == phonePortrait ? scaleWidth : MIN(scaleWidth, scaleHeight);
        
        // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
        // maximum zoom scale to 0.5.
        CGFloat maxScale = 1.0 / [[UIScreen mainScreen] scale];
        
        // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
        if (minScale > maxScale) {
            minScale = maxScale;
        }
            
        self.minimumZoomScale = minScale;
        self.maximumZoomScale = 1.0f;
        self.zoomScale = minScale;

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _zoomView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    _zoomView.frame = frameToCenter;
}


- (void)setZoomingImage:(UIImage *)image
{
    _zoomView.image = image;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame contentSize:CGSizeZero];
}

#pragma mark - UIScrollView Management

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _zoomView;
}

#pragma mark - CCTileViewDataSource

- (UIImage *)tileView:(CCTileView *)tileView imageForRow:(NSInteger)row column:(NSInteger)column scale:(CGFloat)scale
{
    return [self.dataSource tileScrollView:self imageForRow:row column:column scale:scale];
}

#pragma mark - CCTileViewDrawingDelegate

- (void)tileView:(CCTileView *)tileView drawTileRect:(CGRect)tileRect atRow:(NSInteger)row column:(NSInteger)column inBoundingRect:(CGRect)boundingRect context:(CGContextRef)context
{
    if (tileView == _tileView) {
        CGFloat scale = CGContextGetCTM(context).a;
        UIImage *tileImage = [self.dataSource tileScrollView:self imageForRow:row column:column scale:scale];
        if (tileImage) {
            [tileImage drawInRect:tileRect];
        }
    }
}

@end
