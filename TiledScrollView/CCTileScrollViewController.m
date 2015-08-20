//
//  CCTileScrollViewController.m
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/8/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCTileScrollViewController.h"
#import "CCTiledImageScrollView.h"
#import "CCTiledView.h"
#import "CCCanvasView.h"
#import "CCScalingWebView.h"
#import "CCScalingShapeView.h"

@interface CCTileScrollViewController () <CCTiledImageScrollViewDataSource, CCTiledImageScrollViewDelegate, CCMarkupViewDelegate>

@property (nonatomic, strong) CCTiledImageScrollView *tileScrollView;
@property (nonatomic, strong) CCCanvasView *markupView;
@property (nonatomic, strong) NSMutableArray *canvasStrokes;
@property (nonatomic, strong) NSMutableArray *annotations;

@property (nonatomic, strong) NSString *tilesPath;
@property (nonatomic) BOOL markupEnabled;

@property (nonatomic, strong) UIButton *toggleButton;
@end

@implementation CCTileScrollViewController

#pragma mark - UIViewController Methods

- (void)loadView
{
    UIView *containerView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    _tileScrollView = [[CCTiledImageScrollView alloc] initWithFrame:containerView.bounds];
    _tileScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tileScrollView.fullImageSize = (CGSize){9444.0f, 6805.0f};
    _tileScrollView.dataSource = self;
    _tileScrollView.tiledImageScrollViewDelegate = self;
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
    _canvasStrokes = [NSMutableArray new];
    _annotations = [NSMutableArray new];
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

- (UIImage *)tiledImageScrollView:(CCTiledImageScrollView *)tileScrollView imageForRow:(NSInteger)row column:(NSInteger)column atScale:(CGFloat)scale
{
    NSString *path = [NSString stringWithFormat:@"%@/%i/%ld_%ld.png", self.tilesPath, (int)(scale * 1000), (long)row, (long)column];
    UIImage *tileImage = [UIImage imageWithContentsOfFile:path];
    return tileImage;
}

#pragma mark - CCTileScrollView ScrollDelegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat scale = scrollView.zoomScale;
    for (CCScalingShapeView *annotation in self.annotations) {
        annotation.lineWidth = annotation.absoluteLineWidth/scale;
    }
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

#pragma mark - CCCanvasViewDelegate

- (void)canvasView:(CCCanvasView *)canvasView didFinishTrackingPoints:(NSArray *)points
{
    NSMutableArray *viewPoints = [NSMutableArray new];
    for (NSValue *value in points) {
        CGPoint viewPoint = [self.tileScrollView.zoomView convertPoint:[value CGPointValue] fromView:canvasView];
        [viewPoints addObject:[NSValue valueWithCGPoint:viewPoint]];
    }
    [_canvasStrokes addObject:[CCStroke curvedStrokeWithPoints:viewPoints]];
    
    CCScalingShapeView *annotation = [self annotationForTrackType:canvasView.trackType];
    annotation.layer.borderWidth = 1.0f;
    annotation.absoluteLineWidth = canvasView.strokeWidth;
    annotation.strokeColor = canvasView.strokeColor;
    annotation.lineWidth = annotation.absoluteLineWidth/self.tileScrollView.zoomScale;
    [_annotations addObject:annotation];
    [_tileScrollView.zoomView addSubview:annotation];
}

#pragma mark - Annotation Methods

- (CCScalingShapeView *)annotationForTrackType:(CCCanvasViewTrackType)trackType
{
    switch (trackType) {
        case CCCanvasViewTrackTypeFreeHand:
        {
            CCScalingShapeView *annotation = [[CCScalingShapeView alloc] initWithStrokes:_canvasStrokes.copy];
            [_canvasStrokes removeAllObjects];
            return annotation;
        }
        case CCCanvasViewTrackTypePolygon:
            break;
        case CCCanvasViewTrackTypeUndefinedPolygon:
            break;
        case CCCanvasViewTrackTypePin:
        {
            CCScalingShapeView *annotation = [[CCScalingShapeView alloc] initWithStrokes:_canvasStrokes.copy];
            [annotation setLayerImage:[UIImage imageNamed:@"bluePin"]];
            annotation.frame = CGRectInset(annotation.frame, -40, -40);
            [_canvasStrokes removeAllObjects];
            return annotation;
        }
        default:
            break;
    }
    
    return nil;
}

- (UIImage *)snapshotImageWithView:(CCTiledImageScrollView *)view
{
    // Try our best to approximate the best tile set zoom scale to use
    CGFloat tileScale;
    if (view.zoomScale >= 0.5) {
        tileScale = 2.0;
    }
    else if (view.zoomScale >= 0.25) {
        tileScale = 1.0;
    }
    else {
        tileScale = 0.5;
    }
    
    CGFloat translationX = -view.contentOffset.x;
    CGFloat translationY = -view.contentOffset.y;
    if (view.contentSize.width < CGRectGetWidth(view.bounds)) {
        CGFloat deltaX = (CGRectGetWidth(view.bounds) - view.contentSize.width) / 2.0;
        translationX += deltaX;
    }
    if (view.contentSize.height < CGRectGetHeight(view.bounds)) {
        CGFloat deltaY = (CGRectGetHeight(view.bounds) - view.contentSize.height) / 2.0;
        translationY += deltaY;
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGRectGetWidth(view.bounds) / view.zoomScale, CGRectGetHeight(view.bounds) / view.zoomScale), NO, tileScale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, translationX / view.zoomScale, translationY / view.zoomScale);
    
    [view.zoomView.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSLog(@"FUCKKKK NO MEMORY");
}
@end
