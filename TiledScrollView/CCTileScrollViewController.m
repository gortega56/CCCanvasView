//
//  CCTileScrollViewController.m
//  TiledScrollView
//
//  Created by Gabriel Ortega on 2/8/14.
//  Copyright (c) 2014 Clique City. All rights reserved.
//

#import "CCTileScrollViewController.h"
#import "CCTileScrollView.h"
@interface CCTileScrollViewController () <CCTileScrollViewDataSource, CCTileScrollViewDelegate>

@property (nonatomic, strong) CCTileScrollView *tileScrollView;
@property (nonatomic, strong) NSString *tilesPath;

@end

@implementation CCTileScrollViewController

- (void)loadView
{
    UIView *containerView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    _tileScrollView = [[CCTileScrollView alloc] initWithFrame:containerView.bounds contentSize:(CGSize){9444.0f, 6805.0f}];
    _tileScrollView.dataSource = self;
    [containerView addSubview:_tileScrollView];
    
    self.view = containerView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tilesPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"test_files/HalfAndMax"];
    _tileScrollView.zoomingImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/downsample.png", self.tilesPath]];

}

- (UIImage *)tileScrollView:(CCTileScrollView *)tileScrollView imageForRow:(NSInteger)row column:(NSInteger)column scale:(CGFloat)scale
{
    NSString *path = [NSString stringWithFormat:@"%@/%i/%ld_%ld.png", self.tilesPath, (int)(scale * 1000), (long)row, (long)column];
    NSLog(@"Tile Path: %@", path);
    UIImage *tileImage = [UIImage imageWithContentsOfFile:path];
  //  NSLog(@"IMAGE EXISTS %@", (tileImage != Nil) ? @"YES" : @"NO");
    return tileImage;
}

@end
