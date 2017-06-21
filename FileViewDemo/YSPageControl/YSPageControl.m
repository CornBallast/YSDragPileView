//
//  YSPageControl.m
//  FileViewDemo
//
//  Created by ys on 2017/6/9.
//  Copyright © 2017年 ys. All rights reserved.
//

#import "YSPageControl.h"

@implementation YSPageControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        
    }
    return self;
}

-(void)setup{
    [self setBackgroundColor:[UIColor clearColor]];
    _gapWidth = 20;
    _diameter = 12;
    _canTouch = YES;
    //
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapped:)];
    [self addGestureRecognizer:tapGestureRecognizer];
}
//点击切换
- (void)onTapped:(UITapGestureRecognizer*)gesture
{
    CGPoint touchPoint = [gesture locationInView:[gesture view]];
    
    if (touchPoint.x < self.frame.size.width/2)
    {
        // move left
        if (self.currentPage>0)
        {
            if (touchPoint.x <= 22)
            {
                self.currentPage = 0;
            }
            else
            {
                self.currentPage -= 1;
            }
        }
    }
    else
    {
        // move right
        if (self.currentPage<self.numberOfPages-1)
        {
            if (touchPoint.x >= (CGRectGetWidth(self.bounds) - 22))
            {
                self.currentPage = self.numberOfPages - 1;
            }
            else
            {
                self.currentPage += 1;
            }
        }
    }
    [self setNeedsDisplay];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    //
    if (_tapAction) {
        _tapAction(self.currentPage);
    }
}

-(void)drawRect:(CGRect)rect{
    NSInteger gap = self.gapWidth;
    float diameter = self.diameter;
    
    if (self.thumbImage && self.selectedThumbImage)
    {
        diameter = self.thumbImage.size.width;
    }
    //
    NSInteger total_width = self.numberOfPages * diameter + (self.numberOfPages-1) * gap;
    //
    if (total_width > self.frame.size.width)
    {
        while (total_width > self.frame.size.width)
        {
            diameter -= 2;
            gap = diameter + 2;
            while (total_width > self.frame.size.width)
            {
                gap -= 1;
                total_width = self.numberOfPages * diameter + (self.numberOfPages-1) * gap;
                //
                if (gap == 2)
                {
                    break;
                }
            }
            //
            if (diameter == 2)
            {
                break;
            }
        }
    }
    
    int i;
    for (i = 0; i < self.numberOfPages; i ++)
    {
        int x = (self.frame.size.width - total_width) / 2 + i * (diameter + gap);
        UIImage* thumbImage = [self thumbImageForIndex:i];
        UIImage* selectedThumbImage = [self selectedThumbImageForIndex:i];
        
        if (thumbImage && selectedThumbImage)
        {
            if (i==self.currentPage)
            {
                [selectedThumbImage drawInRect:CGRectMake(x,(self.frame.size.height - selectedThumbImage.size.height) / 2,selectedThumbImage.size.width,selectedThumbImage.size.height)];
            }
            else
            {
                [thumbImage drawInRect:CGRectMake(x,(self.frame.size.height - thumbImage.size.height) / 2,thumbImage.size.width,thumbImage.size.height)];
            }
        }
    }
    if (!_canTouch) {
        self.userInteractionEnabled = NO;
    }else{
        self.userInteractionEnabled = YES;
    }
}
//
- (UIImage *)thumbImageForIndex:(NSInteger)index {
    UIImage* aThumbImage = [self.thumbImageForIndex objectForKey:@(index)];
    if (aThumbImage == nil) aThumbImage = self.thumbImage;
    return aThumbImage;
}
//
- (UIImage *)selectedThumbImageForIndex:(NSInteger)index {
    UIImage* aSelectedThumbImage = [self.selectedThumbImageForIndex objectForKey:@(index)];
    if (aSelectedThumbImage == nil) aSelectedThumbImage = self.selectedThumbImage;
    return aSelectedThumbImage;
}

//设置当前page
- (void)setCurrentPage:(NSInteger)page
{
    _currentPage = page;
    [self setNeedsDisplay];
}
//设置page个数
- (void)setNumberOfPages:(NSInteger)numOfPages
{
    _numberOfPages = numOfPages;
    [self setNeedsDisplay];
}

@end
