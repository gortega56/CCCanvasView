//
//  CCWebView.m
//  CCCanvasSample
//
//  Created by Gabriel Ortega on 2/20/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCAnnotatableWebView.h"
#import "CCAnnotationView.h"

@interface CCAnnotatableWebView ()

@property (nonatomic, readonly) CGFloat webViewZoomScale;
@end

@implementation CCAnnotatableWebView

#pragma mark - UIView Methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _annotations = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark - Accessor Methods

- (CGFloat)webViewZoomScale
{
    return self.scrollView.zoomScale/self.scrollView.minimumZoomScale;
}

#pragma mark - Mutator Methods

- (void)addAnnotationView:(CCAnnotationView *)annotationView animated:(BOOL)animated
{
    annotationView.lineWidth = self.annotationLineWidth/self.webViewZoomScale;
    [annotationView updatePositionWithScale:(1.f/self.webViewZoomScale)];
    [annotationView applyTransformWithScale:self.webViewZoomScale];
    [_annotations addObject:annotationView];
    
    }

- (void)addAnnotationLayer:(CCAnnotationView *)annotationLayer
{
    annotationLayer.lineWidth = self.annotationLineWidth/self.webViewZoomScale;
    [annotationLayer updatePositionWithScale:(1.f/self.webViewZoomScale)];
    [annotationLayer applyTransformWithScale:self.webViewZoomScale];
    [_annotations addObject:annotationLayer];
    [self.scrollView addSubview:annotationLayer];
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [super scrollViewDidZoom:scrollView];
    if ([self.delegate respondsToSelector:_cmd]) {
        [(id<UIScrollViewDelegate>)self.delegate scrollViewDidZoom:scrollView];
    }

    CGFloat scale = scrollView.zoomScale/self.scrollView.minimumZoomScale;
    [_annotations enumerateObjectsUsingBlock:^(CCAnnotationView *annotationLayer, NSUInteger idx, BOOL *stop) {
        annotationLayer.lineWidth = self.annotationLineWidth/scale;
        [annotationLayer updateCenterWithScale:scale];
        [annotationLayer applyTransformWithScale:scale];
    }];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    [super scrollViewWillBeginZooming:scrollView withView:view];
    
    if ([self.delegate respondsToSelector:_cmd]) {
        [(id<UIScrollViewDelegate>)self.delegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [super scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    if ([self.delegate respondsToSelector:_cmd]) {
        [(id<UIScrollViewDelegate>)self.delegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

@end
