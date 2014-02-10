//
//  CCTileScrollView.h
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/7/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import <UIKit/UIKit.h>


@class CCTileView;

typedef void (^CCTileViewDrawingBlock) (CGContextRef context, CGRect rect);

@protocol CCTileViewDataSource <NSObject>

@required
- (UIImage *)tileView:(CCTileView *)tileView imageForRow:(NSInteger)row column:(NSInteger)column scale:(CGFloat)scale;

@end

@protocol CCTileViewDrawingDelegate <NSObject>

@required
- (void)tileView:(CCTileView *)tileView drawTileRect:(CGRect)tileRect atRow:(NSInteger)row column:(NSInteger)column inBoundingRect:(CGRect)boundingRect context:(CGContextRef)context;
@end

@interface CCTileView : UIView

@property (nonatomic, readonly) CGSize tileSize;
@property (nonatomic, assign) size_t numberOfZoomLevels;
@property (nonatomic, strong, readonly) CATiledLayer *tiledLayer;

@property (nonatomic, weak) id <CCTileViewDataSource> dataSource;
@property (nonatomic, weak) id <CCTileViewDrawingDelegate> drawingDelegate;

@property (nonatomic, copy) CCTileViewDrawingBlock drawingBlock;

@end
