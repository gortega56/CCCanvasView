//
//  CCWebView.h
//  CCCanvasSample
//
//  Created by Gabriel Ortega on 2/20/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCAnnotatableWebView;
@class CCAnnotationView;

@interface CCAnnotatableWebView : UIWebView

@property (nonatomic, readonly) NSMutableArray *annotations;
@property (nonatomic, readonly) CGFloat webViewZoomScale;
@property (nonatomic, strong) UIColor *annotationColor;
@property (nonatomic) CGFloat annotationLineWidth;

- (void)addAnnotationLayer:(CCAnnotationView *)annotationLayer;
- (void)consolidateAnnotationsInRange:(NSRange)range usingBlock:(CCAnnotationView *(^)(NSArray *subAnnotationStrokes))block;
- (void)removeLastAnnotation;
- (UIImage *)imageCaptureWithSize:(CGSize)size;
@end
