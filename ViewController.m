//
//  ViewController.m
//  CCPhotoBrowser
//
//  Created by admin on 16/4/5.
//  Copyright © 2016年 CuiXinKuan. All rights reserved.
//

#import "ViewController.h"
#import "CCPhotoBrowser.h"

@interface ViewController ()<CCPhotoBrowserDelegate>

@property (nonatomic, strong) NSArray *imageViewsArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createPhotoBrowser];
}

- (void)createPhotoBrowser
{
    NSMutableArray *temp = [NSMutableArray new];
    
    for (int i = 0; i < 1; i++) {
        UIImageView *imageView = [UIImageView new];
        imageView.backgroundColor = [UIColor purpleColor];
        imageView.frame = CGRectMake(0, 0, 188, 220);
        imageView.center = self.view.center;
        [self.view addSubview:imageView];
        imageView.userInteractionEnabled = YES;
        imageView.tag = i;
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"test%d.jpg",i]];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
        [imageView addGestureRecognizer:tap];
        [temp addObject:imageView];
    }
    self.imageViewsArray = [temp copy];
}

- (void)tapImageView:(UITapGestureRecognizer *)tap
{
    UIView * imageView = tap.view;
    CCPhotoBrowser * browser = [[CCPhotoBrowser alloc] init];
    browser.currentImageIndex = imageView.tag;
    browser.sourceImagesContainerView = self.view;
    browser.imageCount = self.imageViewsArray.count;
    browser.delelgate = self;
    [browser show];
}


#pragma mark - CCPhotoBrowserDelegate
- (NSURL *)photoBrowser:(CCPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index {
    return nil;
}

- (UIImage *)photoBrowser:(CCPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index {
    UIImage *image = [UIImage imageNamed:@"test0.jpg"];
    return image;
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
