//
//  CCWebView.m
//  CCCanvasSample
//
//  Created by Gabriel Ortega on 2/20/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCAnnotatableWebView.h"
#import "CCAnnotationLayer.h"

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

- (void)addAnnotationLayer:(CCAnnotationLayer *)annotationLayer
{
    
    annotationLayer.lineWidth = self.annotationLineWidth/self.webViewZoomScale;
    annotationLayer.annotationPosition = [self positionForAnnotation:annotationLayer withScale:1/self.webViewZoomScale];
    annotationLayer.transform = CGAffineTransformMakeScale(self.webViewZoomScale, self.webViewZoomScale);
    [_annotations addObject:annotationLayer];
    [self.scrollView addSubview:annotationLayer];
}

- (CGPoint)positionForAnnotation:(CCAnnotationLayer *)annotation withScale:(CGFloat)scale
{
    CGPoint annotationPosition = annotation.center;
    annotationPosition.x = annotationPosition.x * scale;
    annotationPosition.y = annotationPosition.y * scale;
    return annotationPosition;
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [super scrollViewDidZoom:scrollView];
    if ([self.delegate respondsToSelector:_cmd]) {
        [(id<UIScrollViewDelegate>)self.delegate scrollViewDidZoom:scrollView];
    }

    CGFloat scale = scrollView.zoomScale/self.scrollView.minimumZoomScale;
    [_annotations enumerateObjectsUsingBlock:^(CCAnnotationLayer *annotationLayer, NSUInteger idx, BOOL *stop) {
        CGPoint annotationPosition = annotationLayer.annotationPosition;
        annotationPosition.x = annotationPosition.x * scale;
        annotationPosition.y = annotationPosition.y * scale;
        annotationLayer.center = annotationPosition;
        annotationLayer.transform = CGAffineTransformMakeScale(scale, scale);
        annotationLayer.lineWidth = self.annotationLineWidth/scale;
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
