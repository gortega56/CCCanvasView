//
//  CCTileScrollView.h
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/7/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import <UIKit/UIKit.h>


@class CCTiledView;

@protocol CCTiledViewDelegate <NSObject>
@required
- (void)tiledView:(CCTiledView *)tiledView context:(CGContextRef)context drawRect:(CGRect)rect forRow:(NSInteger)row column:(NSInteger)column;
@end

@interface CCTiledView : UIView

@property (nonatomic, strong, readonly) CATiledLayer *tiledLayer;
@property (nonatomic, assign) size_t numberOfZoomLevels;
@property (nonatomic, readonly) CGSize tileSize;
@property (nonatomic, weak) id <CCTiledViewDelegate> delegate;

@end
