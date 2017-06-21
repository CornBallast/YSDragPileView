//
//  YSDragPileView.m
//  FileViewDemo
//
//  Created by ys on 2017/6/7.
//  Copyright © 2017年 ys. All rights reserved.
//

#import "YSDragPileView.h"
#import "YSDragPileViewCell.h"
#pragma mark - 参数配置

#define YSScreenWidth  [UIScreen mainScreen].bounds.size.width
#define YSScreenHeight [UIScreen mainScreen].bounds.size.height

static const CGFloat ysNextCellRatio = 0.8f; //下一个拖动百分比
static const CGFloat ysSecondCellScale = 0.95f; //第二个Cell缩放比例
static const CGFloat ysThirdCellScale = 0.9f; //第三个Cell缩放比例
static const CGFloat ysForthCellScale = 0.85f; //第四个Cell缩放比例

static const CGFloat ysCellEdage = 15.0f; //cell之间的间距
static const CGFloat ysContainerEdage = 15.0f; //cell上下左右距离pileView的间距

static const CGFloat ysVisibleCellCount = 4; //前面显示的cell个数



@interface YSDragPileView ()
@property(nonatomic,assign)YSDragPileViewStyle style;
@property(nonatomic,assign)YSDragDirection direction;
@property(nonatomic,strong)NSMutableArray *loadedCellsArray; //当前已经显示的cell
@property(nonatomic,assign)BOOL moving; //是否正在移动
@property(nonatomic,assign)NSInteger loadedCellIndex; //已加载到几个cell
//
@property(nonatomic,assign)CGRect firstCellFrame;
@property(nonatomic,assign)CGRect lastCellFrame;
@property(nonatomic,assign)CGAffineTransform lastCellTransform;
@property(nonatomic,assign)CGPoint cellCenter;
@property(nonatomic,assign)BOOL isLoop;
@property(nonatomic,assign)BOOL loopStart;
@end


@implementation YSDragPileView

-(instancetype)initWithFrame:(CGRect)frame style:(YSDragPileViewStyle)style{
    self = [super initWithFrame:frame];
    if (self) {
        self.style = style;
    }
    return self;
}
//刷新试图
-(void)reloadData{
    [self resetData];
    [self cellsLayoutUpdate];
    [self resetCellEffect];
}
//从指定方向移除cell
-(void)dragViewOffForDirection:(YSDragDirection)direction{
    if (self.moving) {
        return;
    }
    CGPoint cellCenter = CGPointZero;
    CGFloat flag = 0;
    if (direction == YSDragDirection_Left) {
        cellCenter = CGPointMake(-YSScreenWidth / 2, self.cellCenter.y);
        flag = -1;
    }else if (direction == YSDragDirection_Right){
        cellCenter = CGPointMake(YSScreenWidth * 1.5, self.cellCenter.y);
        flag = 1;
    }
    YSDragPileViewCell *firstCell = [self.loadedCellsArray firstObject];
    [UIView animateWithDuration:0.3 animations:^{
        CGAffineTransform translate = CGAffineTransformTranslate(CGAffineTransformIdentity, flag * 20, 0);
        firstCell.transform = CGAffineTransformRotate(translate, flag * M_PI_4 / 6);
        firstCell.center = cellCenter;
    } completion:^(BOOL finished) {
        [firstCell removeFromSuperview];
        [self.loadedCellsArray removeObject:firstCell];
        //
        YSDragPileViewCell *currentCell = [self.loadedCellsArray firstObject];
        if (self.delegate && [self.delegate respondsToSelector:@selector(pileViewEndDragging:frontIndex:)]) {
            [self.delegate pileViewEndDragging:self frontIndex:currentCell.tag];
        }
        //
        [self cellsLayoutUpdate];
        [self resetCellEffect];
    }];
}

//清除显示数据
-(void)resetData{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.loopStart = NO;
    self.loadedCellsArray = [NSMutableArray new];
    self.direction = YSDragDirection_Default;
    self.moving = NO;
    self.loadedCellIndex = 0;
}
//生成cell排版样式
-(void)cellsLayoutUpdate{
    //最多显示四个,其他堆叠在后面,循环
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfCellInPileView:)] && [self.dataSource respondsToSelector:@selector(pileView:cellIndex:)]) {
        //cell个数
        NSInteger cellCount = [self.dataSource numberOfCellInPileView:self];
        //是否循环
        _isLoop = NO;
        if ([self.dataSource respondsToSelector:@selector(isLoop:)]) {
            _isLoop = [self.dataSource isLoop:self];
        }
        NSInteger frontCellCount = cellCount >= ysVisibleCellCount ? ysVisibleCellCount : cellCount;
        //
        if (_isLoop && self.loadedCellIndex == cellCount) {
            self.loadedCellIndex = 0;
            _loopStart = YES;
        }
        //
        if (self.loadedCellIndex < cellCount) {
            for (NSInteger i = self.loadedCellsArray.count; i < (self.moving ? frontCellCount + 1 : frontCellCount); i ++) {
                YSDragPileViewCell *cell = [self.dataSource pileView:self cellIndex:self.loadedCellIndex];
                cell.frame = [self cellFrame];
                [cell layoutCellCustom];
                //
                cell.tag = self.loadedCellIndex;
                //添加cell 并倒序显示
                [self addSubview:cell];
                [self sendSubviewToBack:cell];
                [self.loadedCellsArray addObject:cell];
                //添加滑动手势
                UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureOnCell:)];
                [cell addGestureRecognizer:panGesture];
                //添加点击手势
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureOnCell:)];
                [cell addGestureRecognizer:tapGesture];
                //
                self.loadedCellIndex ++;
                //NSLog(@"加载到第%@个Cell",@(self.loadedCellIndex));
            }
        }
    }else{
        NSLog(@"请实现协议dataSource方法");
    }
}
//Cell效果
-(void)resetCellEffect{
    __weak YSDragPileView *weakSelf = self;
    //
    [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:0.6f options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction animations:^{
        [weakSelf originalCellEffect];
    } completion:^(BOOL finished) {
        
    }];
}
//初始化cell效果
-(void)originalCellEffect{
    for (int i = 0; i < self.loadedCellsArray.count; i ++) {
        YSDragPileViewCell *cell = self.loadedCellsArray[i];
        cell.transform = CGAffineTransformIdentity;
        CGRect cellFrame = self.firstCellFrame;
        //
        switch (i) {
            case 0:
                cell.frame = self.firstCellFrame;
                break;
            case 1:
                if (_style == YSDragPileViewStyle_Bottom) {
                    cellFrame.origin.y += ysCellEdage;
                }else if (_style == YSDragPileViewStyle_Top){
                    cellFrame.origin.y -= ysCellEdage;
                }
                cell.frame = cellFrame;
                cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, ysSecondCellScale, 1);
                break;
            case 2:
                if (_style == YSDragPileViewStyle_Bottom) {
                    cellFrame.origin.y += ysCellEdage * 2;
                }else if (_style == YSDragPileViewStyle_Top){
                    cellFrame.origin.y -= ysCellEdage * 2;
                }
                cell.frame = cellFrame;
                cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, ysThirdCellScale, 1);
                break;
            case 3:
                if (_style == YSDragPileViewStyle_Bottom) {
                    cellFrame.origin.y += ysCellEdage * 3;
                }else if (_style == YSDragPileViewStyle_Top){
                    cellFrame.origin.y -= ysCellEdage * 3;
                }
                cell.frame = cellFrame;
                cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, ysForthCellScale, 1);
                if (CGRectIsEmpty(self.lastCellFrame)) {
                    self.lastCellFrame = cellFrame;
                    self.lastCellTransform = cell.transform;
                }
                break;
                
            default:
                break;
        }
        cell.originalTransform = cell.transform;
    }
}

//生成cell的frame
-(CGRect)cellFrame{
    CGRect cellRect = CGRectZero;
    if (self.loadedCellIndex >= ysVisibleCellCount || _loopStart) {
        return self.lastCellFrame;
    }
    //
    CGFloat self_width = self.frame.size.width;
    CGFloat self_height = self.frame.size.height;
    //YSDragPileViewStyle_Default
    CGFloat cell_height = self_height - ysContainerEdage * 2;
    CGFloat cell_width = self_width - ysContainerEdage * 2;
    cellRect = CGRectMake(ysContainerEdage, ysContainerEdage, cell_width, cell_height);
    //
    if (self.style == YSDragPileViewStyle_Bottom) {
        cell_height = self_height - ysContainerEdage * 2 - ysCellEdage * 3;
        cell_width = self_width - ysContainerEdage * 2;
        cellRect = CGRectMake(ysContainerEdage, ysContainerEdage, cell_width, cell_height);
    }else if (self.style == YSDragPileViewStyle_Top){
        cell_height = self_height - ysContainerEdage * 2 - ysCellEdage * 3;
        cell_width = self_width - ysContainerEdage * 2;
        cellRect = CGRectMake(ysContainerEdage, ysContainerEdage + ysCellEdage * 3, cell_width, cell_height);
    }
    //记录第一个cell的位置
    if (CGRectIsEmpty(self.firstCellFrame)) {
        self.firstCellFrame = cellRect;
        self.cellCenter = CGPointMake(ysContainerEdage + cell_width / 2, cellRect.origin.y + cell_height / 2);
    }
    return cellRect;
}
//滑动事件
-(void)panGestureOnCell:(UIPanGestureRecognizer*)panGesture{
    
    switch (panGesture.state) {
        //开始滑动
        case UIGestureRecognizerStateBegan:
            
            break;
        //继续滑动
        case UIGestureRecognizerStateChanged:{
            YSDragPileViewCell *cell = (YSDragPileViewCell *)panGesture.view;
            CGPoint point = [panGesture translationInView:self];//相对位移
            CGPoint movedPoint = CGPointMake(panGesture.view.center.x + point.x, panGesture.view.center.y + point.y);
            cell.center = movedPoint;
            cell.transform = CGAffineTransformRotate(cell.originalTransform, (panGesture.view.center.x - self.cellCenter.x) / self.cellCenter.x * (M_PI_4 / 6));
            [panGesture setTranslation:CGPointZero inView:self];
            //
            float width_ratio = (cell.center.x - self.cellCenter.x) / self.cellCenter.x;
            //float height_ratio = (cell.center.y - self.cellCenter.y) / self.cellCenter.y;
            [self movingStateLinkAnimationAndNextStepWithRatio:width_ratio];
            //判断滑动方向
            if (width_ratio > 0) {
                self.direction = YSDragDirection_Right;
            }else if (width_ratio < 0){
                self.direction = YSDragDirection_Left;
            }else{
                self.direction = YSDragDirection_Default;
            }
            //
            if (self.delegate && [self.delegate respondsToSelector:@selector(pileViewDragging:frontIndex:)]) {
                [self.delegate pileViewDragging:self frontIndex:cell.tag];
            }
        }
            break;
        //停止滑动
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:{
            //停止拖动根据位移方向
            float width_ratio = (panGesture.view.center.x - self.cellCenter.x) / self.cellCenter.x;
            float width_distance = (panGesture.view.center.x - self.cellCenter.x);
            float height_distance = (panGesture.view.center.y - self.cellCenter.y);
            [self panFinishedCell:(YSDragPileViewCell*)panGesture.view direction:self.direction scale:(width_distance / height_distance) nextCell:fabs(width_ratio) > ysNextCellRatio];
        }
            break;
        default:
            break;
    }
}

//生成预备的cell
-(void)movingStateLinkAnimationAndNextStepWithRatio:(float)ratio{
    if (!self.moving) {
        self.moving = YES;
        [self cellsLayoutUpdate];
    }else{
        [self movingVisibleCardsAnimation:ratio];
    }
}
//除去第一层cell,其他cell动画效果
-(void)movingVisibleCardsAnimation:(float)ratio{
    ratio = fabs(ratio) >= ysNextCellRatio ? ysNextCellRatio : fabs(ratio);
    CGFloat sPoor = ysSecondCellScale - ysThirdCellScale;
    CGFloat tPoor = sPoor / (ysNextCellRatio / ratio);
    CGFloat yPoor = ysCellEdage / (ysNextCellRatio / ratio);
    if (_style == YSDragPileViewStyle_Top) {
        yPoor = -yPoor;
    }else if (_style == YSDragPileViewStyle_Default){
        sPoor = tPoor = yPoor = 0;
    }
    for (int i = 0; i < self.loadedCellsArray.count; i ++) {
        YSDragPileViewCell *cell = self.loadedCellsArray[i];
        switch (i) {
            case 1:{
                CGAffineTransform scale = CGAffineTransformScale(CGAffineTransformIdentity, tPoor + ysSecondCellScale, 1);
                CGAffineTransform translate = CGAffineTransformTranslate(scale, 0, -yPoor);
                cell.transform = translate;
            }
                break;
            case 2:{
                CGAffineTransform scale = CGAffineTransformScale(CGAffineTransformIdentity, tPoor + ysThirdCellScale, 1);
                CGAffineTransform translate = CGAffineTransformTranslate(scale, 0, -yPoor);
                cell.transform = translate;
            }
                
                break;
            case 3:{
                CGAffineTransform scale = CGAffineTransformScale(CGAffineTransformIdentity, tPoor + ysForthCellScale, 1);
                CGAffineTransform translate = CGAffineTransformTranslate(scale, 0, -yPoor);
                cell.transform = translate;
            }
                break;
            case 4:
                cell.transform = self.lastCellTransform;
                break;
                
            default:
                break;
        }
        
    }
}

//拖拽事件结束后对cell进行操作
-(void)panFinishedCell:(YSDragPileViewCell*)cell direction:(YSDragDirection)direction scale:(CGFloat)scale nextCell:(BOOL)nextCell{
    //
    if (!nextCell) {
        //不切换下一张 还原拖动cell位置 移除底部出现的cell
        if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfCellInPileView:)]) {
            if (self.moving && self.loadedCellsArray.count > ysVisibleCellCount) {
                YSDragPileViewCell *lastCell = [self.loadedCellsArray lastObject];
                [lastCell removeFromSuperview];
                [self.loadedCellsArray removeObject:lastCell];
                self.loadedCellIndex = lastCell.tag;
            }
            self.moving = NO;
            [self resetCellEffect];
        }
    }else{
        //删除需要移除的cell,重新布局当前的cell
        NSInteger outScreenScale = direction == YSDragDirection_Left ? -1 : 2;
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction animations:^{
            cell.center = CGPointMake(YSScreenWidth * outScreenScale, YSScreenWidth * outScreenScale / scale + self.cellCenter.y);
        } completion:^(BOOL finished) {
            [cell removeFromSuperview];
        }];
        [self.loadedCellsArray removeObject:cell];
        self.moving = NO;
        [self resetCellEffect];
    }
    //
    YSDragPileViewCell *currentCell = [self.loadedCellsArray firstObject];
    if (self.delegate && [self.delegate respondsToSelector:@selector(pileViewEndDragging:frontIndex:)]) {
        [self.delegate pileViewEndDragging:self frontIndex:currentCell.tag];
    }
}


//点击事件
-(void)tapGestureOnCell:(UITapGestureRecognizer*)tapGesture{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pileView:didSelectViewAtIndex:)]) {
        [self.delegate pileView:self didSelectViewAtIndex:tapGesture.view.tag];
    }
}

@end
