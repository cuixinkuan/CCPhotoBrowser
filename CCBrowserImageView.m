//
//  CCBrowserImageView.m
//  CCPhotoBrowser
//
//  Created by admin on 16/4/5.
//  Copyright © 2016年 CuiXinKuan. All rights reserved.
//

#import "CCBrowserImageView.h"
#import "UIImageView+WebCache.h"
#import "CCPhotoBrowserConfig.h"


@implementation CCBrowserImageView

{
    __weak CCWaitingView * _waitingView;
    BOOL _didCheckSize;
    UIScrollView * _scroll;
    UIImageView * _scrollImageView;
    UIScrollView * _zoomingScrollView;
    UIImageView * _zoomingImageView;
    CGFloat _totalScale;
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        _totalScale = 1.0;
        
        // 捏合手势缩放图片
        UIPinchGestureRecognizer * pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoomImage:)];
        pinch.delegate = self;
        [self addGestureRecognizer:pinch];
    }
    return self;
}


- (BOOL)isScaled {
    return 1.0 != _totalScale;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _waitingView.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    CGSize imageSize = self.image.size;
    
    if (self.bounds.size.width * (imageSize.height / imageSize.width) > self.bounds.size.height ) {
        if (!_scroll) {
            UIScrollView * scroll = [[UIScrollView alloc] init];
            scroll.backgroundColor = [UIColor whiteColor];
            UIImageView * imageView = [[UIImageView alloc] init];
            imageView.image = self.image;
            _scrollImageView = imageView;
            [scroll addSubview:imageView];
            scroll.backgroundColor = CCPhotoBrowserBackgroundColor;
            _scroll = scroll;
            [self addSubview:scroll];
            if (_waitingView) {
                [self bringSubviewToFront:_waitingView];
            }
        }
        _scroll.frame = self.bounds;
        CGFloat imageViewH = self.bounds.size.width * (imageSize.height / imageSize.width);
        _scrollImageView.bounds = CGRectMake(0, 0, _scroll.frame.size.width, imageViewH);
        _scrollImageView.center = CGPointMake(_scroll.frame.size.width * 0.5, _scrollImageView.frame.size.height * 0.5);
        _scroll.contentSize = CGSizeMake(0, _scrollImageView.bounds.size.height);
    }else {
        if (_scroll) {
            // 防止旋转时适配的scrollView的影响
            [_scroll removeFromSuperview];
        }
    }
    
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    _waitingView.progress = progress;
    
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    CCWaitingView * waiting = [[CCWaitingView alloc] init];
    waiting.bounds = CGRectMake(0, 0, 100, 100);
    waiting.mode = CCWaitingViewProgressMode;
    _waitingView = waiting;
    [self addSubview:waiting];
    
    __weak CCBrowserImageView * imageViewWeak = self;
    [self sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        imageViewWeak.progress = (CGFloat)receivedSize / expectedSize;
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [imageViewWeak removeWaitingView];
        
        if (error) {
            UILabel * label = [[UILabel alloc] init];
            label.bounds = CGRectMake(0, 0, 160, 30);
            label.center = CGPointMake(imageViewWeak.bounds.size.width * 0.5, imageViewWeak.bounds.size.height * 0.5);
            label.text = @"图片加载失败";
            label.font = [UIFont systemFontOfSize:16];
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
            label.layer.cornerRadius = 5;
            label.clipsToBounds = YES;
            label.textAlignment = NSTextAlignmentCenter;
            [imageViewWeak addSubview:label];
        }else {
            _scrollImageView.image = image;
            [_scrollImageView setNeedsDisplay];
        }
    }];
    
}

- (void)removeWaitingView {
    [_waitingView removeFromSuperview];
}

// 捏合手势
- (void)zoomImage:(UIPinchGestureRecognizer *)recoginzer {
    [self prepareForImageViewScaling];
    CGFloat scale = recoginzer.scale;
    CGFloat temp = _totalScale + (scale - 1);
    [self setTotalScale:temp];
    recoginzer.scale = 1.0;
}

- (void)prepareForImageViewScaling {
    if (!_zoomingScrollView) {
        _zoomingScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _zoomingScrollView.backgroundColor = CCPhotoBrowserBackgroundColor;
        _zoomingScrollView.contentSize = self.bounds.size;
        UIImageView * zoomingImageView = [[UIImageView alloc] initWithImage:self.image];
        CGSize imageSize = zoomingImageView.image.size;
        CGFloat imageViewH = self.bounds.size.height;
        if (imageSize.width > 0 ) {
            imageViewH = self.bounds.size.width * (imageSize.height / imageSize.width);
        }
        zoomingImageView.bounds = CGRectMake(0, 0, self.bounds.size.width, imageViewH);
        zoomingImageView.center = _zoomingScrollView.center;
        zoomingImageView.contentMode = UIViewContentModeScaleAspectFit;
        _zoomingImageView = zoomingImageView;
        [_zoomingScrollView addSubview:zoomingImageView];
        [self addSubview:_zoomingScrollView];
    }
}

- (void)setTotalScale:(CGFloat)totalScale {
    // 最大缩放2倍，最小缩放0.5倍
    if ((_totalScale < 0.5 && totalScale < _totalScale) || (_totalScale > 2.0 && totalScale > _totalScale)) return;
    
    [self zoomWithScale:totalScale];
}

- (void)zoomWithScale:(CGFloat)scale {
    _totalScale = scale;
    _zoomingImageView.transform = CGAffineTransformMakeScale(scale, scale);
    if (scale > 1 ) {
        CGFloat contentW = _zoomingImageView.frame.size.width;
        CGFloat contentH = MAX(_zoomingImageView.frame.size.height, self.frame.size.height);
        _zoomingImageView.center = CGPointMake(contentW * 0.5, contentH * 0.5);
        _zoomingScrollView.contentSize = CGSizeMake(contentW, contentH);
        
        CGPoint offset = _zoomingScrollView.contentOffset;
        offset.x = (contentW - _zoomingScrollView.frame.size.width) * 0.5;
        _zoomingScrollView.contentOffset = offset;
        
    }else {
        _zoomingScrollView.contentSize = _zoomingScrollView.frame.size;
        _zoomingScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _zoomingImageView.center = _zoomingScrollView.center;
    }
  
}

- (void)doubleTapToZommWithScale:(CGFloat)scale {
    [self prepareForImageViewScaling];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self zoomWithScale:scale];
    } completion:^(BOOL finished) {
        if (scale == 1 ) {
            [self clear];
        }
    }];
}

- (void)clear {
    [_zoomingScrollView removeFromSuperview];
    _zoomingScrollView = nil;
    _zoomingImageView = nil;
}

- (void)eliminateScale {
    [self clear];
    _totalScale = 1.0;
}

- (void)scaleImage:(CGFloat)scale {
    [self prepareForImageViewScaling];
    [self setTotalScale:scale];
}



@end
