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
@optional
- (void)tileScrollViewDidEndDeceleration:(CCTileScrollView *)tileScrollView;
- (void)tileScrollViewDidEndDragging:(CCTileScrollView *)tileScrollView;
- (void)tileScrollViewDidEndScrollingAnimation:(CCTileScrollView *)tileScrollView;
- (void)tileScrollViewDidEndZooming:(CCTileScrollView *)tileScrollView withView:(UIView *)view atScale:(CGFloat)scale;
- (void)tileScrollViewDidScroll:(CCTileScrollView *)tileScrollView;
- (void)tileScrollViewDidZoom:(CCTileScrollView *)tileScrollView;
- (void)tileScrollViewWillBeginDeceleration:(CCTileScrollView *)tileScrollView;
- (void)tileScrollViewWillBeginDragging:(CCTileScrollView *)tileScrollView;
- (void)tileScrollViewWillBeginZooming:(CCTileScrollView *)tileScrollView withView:(UIView *)view;
- (void)tileScrollViewWillEndDragging:(CCTileScrollView *)tileScrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;
@end

@interface CCTileScrollView : UIScrollView

@property (nonatomic, weak) id<CCTileScrollViewDataSource> dataSource;
@property (nonatomic, weak) id<CCTileScrollViewDelegate> scrollDelegate;

@property (nonatomic) CGSize fullImageSize;
@property (nonatomic, weak) UIImage *placeHolderImage;
@property (nonatomic, strong, readonly) UIImageView *zoomView;

@end
