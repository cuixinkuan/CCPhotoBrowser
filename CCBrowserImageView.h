//
//  CCBrowserImageView.h
//  CCPhotoBrowser
//
//  Created by admin on 16/4/5.
//  Copyright © 2016年 CuiXinKuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCWaitingView.h"

@interface CCBrowserImageView : UIImageView<UIGestureRecognizerDelegate>

{
//
}

@property (nonatomic,assign)CGFloat progress;
@property (nonatomic,assign,readonly)BOOL isScaled;
@property (nonatomic,assign)BOOL hasLoadedImage;


- (void)eliminateScale; // 清除缩放
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;
- (void)doubleTapToZommWithScale:(CGFloat)scale;
- (void)clear;

@end
