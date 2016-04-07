//
//  CCPhotoBrowserConfig.h
//  CCPhotoBrowser
//
//  Created by admin on 16/4/5.
//  Copyright © 2016年 CuiXinKuan. All rights reserved.
//

typedef enum {
    CCWaitingViewModelLoopDiagram, // 环形
    CCWaitingViewModelPieDiagram  // 饼形
} CCWaitingViewModel;



// 图片保存成功的提示文字
#define CCPhotoBrowserSaveImageSuccessText @"保存成功 !";
// 图片保存成失败的提示文字
#define CCPhotoBrowserSaveImageFailText @"保存失败 !";

// browser 背景色
#define CCPhotoBrowserBackgroundColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.95]
// browser 图片之间的 margin
#define CCPhotoBrowserImageViewMargin 10

// 图片下载进度指示器背景颜色
#define CCWaitingViewBackgroundColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]
// 图片下载进度指示器内部控件间的间距
#define CCWaitingViewItemMargin 10
// 图片下载进度指示进度显示样式（CCWaitingViewModeLoopDiagram 环形，CCWaitingViewModePieDiagram 饼型）
#define CCWaitingViewProgressMode CCWaitingViewModelLoopDiagram


// browser中显示图片动画时长
#define CCPhotoBrowserShowImageAnimationDuration 0.4f
// browser中隐藏图片动画时长
#define CCPhotoBrowserHiddenImageAnimationDuration 0.4f












//#ifndef CCPhotoBrowserConfig_h
//#define CCPhotoBrowserConfig_h
//
//
//#endif /* CCPhotoBrowserConfig_h */
