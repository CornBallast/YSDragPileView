//
//  YSDragPileView.h
//  FileViewDemo
//
//  Created by ys on 2017/6/7.
//  Copyright © 2017年 ys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSDragPileViewCell.h"
@class YSDragPileView;
//拖拽方向
typedef enum : NSUInteger{
    YSDragDirection_Default = 0,
    YSDragDirection_Left,
    YSDragDirection_Right
}YSDragDirection;
//cell排列样式
typedef enum : NSUInteger{
    YSDragPileViewStyle_Default = 0,
    YSDragPileViewStyle_Top,
    YSDragPileViewStyle_Bottom
}YSDragPileViewStyle;


@protocol YSDragPileViewDelegate <NSObject>
@optional
//点击cell
- (void)pileView:(YSDragPileView *_Nullable)pileView didSelectViewAtIndex:(NSInteger)index;
//开始拖动
- (void)pileViewDragging:(YSDragPileView *_Nullable)pileView frontIndex:(NSInteger)frontIndex;
//拖动结束
- (void)pileViewEndDragging:(YSDragPileView *_Nullable)pileView frontIndex:(NSInteger)frontIndex;

@end


@protocol YSDragPileViewDateSource <NSObject>
@required
//cell个数
- (NSInteger)numberOfCellInPileView:(YSDragPileView *_Nullable)pileView;
//创建cell
- (YSDragPileViewCell *_Nullable)pileView:(YSDragPileView *_Nullable)pileView cellIndex:(NSInteger)index;

@optional
//是否无限循环
//⚠️ 目前循环只支持4个Cell以上 后续兼容
-(BOOL)isLoop:(YSDragPileView *_Nullable)pileView;
@end


@interface YSDragPileView : UIView

@property (nonatomic, weak, nullable) id <YSDragPileViewDateSource> dataSource;
@property (nonatomic, weak, nullable) id <YSDragPileViewDelegate> delegate;
//
-(instancetype _Nullable)initWithFrame:(CGRect)frame style:(YSDragPileViewStyle)style;
-(void)dragViewOffForDirection:(YSDragDirection)direction;
-(void)reloadData;

@end
