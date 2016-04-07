//
//  CCPhotoBrowser.m
//  CCPhotoBrowser
//
//  Created by admin on 16/4/6.
//  Copyright © 2016年 CuiXinKuan. All rights reserved.
//

#import "CCPhotoBrowser.h"
#import "UIImageView+WebCache.h"
#import "CCBrowserImageView.h"
#import "CCPhotoBrowserConfig.h"


@implementation CCPhotoBrowser

{
    UIScrollView * _scrollView;
    BOOL _hasShowedFirstView;
    UIButton * _saveButton;
    UILabel * _indexLabel;
    UIActivityIndicatorView * _indicatorView;
    BOOL _willDisappear;
}

- (void)dealloc {
    [[UIApplication sharedApplication].keyWindow removeObserver:self forKeyPath:@"frame"];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = CCPhotoBrowserBackgroundColor;
    }
    return self;
}


- (void)didMoveToSuperview {
    [self setupScrollView];
    [self setupToolbars];
}

- (void)setupScrollView {

    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:_scrollView];
    
    for (int i = 0 ; i < self.imageCount; i ++ ) {
        CCBrowserImageView * imageView = [[CCBrowserImageView alloc] init];
        imageView.tag = i;
        
        // 单击图片
        UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoClick:)];
        
        // 双击放大图片
        UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDoubleTaped:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
         // 如果双击确定失败才触发单击
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        [imageView addGestureRecognizer:singleTap];
        [imageView addGestureRecognizer:doubleTap];
        [_scrollView addSubview:imageView];
    }
    
    [self setupImageOfImageViewForIndex:self.currentImageIndex];
}

// 加载图片
- (void)setupImageOfImageViewForIndex:(NSInteger)index {
    CCBrowserImageView * imageView = _scrollView.subviews[index];
    self.currentImageIndex = index;
    if (imageView.hasLoadedImage) return;
    if ([self highQualityImageURLForIndex:index]) {
        [imageView setImageWithURL:[self highQualityImageURLForIndex:index] placeholderImage:[self placeholderImageForIndex:index]];
    }else {
        imageView.image = [self placeholderImageForIndex:index];
    }
    imageView.hasLoadedImage = YES;
}

// 单击图片
- (void)photoClick:(UITapGestureRecognizer *)recognizer {
    _scrollView.hidden = YES;
    _willDisappear = YES;
    
    CCBrowserImageView * currentImageView = (CCBrowserImageView *)recognizer.view;
    NSInteger currentIndex = currentImageView.tag;
    UIView * sourceView = self.sourceImagesContainerView.subviews[currentIndex];
    CGRect targetTemp = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
    
    UIImageView * tempView = [[UIImageView alloc] init];
    tempView.contentMode = sourceView.contentMode;
    tempView.clipsToBounds = YES;
    tempView.image = currentImageView.image;
    CGFloat h = (self.bounds.size.width / currentImageView.image.size.width) * currentImageView.image.size.height;
    
    if (!currentImageView.image) {
        // 防止因imageview的image加载失败 导致崩溃
        h = self.bounds.size.height;
    }
    
    tempView.bounds = CGRectMake(0, 0, self.bounds.size.width, h);
    tempView.center = self.center;
    [self addSubview:tempView];
    _saveButton.hidden = YES;
    
    [UIView animateWithDuration:CCPhotoBrowserHiddenImageAnimationDuration animations:^{
        tempView.frame = targetTemp;
        self.backgroundColor = [UIColor clearColor];
        _indexLabel.alpha = 0.1;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

// 双击放大图片
- (void)imageViewDoubleTaped:(UITapGestureRecognizer *)recognizer {
    CCBrowserImageView * imageView = (CCBrowserImageView *)recognizer.view;
    CGFloat scale;
    if (imageView.isScaled) {
        scale = 1.0;
    }else {
        scale = 2.0;
    }
    
    CCBrowserImageView * view = (CCBrowserImageView *)recognizer.view;
    [view doubleTapToZommWithScale:scale];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    rect.size.width += CCPhotoBrowserImageViewMargin * 2;
    _scrollView.bounds = rect;
    _scrollView.center = self.center;
    
    CGFloat y = 0;
    CGFloat w = _scrollView.frame.size.width - CCPhotoBrowserImageViewMargin * 2;
    CGFloat h = _scrollView.frame.size.height;
    
    [_scrollView.subviews enumerateObjectsUsingBlock:^( CCBrowserImageView *  obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat x = CCPhotoBrowserImageViewMargin + idx * (CCPhotoBrowserImageViewMargin * 2 + w);
        obj.frame = CGRectMake(x, y, w, h);
    }];
    
    _scrollView.contentSize = CGSizeMake(_scrollView.subviews.count * _scrollView.frame.size.width, 0);
    _scrollView.contentOffset = CGPointMake(self.currentImageIndex * _scrollView.frame.size.width, 0);
    
    if (!_hasShowedFirstView) {
        [self showFirstImage];
    }
    
    _indexLabel.center = CGPointMake(self.bounds.size.width * 0.5, 35);
    _saveButton.frame = CGRectMake(30, self.bounds.size.height - 70, 50, 25);
}

- (void)showFirstImage {
    UIView * sourceView = self.sourceImagesContainerView.subviews[self.currentImageIndex];
    CGRect rect = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
    UIImageView * tempView = [[UIImageView alloc] init];
    tempView.image = [self placeholderImageForIndex:self.currentImageIndex];
    [self addSubview:tempView];
    
    CGRect targetTemp = [_scrollView.subviews[self.currentImageIndex] bounds];
    tempView.frame = rect;
    tempView.contentMode = [_scrollView.subviews[self.currentImageIndex] contentMode];
    _scrollView.hidden = YES;
    
    [UIView animateWithDuration:CCPhotoBrowserShowImageAnimationDuration animations:^{
        tempView.center = self.center;
        tempView.bounds = (CGRect){CGPointZero,targetTemp.size};
    } completion:^(BOOL finished) {
        _hasShowedFirstView = YES;
        [tempView removeFromSuperview];
        _scrollView.hidden = NO;
    }];
    
}

- (void)setupToolbars {
    // 图片序标
    UILabel * indexLabel = [[UILabel alloc] init];
    indexLabel.bounds = CGRectMake(0, 0, 80, 30);
    indexLabel.textAlignment = NSTextAlignmentCenter;
    indexLabel.textColor = [UIColor whiteColor];
    indexLabel.font = [UIFont boldSystemFontOfSize:20];
    indexLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    indexLabel.layer.cornerRadius = indexLabel.bounds.size.height * 0.5;
    indexLabel.clipsToBounds = YES;
    if (self.imageCount > 1 ) {
        indexLabel.text = [NSString stringWithFormat:@"1/%ld",(long)self.imageCount];
    }
    _indexLabel = indexLabel;
    [self addSubview:indexLabel];
    
    // 保存按钮
    UIButton * saveButton = [[UIButton alloc] init];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveButton.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.9];
    saveButton.layer.cornerRadius = 5;
    saveButton.clipsToBounds = YES;
    [saveButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    _saveButton = saveButton;
    [self addSubview:saveButton];
    
}

- (void)saveImage {
    int index = _scrollView.contentOffset.x / _scrollView.bounds.size.width;
    UIImageView * currentImageView = _scrollView.subviews[index];
    UIImageWriteToSavedPhotosAlbum(currentImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    UIActivityIndicatorView * indicator = [[UIActivityIndicatorView alloc] init];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicator.center = self.center;
    _indicatorView = indicator;
    [[UIApplication sharedApplication].keyWindow addSubview:indicator];
    [indicator startAnimating];
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [_indicatorView removeFromSuperview];
    
    UILabel * label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.9];
    label.layer.cornerRadius = 5;
    label.clipsToBounds = YES;
    label.bounds = CGRectMake(0, 0, 150, 30);
    label.center = self.center;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:17];
    [[UIApplication sharedApplication].keyWindow addSubview:label];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:label];
    if (error) {
        label.text = CCPhotoBrowserSaveImageFailText;
    }else {
        label.text = CCPhotoBrowserSaveImageSuccessText;
    }
    [label performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
}



- (UIImage *)placeholderImageForIndex:(NSInteger)index {
    if ([self.delelgate respondsToSelector:@selector(photoBrowser:placeholderImageForIndex:)]) {
        return [self.delelgate photoBrowser:self placeholderImageForIndex:index];
    }
    return nil;
}

- (NSURL *)highQualityImageURLForIndex:(NSInteger)index {
    if ([self.delelgate respondsToSelector:@selector(photoBrowser:highQualityImageURLForIndex:)]) {
        return [self.delelgate photoBrowser:self highQualityImageURLForIndex:index];
    }
    return nil;
}

- (void)show {
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    self.frame = window.bounds;
    [window addObserver:self forKeyPath:@"frame" options:0 context:nil];
    [window addSubview:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UIView *)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"frame"]) {
        self.frame = object.bounds;
        CCBrowserImageView * currentImageView = _scrollView.subviews[_currentImageIndex];
        if ([currentImageView isKindOfClass:[CCBrowserImageView class]]) {
            [currentImageView clear];
        }
    }
}

#pragma mark - scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int index = (scrollView.contentOffset.x + _scrollView.bounds.size.width * 0.5) / _scrollView.bounds.size.width;
    
    // 缩放的图片在拖动一定距离后清除缩放
    CGFloat margin = 150;
    CGFloat x = scrollView.contentOffset.x;
    if ((x - index * self.bounds.size.width) > margin || (x - index * self.bounds.size.width) < - margin) {
        CCBrowserImageView * imageView = _scrollView.subviews[index];
        if (imageView.isScaled) {
            [UIView animateWithDuration:0.5 animations:^{
                imageView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                [imageView eliminateScale];
            }];
        }
    }
    
    if (!_willDisappear) {
        _indexLabel.text = [NSString stringWithFormat:@"%d/%ld",index + 1,(long)self.imageCount];
    }
    
    [self setupImageOfImageViewForIndex:index];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
