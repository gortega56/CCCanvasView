//
//  CCMarkupTileView.h
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/11/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCMarkupView;
@protocol CCMarkupViewDelegate <NSObject>

- (void)markView:(CCMarkupView *)markupView didFinishPath:(UIBezierPath *)path;
- (void)markView:(CCMarkupView *)markupView didFinishTrackingPoints:(NSArray *)points;

@end

@interface CCMarkupView : UIView

@property (nonatomic, weak) id<CCMarkupViewDelegate> delegate;

@end

