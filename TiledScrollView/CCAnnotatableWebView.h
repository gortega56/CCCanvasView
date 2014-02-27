//
//  CCWebView.h
//  CCCanvasSample
//
//  Created by Gabriel Ortega on 2/20/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCAnnotationView;

@interface CCAnnotatableWebView : UIWebView

@property (nonatomic, strong) NSMutableArray *annotations;
@property (nonatomic) CGFloat annotationLineWidth;

- (void)addAnnotationLayer:(CCAnnotationView *)annotationLayer;

@end
