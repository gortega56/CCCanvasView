//
//  CCWebViewController.m
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/18/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCWebViewController.h"
#import "CCCanvasView.h"
#import "CCAnnotationLayer.h"
#import "CCAnnotatableWebView.h"

CGFloat const kCCWebViewControllerDefaultAnnotationLineWidth = 10.f;


@interface CCWebViewController () <CCMarkupViewDelegate, UIScrollViewDelegate, UIWebViewDelegate>

@property (nonatomic, strong) CCAnnotatableWebView *webView;
@property (nonatomic, strong) CCCanvasView *markupView;

@property (nonatomic, strong) NSMutableArray *markLayers;

@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic) BOOL markupEnabled;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic) CGFloat minimumZoomScale;
@property (nonatomic) CGFloat maximumZoomScale;
@property (nonatomic) CGFloat zoomScale;

@end

@implementation CCWebViewController

- (void)loadView
{
    UIView *containerView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    _webView = [[CCAnnotatableWebView alloc] initWithFrame:containerView.bounds];
    _webView.annotationLineWidth = kCCWebViewControllerDefaultAnnotationLineWidth;
    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
    [containerView addSubview:_webView];
    
    _scrollView = _webView.scrollView;

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
    
    _markLayers = [NSMutableArray new];
}

- (void)webViewDidStartLoad:(CCAnnotatableWebView *)webView
{
    
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), NSStringFromCGSize(_webView.scrollView.contentSize));

}

- (void)webViewDidFinishLoad:(CCAnnotatableWebView *)webView
{
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), NSStringFromCGSize(_webView.scrollView.contentSize));
    NSLog(@"MIN SCALE %f", _webView.scrollView.minimumZoomScale);
    NSLog(@"ZOOM SCALE %f", _webView.scrollView.zoomScale);
    NSLog(@"MAX SCALE %f", _webView.scrollView.maximumZoomScale);

    self.minimumZoomScale = _webView.scrollView.minimumZoomScale;
    self.maximumZoomScale = _webView.scrollView.maximumZoomScale;
    self.zoomScale = _webView.scrollView.zoomScale;
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

#pragma mark - CCCanvasViewDelegate

- (void)canvasView:(CCCanvasView *)canvasView didFinishTrackingPoints:(NSArray *)points
{
    NSMutableArray *viewPoints = [NSMutableArray new];
    for (NSValue *value in points) {
        CGPoint viewPoint = [_webView.scrollView convertPoint:[value CGPointValue] fromView:canvasView];
        [viewPoints addObject:[NSValue valueWithCGPoint:viewPoint]];
    }

    CCStroke *stroke = [CCStroke strokeWithPoints:viewPoints];
    CCAnnotationLayer *annotation = [CCAnnotationLayer annotationViewWithStrokes:@[stroke]];
    [_webView addAnnotationLayer:annotation];
}

@end
