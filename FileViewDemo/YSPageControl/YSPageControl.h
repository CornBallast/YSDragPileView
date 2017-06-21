//
//  YSPageControl.h
//  FileViewDemo
//
//  Created by ys on 2017/6/9.
//  Copyright © 2017年 ys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSPageControl : UIControl

@property(nonatomic,copy)void(^tapAction)(NSInteger currentIndex);

@property(nonatomic,assign)NSInteger currentPage;
@property(nonatomic,assign)NSInteger numberOfPages;
//
@property(nonatomic,strong)UIImage *thumbImage;
@property(nonatomic,strong)UIImage *selectedThumbImage;
@property(nonatomic,strong)NSMutableDictionary *thumbImageForIndex;
@property(nonatomic,strong)NSMutableDictionary *selectedThumbImageForIndex;
@property(nonatomic,assign)NSInteger diameter; //点的大小
@property(nonatomic,assign)NSInteger gapWidth; //点与点之间的间距
@property(nonatomic,assign)BOOL canTouch;
@end
