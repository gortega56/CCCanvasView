//
//  CCWebViewController.m
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/18/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCWebViewController.h"
#import "CCCanvasView.h"
#import "CCStroke.h"
#import "CCScalingWebView.h"
#import "CCScalingShapeView.h"

CGFloat const kCCWebViewControllerDefaultAnnotationLineWidth = 10.f;


@interface CCWebViewController () <CCMarkupViewDelegate, UIScrollViewDelegate, UIWebViewDelegate>

@property (nonatomic, strong) CCScalingWebView *webView;
@property (nonatomic, strong) CCCanvasView *markupView;
@property (nonatomic, strong) NSMutableArray *canvasStrokes;

@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic) BOOL markupEnabled;

@end

@implementation CCWebViewController

- (void)loadView
{
    UIView *containerView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    _webView = [[CCScalingWebView alloc] initWithFrame:containerView.bounds];
    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
    [containerView addSubview:_webView];
    
    _toggleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _toggleButton.frame = CGRectMake(0.f, CGRectGetMaxY(containerView.frame) - 40, 60, 40);
    [_toggleButton setTitle:@"Mark Up" forState:UIControlStateNormal];
    [_toggleButton addTarget:self action:@selector(toggleMarkup) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:_toggleButton];
    
    
    
    self.view = containerView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"doc" ofType:@"html" inDirectory:@"doc (1)"]];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    _canvasStrokes = [NSMutableArray new];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"%@ %@", [self class], NSStringFromSelector(_cmd));
}

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
        _markupView.frame = CGRectIntersection(self.view.frame, _webView.scrollView.frame);
        [self.view insertSubview:_markupView belowSubview:_toggleButton];
    }
    else {
        [_markupView removeFromSuperview];
    }
    
    _markupView.trackType = CCCanvasViewTrackTypePin;
    _markupView.userInteractionEnabled = _markupEnabled;
    _webView.scrollView.scrollEnabled = !_markupEnabled;
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
        CGPoint viewPoint = [_webView.scrollView convertPoint:[value CGPointValue] fromView:canvasView];
        [viewPoints addObject:[NSValue valueWithCGPoint:viewPoint]];
    }
    [_canvasStrokes addObject:[CCStroke curvedStrokeWithPoints:viewPoints]];

    CCScalingShapeView *annotation = [self annotationForTrackType:canvasView.trackType];
    [self.webView addScalingSubview:annotation];
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

@end
