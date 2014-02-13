//
//  CCTileScrollView.h
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/7/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import <UIKit/UIKit.h>


@class CCTileView;
@protocol CCTileViewDelegate <NSObject>
@required
- (void)tileView:(CCTileView *)tileView drawTileRect:(CGRect)tileRect atRow:(NSInteger)row column:(NSInteger)column inBoundingRect:(CGRect)boundingRect context:(CGContextRef)context;
@end

@interface CCTileView : UIView

@property (nonatomic, strong, readonly) CATiledLayer *tiledLayer;
@property (nonatomic, assign) size_t numberOfZoomLevels;
@property (nonatomic, readonly) CGSize tileSize;

@property (nonatomic, weak) id <CCTileViewDelegate> delegate;

@end
