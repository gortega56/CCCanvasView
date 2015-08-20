//
//  CCTileScrollView.h
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/8/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCTiledImageScrollView;
@class CCTiledView;

@protocol CCTiledImageScrollViewDataSource <NSObject>
@required
- (UIImage *)tiledImageScrollView:(CCTiledImageScrollView *)tileScrollView imageForRow:(NSInteger)row column:(NSInteger)column atScale:(CGFloat)scale;
@end

@protocol CCTiledImageScrollViewDelegate <UIScrollViewDelegate>
@end

@interface CCTiledImageScrollView : UIScrollView

@property (nonatomic, weak) id<CCTiledImageScrollViewDataSource> dataSource;
@property (nonatomic, weak) id<CCTiledImageScrollViewDelegate> tiledImageScrollViewDelegate;

@property (nonatomic) CGSize fullImageSize;
@property (nonatomic, weak) UIImage *placeHolderImage;
@property (nonatomic, strong, readonly) UIImageView *zoomView;
@property (nonatomic, strong, readonly) CCTiledView *tiledView;

@property (nonatomic) size_t numberOfZoomLevels;
@property (nonatomic) size_t numberOfMagnifiedZoomLevels;
@property (nonatomic) CGSize tileSize;

@end
