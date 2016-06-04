//
//  ViewController.m
//  MusicWidgetAnimation
//
//  Created by Bear on 16/5/7.
//  Copyright © 2016年 Bear. All rights reserved.
//

#import "ViewController.h"
#import "CardAnimationView.h"
#import "MyCardView.h"
#import "ExchangeImageView.h"

@interface ViewController () <CardAnimationViewDelegate>
{
    NSArray *_imageArray;
    ExchangeImageView *_bgImageView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    _imageArray = @[@"TestImage_1",
                    @"TestImage_2",
                    @"TestImage_3",
                    @"TestImage_4",
                    @"TestImage_5",
                    @"TestImage_6",
                    @"TestImage_7",
                    @"TestImage_8",
                    @"TestImage_9",
                    @"TestImage_10",
                    @"TestImage_11",
                    @"TestImage_12",
                    @"TestImage_13",
                    @"TestImage_14",
                    @"TestImage_15",
                    @"TestImage_16",
                    @"TestImage_17",
                    @"TestImage_18"];
    
    _bgImageView = [[ExchangeImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
//    _bgImageView.nextImageName = _imageArray[0];
    [self.view addSubview:_bgImageView];
    
    CardAnimationView *cardAnimationView = [[CardAnimationView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    cardAnimationView.delegate = self;
    cardAnimationView.backgroundColor = [UIColor clearColor];
    cardAnimationView.cardShowInView_Count = 3;
//    cardAnimationView.animationDuration_Normal = 0.7;
//    cardAnimationView.animationDuration_Flip = 1.0;
//    cardAnimationView.cardRotateWhenPan = NO;
//    cardAnimationView.cardRotateMaxAngle = 45;
//    cardAnimationView.cardAlphaGapValue = 0.1;
//    cardAnimationView.cardOffSetPoint = CGPointMake(25, 40);
//    cardAnimationView.cardScaleRatio  = 0.15;
//    cardAnimationView.cardFlyMaxDistance = 80;
    cardAnimationView.cardCycleShow = YES;
//    cardAnimationView.cardPanEnable = NO;

    [self.view addSubview:cardAnimationView];

}


#pragma mark - CardAnimationView delegate
- (CardViewCell *)cardViewInCardAnimationView:(CardAnimationView *)cardAnimationView AtIndex:(int)index
{
    CGFloat cardView_width = WIDTH * 0.8;
    CGFloat cardView_height = HEIGHT * 0.7;
    NSString *cardViewID_Str = @"cardViewID_Str";
    
    MyCardView *cardView = (MyCardView *)[cardAnimationView dequeueReusableCardViewCellWithIdentifier:cardViewID_Str];
    if (!cardView) {
        cardView = [[MyCardView alloc] initWithFrame:CGRectMake(0, 0, cardView_width, cardView_height) reuseIdentifier:cardViewID_Str];
    }
    
    cardView.backgroundColor = [UIColor whiteColor];
    cardView.cardViewFront.mainLabel.text = [NSString stringWithFormat:@"%d--1", index];
    cardView.cardViewFront.headImgV.image = [UIImage imageNamed:_imageArray[index]];
    
    return cardView;
}

- (NSInteger)numberOfCardsInCardAnimationView:(CardAnimationView *)cardAnimationView
{
    return [_imageArray count];
}

- (void)cardViewWillShowWithIndex:(NSInteger)index
{
    NSLog(@"index:%ld", (long)index);
    _bgImageView.nextImageName = _imageArray[index];
//    _bgImageView.image = [UIImage imageNamed:_imageArray[index]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
