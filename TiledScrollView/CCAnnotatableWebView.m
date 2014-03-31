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

@property (nonatomic, strong) NSMutableArray *annotations;

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

- (void)addAnnotationLayer:(CCAnnotationView *)annotationLayer
{
    annotationLayer.lineWidth = annotationLayer.constantLineWidth/self.webViewZoomScale;
    [annotationLayer updatePositionWithScale:(1.f/self.webViewZoomScale)];
    [annotationLayer applyTransformWithScale:self.webViewZoomScale];
    [_annotations addObject:annotationLayer];
    [self.scrollView addSubview:annotationLayer];
}

- (void)removeAnnotation:(CCAnnotationView *)annotation
{
    [annotation removeFromSuperview];
    [_annotations removeObject:annotation];
}

- (void)removeLastAnnotation
{
    [self removeAnnotation:_annotations.lastObject];
}

- (void)consolidateAnnotationsInRange:(NSRange)range usingBlock:(CCAnnotationView *(^)(NSArray *subAnnotationStrokes))block
{
    if (self.annotations.count == 0) {
        return;
    }
    
    NSMutableArray *strokes = [NSMutableArray new];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
    NSArray *subAnnotations = [self.annotations objectsAtIndexes:indexSet];
    for (CCAnnotationView *subAnnotation in subAnnotations) {
        [strokes addObjectsFromArray:subAnnotation.strokes];
        [self removeAnnotation:subAnnotation];
    }
    
    CCAnnotationView *annotation = block(strokes);
    [self addAnnotationLayer:annotation];
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [super scrollViewDidZoom:scrollView];
    if ([self.delegate respondsToSelector:_cmd]) {
        [(id<UIScrollViewDelegate>)self.delegate scrollViewDidZoom:scrollView];
    }

    CGFloat scale = self.webViewZoomScale;
    [_annotations enumerateObjectsUsingBlock:^(CCAnnotationView *annotationLayer, NSUInteger idx, BOOL *stop) {
        annotationLayer.lineWidth = annotationLayer.constantLineWidth/scale;
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

#pragma mark - Image Capture

- (UIImage *)imageCaptureWithSize:(CGSize)size
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    }
    else {
        UIGraphicsBeginImageContext(size);
    }
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
