//
//  CCMarkupTileView.h
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/11/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const kCCCanvasViewDefaultLineWidth;

typedef NS_ENUM(NSInteger, CCCanvasViewTrackType)
{
    CCCanvasViewTrackTypePin,
    CCCanvasViewTrackTypeFreeHand,
    CCCanvasViewTrackTypeCircle,
    CCCanvasViewTrackTypeRectangle,
    CCCanvasViewTrackTypePolygon,
    CCCanvasViewTrackTypeUndefinedPolygon,
    CCCanvasViewTrackTypeDebug
};

@class CCCanvasView;
@protocol CCMarkupViewDelegate <NSObject>

@optional
- (void)canvasView:(CCCanvasView *)canvasView didTrackPoint:(CGPoint)point;
- (void)canvasView:(CCCanvasView *)canvasView didFinishTrackingPoints:(NSArray *)points;
- (void)canvasView:(CCCanvasView *)canvasView didFinishPath:(UIBezierPath *)path;

@end

@interface CCCanvasView : UIView

@property (nonatomic) CGFloat strokeWidth;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, weak) id<CCMarkupViewDelegate> delegate;
@property (nonatomic) CCCanvasViewTrackType trackType;

- (void)clearCurrentPathPoints;
- (void)addTrackedPoint:(CGPoint)point;
- (void)finishTrackingPoints;

@end








