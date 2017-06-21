//
//  YSDragPileViewCell.h
//  FileViewDemo
//
//  Created by ys on 2017/6/7.
//  Copyright © 2017年 ys. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum : NSUInteger{
    YSDragPileViewCellStyle_Default = 0, //默认 含有一个UIImageView控件
    YSDragPileViewCellStyle_Custom //自定义
}YSDragPileViewCellStyle;


@interface YSDragPileViewCell : UIView
//
@property(nonatomic,assign)CGAffineTransform originalTransform;
//与cell同大小的图片
@property(nonatomic,strong)UIImageView *imageView;
//创建cell
-(instancetype)initWithFrame:(CGRect)frame Style:(YSDragPileViewCellStyle)style;
//自定义Cell
-(void)layoutCellCustom;
@end
