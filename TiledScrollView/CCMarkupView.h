//
//  CCMarkupTileView.h
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/11/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CCMarkupViewDelegate <NSObject>

@end

@interface CCMarkupView : UIView

@property (nonatomic, weak) id<CCMarkupViewDelegate> delegate;

@end

