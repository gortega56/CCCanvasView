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
#import "CCCanvasView.h"
#import "CCAnnotationLayer.h"


@interface CCTileScrollViewController () <CCTileScrollViewDataSource, CCTileScrollViewDelegate, CCMarkupViewDelegate>

@property (nonatomic, strong) CCTileScrollView *tileScrollView;
@property (nonatomic, strong) CCCanvasView *markupView;


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

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
   // _markupView.frame = CGRectIntersection(self.view.frame, _tileScrollView.zoomView.frame);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    _markupView.frame = CGRectIntersection(self.view.frame, _tileScrollView.zoomView.frame);
    _toggleButton.frame = CGRectMake(CGRectGetMidX(self.view.bounds) - 30, CGRectGetMaxY(self.view.bounds) - 40, 60, 40);
}

#pragma mark - CCTileScrollView DataSource

- (UIImage *)tileScrollView:(CCTileScrollView *)tileScrollView imageForRow:(NSInteger)row column:(NSInteger)column scale:(CGFloat)scale
{
    NSString *path = [NSString stringWithFormat:@"%@/%i/%ld_%ld.png", self.tilesPath, (int)(scale * 1000), (long)row, (long)column];
    UIImage *tileImage = [UIImage imageWithContentsOfFile:path];
    return tileImage;
}

#pragma mark - CCTileScrollView ScrollDelegate

- (void)tileScrollViewDidZoom:(CCTileScrollView *)tileScrollView
{
    [self.markupViews setValue:@(tileScrollView.zoomScale) forKey:@"scale"];
    [self.markupViews makeObjectsPerformSelector:@selector(setNeedsDisplay)];
}

#pragma mark - Markup

- (void)setMarkupEnabled:(BOOL)markupEnabled
{
    _markupEnabled = markupEnabled;
    
    if (_markupEnabled == YES) {
        if (_markupView == nil) {
            _markupView = [[CCCanvasView alloc] initWithFrame:CGRectZero];
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
- (void)canvasView:(CCCanvasView *)canvasView didTrackPoint:(CGPoint)point
{

}

- (void)canvasView:(CCCanvasView *)canvasView didFinishTrackingPoints:(NSArray *)points
{
    NSMutableArray *viewPoints = [NSMutableArray new];
    for (NSValue *value in points) {
        CGPoint viewPoint = [_tileScrollView.zoomView convertPoint:[value CGPointValue] fromView:canvasView];
        [viewPoints addObject:[NSValue valueWithCGPoint:viewPoint]];
    }
    
//    CCStroke *stroke = [CCStroke strokeWithPoints:viewPoints];
//    CCAnnotationLayer *markLayer = [CCAnnotationLayer layer];
//    markLayer.strokes = @[stroke];
//    markLayer.fillColor = [UIColor clearColor].CGColor;
//    markLayer.strokeColor = [UIColor orangeColor].CGColor;
//    markLayer.lineCap = kCALineCapRound;
//    markLayer.lineJoin = kCALineJoinRound;
//    markLayer.lineWidth = kCCMarkupViewLineWidth/_tileScrollView.zoomScale;
//    markLayer.path = markLayer.strokePath.CGPath;
//    markLayer.scale = _tileScrollView.zoomScale;
//    [_markupViews addObject:markLayer];
//    [_tileScrollView.zoomView.layer addSublayer:markLayer];
}

- (void)canvasView:(CCCanvasView *)canvasView didFinishPath:(UIBezierPath *)path
{
//    CGFloat scale = (1.f/_tileScrollView.zoomScale);
//    
//    CCStroke *stroke = [CCStroke strokeWithPoints:];
//    CCMarkLayer *markLayer = [CCMarkLayer layer];
//    markLayer.strokes = @[stroke];
//    markLayer.fillColor = [UIColor clearColor].CGColor;
//    markLayer.strokeColor = [UIColor orangeColor].CGColor;
//    markLayer.lineCap = kCALineCapRound;
//    markLayer.lineJoin = kCALineJoinRound;
//    markLayer.scale = _tileScrollView.zoomScale;
//    markLayer.transform = CATransform3DMakeScale(scale, scale, 1);
//    [_markupViews addObject:markLayer];
//    [_tileScrollView.zoomView.layer addSublayer:markLayer];
//
//    
//    
//    CCMarkLayer *shapeLayer = [CCMarkLayer layer];
//    shapeLayer.strokeColor = [UIColor orangeColor].CGColor;
//    shapeLayer.lineWidth = kCCMarkupViewLineWidth;
//    shapeLayer.lineCap = kCALineCapRound;
//    shapeLayer.lineJoin = kCALineJoinRound;
//    shapeLayer.path = path.CGPath;
//    shapeLayer.transform = CATransform3DMakeScale(scale, scale, 1);
//    [_tileScrollView.zoomView.layer addSublayer:shapeLayer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSLog(@"FUCKKKK NO MEMORY");
}
@end
