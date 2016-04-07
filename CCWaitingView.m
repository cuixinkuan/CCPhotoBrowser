//
//  CCWaitingView.m
//  CCPhotoBrowser
//
//  Created by admin on 16/4/5.
//  Copyright © 2016年 CuiXinKuan. All rights reserved.
//

#import "CCWaitingView.h"

@implementation CCWaitingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = CCWaitingViewBackgroundColor;
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        self.mode = CCWaitingViewModelLoopDiagram;
    }
    return self;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self setNeedsDisplay];
    if (progress >= 1) {
        [self removeFromSuperview];
    }
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat xCenter = rect.size.width * 0.5;
    CGFloat yCenter = rect.size.height * 0.5;
    
    switch (self.mode) {
        case CCWaitingViewModelPieDiagram:
        {
            CGFloat radius = MIN(rect.size.width * 0.5, rect.size.height * 0.5) - CCWaitingViewItemMargin;
            CGFloat w = radius * 2 + CCWaitingViewItemMargin;
            CGFloat h = w;
            CGFloat x = (rect.size.width - w) * 0.5;
            CGFloat y = (rect.size.height - h) * 0.5;
            CGContextAddEllipseInRect(ctx, CGRectMake(x, y, w, h));
            CGContextFillPath(ctx);
            
            [CCWaitingViewBackgroundColor set];
            CGContextMoveToPoint(ctx, xCenter, yCenter);
            CGContextAddLineToPoint(ctx, xCenter, 0);
            // 初始值
            CGFloat to = - M_PI * 0.5 + self.progress * M_PI * 2 + 0.001;
            CGContextAddArc(ctx, xCenter, yCenter, radius, - M_PI * 0.5, to, 1);
            CGContextClosePath(ctx);
            CGContextFillPath(ctx);
            
        }
            break;
            
        default:
        {
            CGContextSetLineWidth(ctx, 15);
            CGContextSetLineCap(ctx, kCGLineCapRound);
            // 初始值
            CGFloat to = - M_PI * 0.5 + self.progress * M_PI * 2 + 0.05;
            CGFloat radius = MIN(rect.size.width, rect.size.height)*0.5 - CCWaitingViewItemMargin;
            CGContextAddArc(ctx, xCenter, yCenter, radius, - M_PI * 0.5, to, 0);
            CGContextStrokePath(ctx);
            
        }
            break;
    }

}




@end
