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
@property (nonatomic, readonly) CGSize webViewContentSize;
@property (nonatomic, readonly) CGFloat webViewZoomScale;

@property (nonatomic, strong) UIColor *annotationColor;
@property (nonatomic) CGFloat annotationLineWidth;

- (void)addAnnotationViews:(NSArray *)annotationViews;
- (void)addAnnotationLayer:(CCAnnotationView *)annotationLayer;
- (void)consolidateAnnotationsInRange:(NSRange)range usingBlock:(CCAnnotationView *(^)(NSArray *subAnnotationStrokes))block;

- (NSArray *)annotationsWithPredicate:(NSPredicate *)predicate;
- (void)removeAnnotationViews:(NSArray *)annotationViews;
- (void)removeAnnotation:(CCAnnotationView *)annotation;

- (UIImage *)imageCaptureWithSize:(CGSize)size;
@end
