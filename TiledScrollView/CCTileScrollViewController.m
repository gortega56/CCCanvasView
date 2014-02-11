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
#import "CCMarkupViewController.h"
#import "CCMarkupView.h"


@interface CCTileScrollViewController () <CCTileScrollViewDataSource, CCTileScrollViewDelegate, CCTileViewDrawingDelegate, CCMarkupViewDelegate>

@property (nonatomic, strong) CCTileScrollView *tileScrollView;
@property (nonatomic, strong) CCMarkupView *markupView;

@property (nonatomic, strong) CCMarkupViewController *markupController;

@property (nonatomic, strong) NSString *tilesPath;
@property (nonatomic) BOOL markupEnabled;
@end

@implementation CCTileScrollViewController

- (void)loadView
{
    UIView *containerView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    _tileScrollView = [[CCTileScrollView alloc] initWithFrame:containerView.bounds contentSize:(CGSize){9444.0f, 6805.0f}];
    _tileScrollView.dataSource = self;
    [containerView addSubview:_tileScrollView];
    
    _markupView = [[CCMarkupView alloc] initWithFrame:containerView.bounds];
    _markupView.delegate = self;
    _markupView.layer.borderColor = [UIColor greenColor].CGColor;
    _markupView.layer.borderWidth = 2.0f;
    [containerView addSubview:_markupView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(CGRectGetMidX(containerView.frame) - 30, CGRectGetMaxY(containerView.frame) - 40, 60, 40);
    button.layer.borderColor = [UIColor redColor].CGColor;
    button.layer.borderWidth = 1.f;
    [button addTarget:self action:@selector(toggleMarkup) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:button];
    
    self.view = containerView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tilesPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"test_files/HalfAndMax"];
    _tileScrollView.zoomingImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/downsample.png", self.tilesPath]];
    _markupEnabled = NO;

}

- (UIImage *)tileScrollView:(CCTileScrollView *)tileScrollView imageForRow:(NSInteger)row column:(NSInteger)column scale:(CGFloat)scale
{
    NSString *path = [NSString stringWithFormat:@"%@/%i/%ld_%ld.png", self.tilesPath, (int)(scale * 1000), (long)row, (long)column];
    NSLog(@"Tile Path: %@", path);
    UIImage *tileImage = [UIImage imageWithContentsOfFile:path];
    NSLog(@"IMAGE EXISTS %@", (tileImage != Nil) ? @"YES" : @"NO");
    return tileImage;
}

- (void)tileView:(CCTileView *)tileView drawTileRect:(CGRect)tileRect atRow:(NSInteger)row column:(NSInteger)column inBoundingRect:(CGRect)boundingRect context:(CGContextRef)context
{

}

- (void)setMarkupEnabled:(BOOL)markupEnabled
{
    _markupEnabled = markupEnabled;
    _markupView.userInteractionEnabled = _markupEnabled;
    _tileScrollView.zoomView.userInteractionEnabled = !_markupEnabled;
    _tileScrollView.scrollEnabled = !_markupEnabled;
}

- (void)toggleMarkup
{
    self.markupEnabled = !self.markupEnabled;
    NSLog(@"Mark up %@", (_markupView.userInteractionEnabled) ? @"ENABLED" : @"DISABLED");
    NSLog(@"Scrolling %@", (_tileScrollView.scrollEnabled) ?  @"ENABLED" : @"DISABLED");
}

@end
