//
//  CCTileScrollView.m
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/8/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCTileScrollView.h"
#import "CCCanvasView.h"
#import "CCTileView.h"

@interface CCTileScrollView () <UIScrollViewDelegate, CCTileViewDelegate>
{
    CGPoint _pointToCenterAfterResize;
    CGFloat _scaleToRestoreAfterResize; // Used for rotation support
}

@property (nonatomic, strong) UIImageView *zoomView;
@property (nonatomic, strong) CCCanvasView *markupView;
@property (nonatomic, strong) CCTileView *imageTileView;

@end

@implementation CCTileScrollView

#pragma mark - UIView Methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.bouncesZoom = YES;
        self.delegate = self;
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


#pragma mark - Tile/Zoom Methods

- (void)setFullImageSize:(CGSize)fullImageSize
{
    self.contentSize = fullImageSize;
    _fullImageSize = fullImageSize;
    [self initTileImageViewWithContentSize:fullImageSize];
}

- (void)initTileImageViewWithContentSize:(CGSize)contentSize
{
    // Clear previous image
    [_zoomView removeFromSuperview];
    _zoomView = nil;
    _imageTileView = nil;
    
    // Reset zoom scale
    self.zoomScale = 1.f;
    
    // Set up new tiling image
    _zoomView = [[UIImageView alloc] initWithFrame:(CGRect){.size = contentSize}];
    _zoomView.userInteractionEnabled = YES;
    [self addSubview:_zoomView];
    
    _imageTileView = [[CCTileView alloc] initWithFrame:_zoomView.bounds];
    _imageTileView.userInteractionEnabled = NO;
    _imageTileView.delegate = self;
    [_zoomView addSubview:_imageTileView];
    
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

- (void)setZoomScalesForCurrentBoundsAndContentSize
{
    CGSize boundsSize = self.bounds.size;
    CGFloat scaleWidth = CGRectGetWidth(self.frame) / _fullImageSize.width;
    CGFloat scaleHeight = CGRectGetHeight(self.frame) / _fullImageSize.height;
    
    // fill width if the image and phone are both portrait or both landscape; otherwise take smaller scale
    BOOL imagePortrait = _fullImageSize.height > _fullImageSize.width;
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
    self.maximumZoomScale = maxScale;
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self.scrollDelegate respondsToSelector:@selector(tileScrollViewDidEndDeceleration:)]) {
        [self.scrollDelegate tileScrollViewDidEndDeceleration:self];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.scrollDelegate respondsToSelector:@selector(tileScrollViewDidEndDragging:)]) {
        [self.scrollDelegate tileScrollViewDidEndDragging:self];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ([self.scrollDelegate respondsToSelector:@selector(tileScrollViewDidEndScrollingAnimation:)]) {
        [self.scrollDelegate tileScrollViewDidEndScrollingAnimation:self];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if ([self.scrollDelegate respondsToSelector:@selector(tileScrollViewDidEndZooming:withView:atScale:)]) {
        [self.scrollDelegate tileScrollViewDidEndZooming:self withView:view atScale:scale];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.scrollDelegate respondsToSelector:@selector(tileScrollViewDidScroll:)]) {
        [self.scrollDelegate tileScrollViewDidScroll:self];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if ([self.scrollDelegate respondsToSelector:@selector(tileScrollViewDidZoom:)]) {
        [self.scrollDelegate tileScrollViewDidZoom:self];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if ([self.scrollDelegate respondsToSelector:@selector(tileScrollViewWillBeginDeceleration:)]) {
        [self.scrollDelegate tileScrollViewWillBeginDeceleration:self];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.scrollDelegate respondsToSelector:@selector(tileScrollViewWillBeginDragging:)]) {
        [self.scrollDelegate tileScrollViewWillBeginDragging:self];
    }
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    if ([self.scrollDelegate respondsToSelector:@selector(tileScrollViewWillBeginZooming:withView:)]) {
        [self.scrollDelegate tileScrollViewWillBeginZooming:self withView:view];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ([self.scrollDelegate respondsToSelector:@selector(tileScrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.scrollDelegate tileScrollViewWillEndDragging:self withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _zoomView;
}

#pragma mark - CCTileView DataSource

- (UIImage *)tileView:(CCTileView *)tileView imageForRow:(NSInteger)row column:(NSInteger)column scale:(CGFloat)scale
{
    return [self.dataSource tileScrollView:self imageForRow:row column:column scale:scale];
}

#pragma mark - CCTileView Delegate

- (void)tileView:(CCTileView *)tileView drawTileRect:(CGRect)tileRect atRow:(NSInteger)row column:(NSInteger)column inBoundingRect:(CGRect)boundingRect context:(CGContextRef)context
{
    if (tileView == _imageTileView) {
        CGFloat scale = CGContextGetCTM(context).a;
        UIImage *tileImage = [self.dataSource tileScrollView:self imageForRow:row column:column scale:scale];
        if (tileImage) {
            [tileImage drawInRect:tileRect];
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
