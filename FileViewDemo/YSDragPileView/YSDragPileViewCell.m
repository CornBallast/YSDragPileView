//
//  YSDragPileViewCell.m
//  FileViewDemo
//
//  Created by ys on 2017/6/7.
//  Copyright © 2017年 ys. All rights reserved.
//

#import "YSDragPileViewCell.h"

@implementation YSDragPileViewCell

-(instancetype)initWithFrame:(CGRect)frame Style:(YSDragPileViewCellStyle)style{
    self = [super initWithFrame:frame];
    if (self) {
        [self layoutWithStyle:style];
    }
    return self;
}

//
-(void)layoutWithStyle:(YSDragPileViewCellStyle)style{
    if (style == YSDragPileViewCellStyle_Default) {
        [self layoutCellCustom];
    }
}
//
-(void)layoutCellCustom{
    [self updateImageViewRect];
}
//
-(void)defaultCellStyle{
    self.imageView = [[UIImageView alloc] init];
    self.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.imageView.layer.borderWidth = 2;
    [self addSubview:self.imageView];
}
//
-(void)updateImageViewRect{
    if (self.imageView) {
        self.imageView.frame = self.bounds;
    }else{
        [self defaultCellStyle];
    }
}
@end
