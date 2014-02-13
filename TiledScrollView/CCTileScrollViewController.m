//
//  CCTileScrollViewController.m
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/8/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCTileScrollViewController.h"
#import "CCTileScrollView.h"
#import "CCTileView.h"
#import "CCMarkupView.h"


@interface CCTileScrollViewController () <CCTileScrollViewDataSource, CCTileScrollViewDelegate, CCMarkupViewDelegate>

@property (nonatomic, strong) CCTileScrollView *tileScrollView;
@property (nonatomic, strong) CCMarkupView *markupView;


@property (nonatomic, strong) NSString *tilesPath;
@property (nonatomic) BOOL markupEnabled;

@property (nonatomic, strong) NSMutableArray *markupViews;
@property (nonatomic, strong) UIButton *toggleButton;
@end

@implementation CCTileScrollViewController

#pragma mark - UIViewController Methods

- (void)loadView
{
    UIView *containerView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    _tileScrollView = [[CCTileScrollView alloc] initWithFrame:containerView.bounds];
    _tileScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tileScrollView.fullImageSize = (CGSize){9444.0f, 6805.0f};
    _tileScrollView.dataSource = self;
    _tileScrollView.scrollDelegate = self;
    [containerView addSubview:_tileScrollView];
    
    _toggleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _toggleButton.frame = CGRectMake(CGRectGetMidX(containerView.frame) - 30, CGRectGetMaxY(containerView.frame) - 40, 60, 40);
    _toggleButton.layer.borderColor = [UIColor redColor].CGColor;
    _toggleButton.layer.borderWidth = 1.f;
    [_toggleButton addTarget:self action:@selector(toggleMarkup) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:_toggleButton];
    
    self.view = containerView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tilesPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"test_files/HalfAndMax"];
    _tileScrollView.placeHolderImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/downsample.png", self.tilesPath]];
    _markupViews = [NSMutableArray new];
    self.markupEnabled = NO;
}

#pragma mark - CCTileScrollView DataSource

- (UIImage *)tileScrollView:(CCTileScrollView *)tileScrollView imageForRow:(NSInteger)row column:(NSInteger)column scale:(CGFloat)scale
{
    NSString *path = [NSString stringWithFormat:@"%@/%i/%ld_%ld.png", self.tilesPath, (int)(scale * 1000), (long)row, (long)column];
    UIImage *tileImage = [UIImage imageWithContentsOfFile:path];
    return tileImage;
}

#pragma mark - CCTileScrollView ScrollDelegate

#pragma mark - Markup

- (void)setMarkupEnabled:(BOOL)markupEnabled
{
    _markupEnabled = markupEnabled;
    
    if (_markupEnabled == YES) {
        if (_markupView == nil) {
            _markupView = [[CCMarkupView alloc] initWithFrame:CGRectZero];
            _markupView.delegate = self;
            _markupView.layer.borderColor = [UIColor greenColor].CGColor;
            _markupView.layer.borderWidth = 5.0f;
        }
        _markupView.frame = CGRectIntersection(self.view.frame, _tileScrollView.zoomView.frame);
        [self.view insertSubview:_markupView belowSubview:_toggleButton];
    }
    else {
        [_markupView removeFromSuperview];
    }
    
    _markupView.userInteractionEnabled = _markupEnabled;
    _tileScrollView.scrollEnabled = !_markupEnabled;
}

- (void)toggleMarkup
{
    self.markupEnabled = !self.markupEnabled;
}

#pragma mark - CCMarkup Delegate
- (void)markView:(CCMarkupView *)markupView didTrackPoint:(CGPoint)point
{

}

- (void)markView:(CCMarkupView *)markupView didFinishTrackingPoints:(NSArray *)points
{
    NSMutableArray *viewPoints = [NSMutableArray new];
    for (NSValue *value in points) {
        CGPoint viewPoint = [_tileScrollView.zoomView convertPoint:[value CGPointValue] fromView:markupView];
        [viewPoints addObject:[NSValue valueWithCGPoint:viewPoint]];
    }
    
    UIBezierPath *viewPath = bezierPathForPoints(viewPoints);
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = [UIColor orangeColor].CGColor;
    shapeLayer.lineWidth = kCCMarkupViewLineWidth/_tileScrollView.zoomScale;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.path = viewPath.CGPath;
    [_tileScrollView.zoomView.layer addSublayer:shapeLayer];
}

@end
