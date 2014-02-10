//
//  CCTileScrollView.h
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/8/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCTileScrollView;

@protocol CCTileScrollViewDataSource <NSObject>
@required
- (UIImage *)tileScrollView:(CCTileScrollView *)tileScrollView imageForRow:(NSInteger)row column:(NSInteger)column scale:(CGFloat)scale;
@end

@protocol CCTileScrollViewDelegate <NSObject>



@end

@interface CCTileScrollView : UIScrollView

@property (nonatomic, weak) id<CCTileScrollViewDataSource> dataSource;

@property (nonatomic, weak) UIImage *zoomingImage;

- (id)initWithFrame:(CGRect)frame contentSize:(CGSize)contentSize;

@end
