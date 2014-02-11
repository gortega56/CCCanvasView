//
//  CCMarkupController.h
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/10/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCMarkupViewController : UIViewController

@property (nonatomic) BOOL shouldReceiveTouch;
@property (nonatomic, weak) UIView *inputView;
@property (nonatomic, strong, readonly) NSMutableArray *bezierPaths;
@property (nonatomic, strong, readonly) NSMutableArray *touchPoints;


@end

@class CCBezierPathBuilder;

@protocol CCBezierPathBuilderDelegate <NSObject>

@optional
- (void)bezierPathBuilder:(CCBezierPathBuilder *)bezierPathBuilder didFinalizeCurrentPath:(UIBezierPath *)currentPath;

@end

@interface CCBezierPathBuilder : NSObject

@property (nonatomic, strong) UIBezierPath *currentPath;

@property (nonatomic, weak) id<CCBezierPathBuilderDelegate> delegate;

- (void)beginPathAtPoint:(CGPoint)point;
- (void)modifyCurrentPathWithPoint:(CGPoint)point;
- (void)finalizeCurrentPathWithPoint:(CGPoint)point;


@end