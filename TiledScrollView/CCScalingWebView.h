//
//  CCWebView.h
//  CCCanvasSample
//
//  Created by Gabriel Ortega on 2/20/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCScalingWebView;

@protocol CCWebViewScaling <NSObject>

@required
- (void)webView:(CCScalingWebView *)webView didScale:(CGFloat)scale;
- (BOOL)scalesWithWebView:(CCScalingWebView *)webView;

@optional
- (void)willMoveToScalingWebView:(CCScalingWebView *)webView;
- (void)didMoveToScalingWebView:(CCScalingWebView *)webView;

@end

@interface CCScalingWebView : UIWebView

@property (nonatomic, readonly) NSMutableArray *scalingSubviews;
@property (nonatomic, readonly) CGSize webViewContentSize;
@property (nonatomic, readonly) CGFloat webViewZoomScale;

- (void)addScalingSubviews:(NSArray *)subviews;
- (void)addScalingSubview:(UIView<CCWebViewScaling> *)subview;

- (void)removeScalingSubviews:(NSArray *)subviews;
- (void)removeScalingSubview:(UIView *)subview;

- (NSArray *)subviewsWithPredicate:(NSPredicate *)predicate;

@end
