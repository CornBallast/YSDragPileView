//
//  ViewController.m
//  FileViewDemo
//
//  Created by ys on 2017/6/7.
//  Copyright © 2017年 ys. All rights reserved.
//

#import "ViewController.h"
#import "YSDragPileView.h"
#import "YSPageControl.h"
@interface ViewController ()<YSDragPileViewDelegate,YSDragPileViewDateSource>
@property (nonatomic, strong) YSDragPileView *container;
@property (nonatomic, strong) YSPageControl *pageControl;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.container = [[YSDragPileView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.width * 1.3) style:YSDragPileViewStyle_Top];
    self.container.delegate = self;
    self.container.dataSource = self;
    self.container.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.container];
    // 重启加载
    [self.container reloadData];
    //
    [self addPageControl];
}
//
-(void)addPageControl{
    _pageControl = [[YSPageControl alloc] initWithFrame:CGRectZero];
    [self.pageControl setFrame:CGRectMake(20,self.view.frame.size.height-50,self.view.frame.size.width-40,20)];
    _pageControl.canTouch = NO;
    [self.pageControl setThumbImage:[UIImage imageNamed:@"dot_normal.png"]];
    [self.pageControl setSelectedThumbImage:[UIImage imageNamed:@"dot_selected.png"]];
    [self.pageControl setNumberOfPages:4];
    [self.view addSubview:_pageControl];
}
//
- (YSDragPileViewCell*)pileView:(YSDragPileView *)pileView cellIndex:(NSInteger)index{
    YSDragPileViewCell *cell = [[YSDragPileViewCell alloc] initWithFrame:CGRectZero Style:YSDragPileViewCellStyle_Default];
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",@(index)]];
    return cell;
}

- (NSInteger)numberOfCellInPileView:(YSDragPileView *)pileView{
    return 4;
}

-(BOOL)isLoop:(YSDragPileView *)pileView{
    return YES;
}

-(void)pileViewEndDragging:(YSDragPileView *)pileView frontIndex:(NSInteger)frontIndex{
    NSLog(@"当前cellTag__%@",@(frontIndex));
    _pageControl.currentPage = frontIndex;
}


//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
//    if (touchPoint.x < self.view.center.x) {
//        [self.container dragViewOffForDirection:YSDragDirection_Left];
//    }else{
//        [self.container dragViewOffForDirection:YSDragDirection_Right];
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
