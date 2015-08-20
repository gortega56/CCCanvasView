//
//  CCTileScrollView.m
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/8/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCTiledImageScrollView.h"
#import "CCTiledView.h"

#define DEBUG_TILE 0

@interface CCTiledImageScrollView () <UIScrollViewDelegate, CCTiledViewDelegate>
{
    CGPoint _pointToCenterAfterResize;
    CGFloat _scaleToRestoreAfterResize; // Used for rotation support
}

@property (nonatomic, strong) UIImageView *zoomView;
@property (nonatomic, strong, readwrite) CCTiledView *tiledView;

@end

@implementation CCTiledImageScrollView

#pragma mark - UIView Methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.bouncesZoom = YES;
        self.delegate = self;
        self.numberOfMagnifiedZoomLevels = 0;
        self.numberOfZoomLevels = 2;
        self.tileSize = CGSizeMake(256.f, 256.f);
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame
{
    BOOL isResize = !CGSizeEqualToSize(frame.size, self.frame.size);
    if (isResize) {
        [self willResizeFrame];
    }
    
    [super setFrame:frame];
    
    if (isResize) {
        [self didResizeFrame];
    }
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

#pragma mark - UIScrollView Methods

- (void)setDelegate:(id<UIScrollViewDelegate>)delegate
{
    [super setDelegate:self];
}

#pragma mark - Tile/Zoom Methods

- (void)setFullImageSize:(CGSize)fullImageSize
{
    self.contentSize = fullImageSize;
    _fullImageSize = fullImageSize;
    [self initSubviewsWithContentSize:fullImageSize];
}

- (void)initSubviewsWithContentSize:(CGSize)contentSize
{
    // Clear previous image
    [_zoomView removeFromSuperview];
    _zoomView = nil;
    _tiledView = nil;
    
    // Reset zoom scale
    self.zoomScale = 1.f;
    
    // Set up new tiling image
    _zoomView = [[UIImageView alloc] initWithFrame:(CGRect){.size = contentSize}];
    _zoomView.userInteractionEnabled = YES;
    [self addSubview:_zoomView];
    
    _tiledView = [[CCTiledView alloc] initWithFrame:_zoomView.bounds];
    _tiledView.numberOfZoomLevels = self.numberOfZoomLevels;
    _tiledView.numberOfMagnifiedZoomLevels = self.numberOfMagnifiedZoomLevels;
    _tiledView.tileSize = self.tileSize;
    _tiledView.userInteractionEnabled = NO;
    _tiledView.delegate = self;
    [_zoomView addSubview:_tiledView];
    
    [self configureForContentSize:contentSize];
}

- (void)configureForContentSize:(CGSize)contentSize
{
    [self setZoomScalesForCurrentBoundsAndContentSize];
    self.zoomScale = self.minimumZoomScale;
}

- (void)setPlaceHolderImage:(UIImage *)image
{
    _zoomView.image = image;
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.tiledImageScrollViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.tiledImageScrollViewDelegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ([self.tiledImageScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [self.tiledImageScrollViewDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if ([self.tiledImageScrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [self.tiledImageScrollViewDelegate scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self.tiledImageScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.tiledImageScrollViewDelegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.tiledImageScrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.tiledImageScrollViewDelegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.tiledImageScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.tiledImageScrollViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ([self.tiledImageScrollViewDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.tiledImageScrollViewDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    if ([self.tiledImageScrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
        [self.tiledImageScrollViewDelegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if ([self.tiledImageScrollViewDelegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
        [self.tiledImageScrollViewDelegate scrollViewDidZoom:scrollView];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if ([self.tiledImageScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
        [self.tiledImageScrollViewDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

// This method does not get forwarded to tiledScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _zoomView;
}

#pragma mark - CCTileView DataSource

- (UIImage *)tileView:(CCTiledView *)tileView imageForRow:(NSInteger)row column:(NSInteger)column scale:(CGFloat)scale
{
    return [self.dataSource tiledImageScrollView:self imageForRow:row column:column atScale:scale];
}

#pragma mark - CCTileView Delegate

- (void)tiledView:(CCTiledView *)tiledView context:(CGContextRef)context drawRect:(CGRect)rect forRow:(NSInteger)row column:(NSInteger)column
{
    if (tiledView == _tiledView) {
        CGFloat scale = CGContextGetCTM(context).a;
        UIImage *tileImage = [self.dataSource tiledImageScrollView:self imageForRow:row column:column atScale:scale];
        if (tileImage) {
            [tileImage drawInRect:rect];
        }
        
        if (DEBUG_TILE) {
            [[UIColor redColor] setStroke];
            CGContextStrokeRect(context, rect);
        }
    }
}

// Copied from Apple Docs PhotoScroller Sample Code

#pragma mark - Rotation Support Methods

- (void)willResizeFrame
{
    // Get center of what area is being viewed and convert it to zoomView coordinate space
    CGPoint boundsCenter = (CGPoint){CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)};
    _pointToCenterAfterResize = [self convertPoint:boundsCenter toView:_zoomView];
    
    // Keep track of current zoom scale
    _scaleToRestoreAfterResize = self.zoomScale;
    
    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (_scaleToRestoreAfterResize <= self.minimumZoomScale + FLT_EPSILON)
       _scaleToRestoreAfterResize = 0;
}

- (void)didResizeFrame
{
    [self setZoomScalesForCurrentBoundsAndContentSize];
    
    // Restore zoom scale to a value with zoom scale range
    CGFloat maxZoomScale = MAX(self.minimumZoomScale, _scaleToRestoreAfterResize);
    self.zoomScale = MIN(self.maximumZoomScale, maxZoomScale);
    self.zoomScale = _scaleToRestoreAfterResize;
    
    // Restore center point within allowable range
    CGPoint boundsCenter = [self convertPoint:_pointToCenterAfterResize fromView:_zoomView];
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                                 boundsCenter.y - self.bounds.size.height / 2.0);

    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    
    CGFloat realMaxOffset = MIN(maxOffset.x, offset.x);
    offset.x = MAX(minOffset.x, realMaxOffset);
    
    realMaxOffset = MIN(maxOffset.y, offset.y);
    offset.y = MAX(minOffset.y, realMaxOffset);
    
    self.contentOffset = offset;
}

- (void)setZoomScalesForCurrentBoundsAndContentSize
{
    CGSize boundsSize = self.bounds.size;
    CGFloat scaleWidth = CGRectGetWidth(self.frame) / _fullImageSize.width;
    CGFloat scaleHeight = CGRectGetHeight(self.frame) / _fullImageSize.height;
    
    // fill width if the image and phone are both portrait or both landscape; otherwise take smaller scale
    BOOL imagePortrait = _fullImageSize.height > _fullImageSize.width;
    BOOL phonePortrait = boundsSize.height > boundsSize.width;
    CGFloat minScale = imagePortrait == phonePortrait ? scaleWidth : MIN(scaleWidth, scaleHeight);
    
    CGFloat maxScale = (1 + self.numberOfMagnifiedZoomLevels) ;
    
    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
    if (minScale > maxScale) {
        minScale = maxScale;
    }
    
    self.minimumZoomScale = minScale;
    self.maximumZoomScale = maxScale;
}

- (CGPoint)maximumContentOffset
{
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset
{
    return CGPointZero;
}

@end
