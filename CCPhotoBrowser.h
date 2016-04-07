//
//  CCPhotoBrowser.h
//  CCPhotoBrowser
//
//  Created by admin on 16/4/6.
//  Copyright © 2016年 CuiXinKuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCButton,CCPhotoBrowser;

@protocol CCPhotoBrowserDelegate <NSObject>

@required

- (UIImage *)photoBrowser:(CCPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index;

@optional
- (NSURL *)photoBrowser:(CCPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index;

@end

@interface CCPhotoBrowser : UIView <UIScrollViewDelegate>

@property (nonatomic,weak)UIView * sourceImagesContainerView;
@property (nonatomic,assign)NSInteger currentImageIndex;
@property (nonatomic,assign)NSInteger imageCount;

@property (nonatomic,weak)id<CCPhotoBrowserDelegate> delelgate;

- (void)show;

@end
