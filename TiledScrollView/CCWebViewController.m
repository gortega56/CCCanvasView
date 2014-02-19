//
//  CCWebViewController.m
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/18/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCWebViewController.h"
#import "CCCanvasView.h"
#import "CCMarkLayer.h"

@interface CCWebViewController () <CCMarkupViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) CCCanvasView *markupView;

@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic) BOOL markupEnabled;


@end

@implementation CCWebViewController

- (void)loadView
{
    UIView *containerView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    _webView = [[UIWebView alloc] initWithFrame:containerView.bounds];
    _webView.scalesPageToFit = YES;
    [containerView addSubview:_webView];
    
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

    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"doc" ofType:@"html" inDirectory:@"doc (1)"]];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
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
    
    _markupView.userInteractionEnabled = _markupEnabled;
    _webView.scrollView.scrollEnabled = !_markupEnabled;
}

- (void)toggleMarkup
{
    self.markupEnabled = !self.markupEnabled;
}

- (void)markView:(CCCanvasView *)markupView didFinishTrackingPoints:(NSArray *)points
{
    UIView *webBrowserView = _webView.scrollView.subviews[0];
    NSMutableArray *viewPoints = [NSMutableArray new];
    for (NSValue *value in points) {
        CGPoint viewPoint = [webBrowserView convertPoint:[value CGPointValue] fromView:markupView];
        [viewPoints addObject:[NSValue valueWithCGPoint:viewPoint]];
    }
    
    
    
    CCStroke *stroke = [CCStroke strokeWithPoints:viewPoints];
    CCMarkLayer *markLayer = [CCMarkLayer layer];
    markLayer.strokes = @[stroke];
    markLayer.fillColor = [UIColor clearColor].CGColor;
    markLayer.strokeColor = [UIColor orangeColor].CGColor;
    markLayer.lineCap = kCALineCapRound;
    markLayer.lineJoin = kCALineJoinRound;
    markLayer.lineWidth = kCCMarkupViewLineWidth/_webView.scrollView.zoomScale;
    markLayer.path = markLayer.strokePath.CGPath;
    markLayer.scale = _webView.scrollView.zoomScale;
 //   [_markupViews addObject:markLayer];
    [webBrowserView.layer addSublayer:markLayer];
}

@end
