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

- (void)dealloc
{
    [self removeAnnotationViews:_annotations];
    _annotations = nil;
    
    // UIWebView is notorious for leaking memory... Here are some tricks to get it to release
    // http://www.codercowboy.com/code-uiwebview-memory-leak-prevention/
    [self loadHTMLString:@"" baseURL:nil];
    [self stopLoading];
    self.delegate = nil;
    [self removeFromSuperview];
}

#pragma mark - Accessor Methods

- (CGFloat)webViewZoomScale
{
    return self.scrollView.zoomScale/self.scrollView.minimumZoomScale;
}

- (CGSize)webViewContentSize
{
    return CGSizeMake(self.scrollView.contentSize.width/self.webViewZoomScale, self.scrollView.contentSize.height/self.webViewZoomScale);
}

#pragma mark - Mutator Methods

- (void)addAnnotationViews:(NSArray *)annotationViews
{
    for (CCAnnotationView *annotationView in annotationViews) {
        [self addAnnotationLayer:annotationView];
    }
}

- (void)addAnnotationLayer:(CCAnnotationView *)annotationLayer
{
    CGFloat scale = self.webViewZoomScale;
    annotationLayer.lineWidth = annotationLayer.constantLineWidth/scale;
    [annotationLayer updateCenterWithScale:scale];
    [annotationLayer applyTransformWithScale:scale];
    [_annotations addObject:annotationLayer];
    [self.scrollView addSubview:annotationLayer];
}

- (void)removeAnnotationViews:(NSArray *)annotationViews
{
    [annotationViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_annotations removeObjectsInArray:annotationViews];
}

- (void)removeAnnotation:(CCAnnotationView *)annotation
{
    if (!annotation) {
        return;
    }
    
    [self removeAnnotationViews:@[annotation]];
}

- (NSArray *)annotationsWithPredicate:(NSPredicate *)predicate
{
    return [_annotations filteredArrayUsingPredicate:predicate];
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

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    // NOTE: Base class does NOT respond to [id<UIScrollViewDelegate> scrollViewWillEndDragging:withVelocity:targetContentOffset:]
    if ([self.delegate respondsToSelector:_cmd]) {
        [(id<UIScrollViewDelegate>)self.delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
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
