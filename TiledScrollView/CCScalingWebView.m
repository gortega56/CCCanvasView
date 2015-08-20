//
//  CCWebView.m
//  CCCanvasSample
//
//  Created by Gabriel Ortega on 2/20/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCScalingWebView.h"

@interface CCScalingWebView ()

@property (nonatomic, strong) NSMutableArray *scalingSubviews;

@end

@implementation CCScalingWebView

#pragma mark - UIView Methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _scalingSubviews = [NSMutableArray new];
    }
    
    return self;
}

- (void)dealloc
{
    [self removeScalingSubviews:_scalingSubviews];
    _scalingSubviews = nil;
    
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

- (void)addScalingSubviews:(NSArray *)subviews
{
    for (UIView<CCWebViewScaling> *annotationView in subviews) {
        if ([annotationView respondsToSelector:@selector(willMoveToScalingWebView:)]) {
            [annotationView willMoveToScalingWebView:self];
        }
        
        [self addScalingSubview:annotationView];
        
        if ([annotationView respondsToSelector:@selector(didMoveToScalingWebView:)]) {
            [annotationView didMoveToScalingWebView:self];
        }
    }
}

- (void)addScalingSubview:(UIView<CCWebViewScaling> *)subview
{
    [subview webView:self didScale:self.webViewZoomScale];
    [_scalingSubviews addObject:subview];
    [self.scrollView addSubview:subview];
}

- (void)removeScalingSubviews:(NSArray *)subviews
{
    [subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_scalingSubviews removeObjectsInArray:subviews];
}

- (void)removeScalingSubview:(UIView *)subview
{
    if (!subview) {
        return;
    }
    
    [self removeScalingSubviews:@[subview]];
}

- (NSArray *)subviewsWithPredicate:(NSPredicate *)predicate
{
    return [_scalingSubviews filteredArrayUsingPredicate:predicate];
}

- (void)consolidateAnnotationsInRange:(NSRange)range usingBlock:(UIView<CCWebViewScaling> *(^)(NSArray *))block
{
//    if (self.scalingSubviews.count == 0) {
//        return;
//    }
//    
//    NSMutableArray *strokes = [NSMutableArray new];
//    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
//    NSArray *subAnnotations = [self.scalingSubviews objectsAtIndexes:indexSet];
//    for (UIView *subAnnotation in subAnnotations) {
//      //  [strokes addObjectsFromArray:subAnnotation.strokes];
//        [self removeScalingSubview:subAnnotation];
//    }
//    
//    CCScalingShapeView *annotation = block(strokes);
//    [self addScalingSubview:annotation];
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [super scrollViewDidZoom:scrollView];
    if ([self.delegate respondsToSelector:_cmd]) {
        [(id<UIScrollViewDelegate>)self.delegate scrollViewDidZoom:scrollView];
    }

    CGFloat scale = self.webViewZoomScale;
    [_scalingSubviews enumerateObjectsUsingBlock:^(UIView<CCWebViewScaling> *annotationLayer, NSUInteger idx, BOOL *stop) {
        [annotationLayer webView:self didScale:scale];
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

@end
