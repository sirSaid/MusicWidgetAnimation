//
//  CardAnimationView.m
//  MusicWidgetAnimation
//
//  Created by Bear on 16/5/7.
//  Copyright © 2016年 Bear. All rights reserved.
//

#import "CardAnimationView.h"
#import "CardView.h"

typedef void (^UpdateCardsAnimationFinish_Block)();

@interface CardAnimationView ()
{
    UIPanGestureRecognizer  *_panGesture;
    UITapGestureRecognizer  *_tapGesture;
    NSMutableArray          *_cardArray;
    PanDirection            panDir;
    CGFloat                 cardView_width;
    CGFloat                 cardView_height;
    UpdateCardsAnimationFinish_Block _updateCardsAnimationFinish_Block;
}

@property (assign, nonatomic) int       cardIndex;
@property (strong, nonatomic) CardView  *cardView_Now;

@end

@implementation CardAnimationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        //  默认参数配置
        _cardShowInView_Count       = 3;
        _animationDuration_Normal   = 0.2;
        _animationDuration_Flip     = 2;
        _cardRotateWhenPan          = YES;
        _cardRotateMaxAngle         = 8.0;
        _cardAlphaGapValue          = 0.25;
        _cardOffSetPoint            = CGPointMake(0, 25);
        _cardScaleRatio             = 0.08;
        
        cardView_width = WIDTH * 0.8;
        cardView_height = HEIGHT * 0.7;
        
        self.cardIndex = 0;
        panDir = kPanDir_Null;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    static BOOL firstCreateUI = YES;
    if (firstCreateUI == YES) {
        
        [self createUI];
        firstCreateUI = NO;
    }

}


- (void)createUI
{
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture_Event:)];
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture_Event:)];
    _tapGesture.numberOfTapsRequired = 1;
    _cardArray = [[NSMutableArray alloc] init];
    
    for (int i = 0 ; i < _cardShowInView_Count + 2; i++) {
        
        CardView *cardView = [[CardView alloc] initWithFrame:CGRectMake(0, 0, cardView_width, cardView_height)];
        cardView.backgroundColor = [UIColor whiteColor];
        cardView.mainLabel.text = [NSString stringWithFormat:@"%d", i];
        [_cardArray addObject:cardView];
        [self addSubview:cardView];
        
        if (i > 0) {
            [self insertSubview:cardView belowSubview:_cardArray[i - 1]];
        }else{
            [self addSubview:cardView];
        }
    }
    
    [self updateCardsWithAnimation:NO];
}

- (void)updateCardsWithAnimation:(BOOL)animation
{
    if (animation) {
        
        [UIView animateWithDuration:_animationDuration_Normal delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            [self updateCardsDetail];
        } completion:^(BOOL finished) {
            if (_updateCardsAnimationFinish_Block) {
                _updateCardsAnimationFinish_Block();
            }
        }];
    }else{
        [self updateCardsDetail];
    }
}



- (void)updateCardsDetail
{
    int cardAll_count           = (int)[_cardArray count];
    int cardWillDisappear_index = _cardIndex + cardAll_count - 1;
    int cardWillAppear_index    = _cardIndex + cardAll_count - 2;
    
    if (cardWillDisappear_index >= cardAll_count) {
        cardWillDisappear_index -= cardAll_count;
    }
    
    if (cardWillAppear_index >= cardAll_count) {
        cardWillAppear_index -= cardAll_count;
    }
    
    
    //  即将消失的cardView
    CardView *cardView_willDisappear = _cardArray[cardWillDisappear_index];
    if (panDir == kPanDir_Left){
        [cardView_willDisappear setMaxX:0];
    }
    else if (panDir == kPanDir_Right) {
        [cardView_willDisappear setX:self.width];
    }
    
    //  即将显示的cardView
    CardView *cardView_willAppear = _cardArray[cardWillAppear_index];
    cardView_willAppear.alpha = 1 - _cardShowInView_Count * _cardAlphaGapValue;
    [cardView_willAppear setCenter:CGPointMake(self.width / 2.0 - _cardOffSetPoint.x * _cardShowInView_Count, self.height / 2.0 - _cardOffSetPoint.y * _cardShowInView_Count)];
    
    
    _updateCardsAnimationFinish_Block = ^{
        cardView_willDisappear.hidden = YES;
        cardView_willAppear.hidden = YES;
    };

    //  缩放动画
    cardView_willAppear.scaleAnimation.fromValue = cardView_willAppear.scaleAnimation.toValue;
    cardView_willAppear.scaleAnimation.toValue = [NSNumber numberWithFloat:1 - _cardShowInView_Count * _cardScaleRatio];
    cardView_willAppear.scaleAnimation.duration = _animationDuration_Normal;
    [cardView_willAppear.layer addAnimation:cardView_willAppear.scaleAnimation forKey:cardView_willAppear.scaleAnimation.keyPath];
    
    //  旋转复位
    cardView_willAppear.layer.anchorPoint = CGPointMake(0.5, 0.5);
    cardView_willAppear.rotationAnimation.fromValue = [NSNumber numberWithFloat:0];
    cardView_willAppear.rotationAnimation.toValue = [NSNumber numberWithFloat:0];
    [cardView_willAppear.layer addAnimation:cardView_willAppear.rotationAnimation forKey:cardView_willAppear.rotationAnimation.keyPath];
    
    
    //  中间可见的cardView
    for (int j = 0 ; j < _cardShowInView_Count; j++) {
        
        int i = j + _cardIndex;
        if (i >= cardAll_count) {
            i -= cardAll_count;
        }
        
        CardView *cardView = _cardArray[i];
        cardView.hidden = NO;
        cardView.alpha = 1 - j * _cardAlphaGapValue;
        [cardView setCenter:CGPointMake(self.width / 2.0 - _cardOffSetPoint.x * j, self.height / 2.0 - _cardOffSetPoint.y * j)];

        //  缩放动画
        cardView.scaleAnimation.fromValue = cardView.scaleAnimation.toValue;
        cardView.scaleAnimation.toValue = [NSNumber numberWithFloat:1 - j * _cardScaleRatio];
        cardView.scaleAnimation.duration = _animationDuration_Normal;
        [cardView.layer addAnimation:cardView.scaleAnimation forKey:cardView.scaleAnimation.keyPath];
        
        //  手势移交
        if (j == 0) {
            [_panGesture.view removeGestureRecognizer:_panGesture];
            [cardView addGestureRecognizer:_panGesture];
            
            [_tapGesture.view removeGestureRecognizer:_tapGesture];
            [cardView addGestureRecognizer:_tapGesture];
        }
        
        //  即将显示的view插入在最后一个可见cardView的下方
        if (j == _cardShowInView_Count - 1) {
            [self insertSubview:cardView_willAppear belowSubview:cardView];
        }

    }
    
}

- (void)setBigSize:(UIView *)view
{
    [view setWidth_DonotMoveCenter:WIDTH];
    [view setHeight_DonotMoveCenter:HEIGHT];
}

- (void)setSmallSize:(UIView *)view
{
    [view setWidth_DonotMoveCenter:cardView_width];
    [view setHeight_DonotMoveCenter:cardView_height];
}

#pragma mark - Gesture

- (void)tapGesture_Event:(UITapGestureRecognizer *)tapGesture
{
    CardView *cardView = (CardView *)tapGesture.view;
    
    cardView.layer.position = CGPointMake(self.width / 2.0, self.height / 2.0);
    cardView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:_animationDuration_Flip];
    
    NSUInteger index_back = [cardView.subviews indexOfObject:cardView.backBgView];
    NSUInteger index_front = [cardView.subviews indexOfObject:cardView.frontBgView];
    
    
    //  翻转后，back模式
    if (index_back < index_front) {
        
        cardView.cardStatus = kCardStatus_Back;
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:cardView cache:YES];
        
        [self setBigSize:cardView];
        [self setBigSize:cardView.frontBgView];
        [self setBigSize:cardView.backBgView];
        [self setBigSize:(UIView *)cardView.cardViewBack];
    }
    //  翻转后，front模式
    else{
        
        cardView.cardStatus = kCardStatus_Front;
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:cardView cache:YES];
        
        [self setSmallSize:cardView];
        [self setSmallSize:cardView.frontBgView];
        [self setSmallSize:cardView.backBgView];
        [self setSmallSize:(UIView *)cardView.cardViewBack];
    }
    
    [cardView exchangeSubviewAtIndex:index_back withSubviewAtIndex:index_front];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationWillStartSelector:@selector(flipAnimationWillStart_Event)];
    [UIView setAnimationDidStopSelector:@selector(flipAnimationDidStop_Event)];
    [UIView commitAnimations];
    
    
    
    
    
    
    
//    cardView.flipAnimation.duration = _animationDuration_Normal;
//    cardView.flipAnimation.fromValue = 0;
//    cardView.flipAnimation.toValue = [NSNumber numberWithFloat:M_PI/2.0];
//    [cardView.layer addAnimation:cardView.flipAnimation forKey:cardView.flipAnimation.keyPath];
//    NSLog(@"card:%@", cardView.mainLabel.text);
    
//    CATransform3D transform = CATransform3DMakeTranslation(0.0f, 0.0f, -15.0f);
//    transform = CATransform3DRotate(transform, (CGFloat)M_PI + 0.4f, 0.0f, 0.0f, 1.0f);
//    transform = CATransform3DRotate(transform, (CGFloat)M_PI_4, 1.0f, 0.0f, 0.0f);
//    transform = CATransform3DRotate(transform, -0.4f, 0.0f, 1.0f, 0.0f);
//    transform = CATransform3DScale(transform, 3.0f, 3.0f, 3.0f);
//    cardView.transform = transform;
    
//    UIViewAnimationOptions trans = UIViewAnimationOptionTransitionFlipFromLeft;
//    [cardView transitionFromView:cardView
//                        toView:cardView
//                      duration:2.0
//                       options:trans
//                    completion:^(BOOL finished) {
//                        
//                    }];
    
    
    
//    id animationsBlock = ^{
//        
//        CATransform3D transform = CATransform3DIdentity;
////        transform = CATransform3DMakeTranslation(0.0f, 0.0f, -15.0f);
////        transform = CATransform3DRotate(transform, (CGFloat)M_PI + 0.4f, 0.0f, 0.0f, 1.0f);
////        transform = CATransform3DRotate(transform, (CGFloat)M_PI_4, 1.0f, 0.0f, 0.0f);
////        transform = CATransform3DRotate(transform, -0.4f, 0.0f, 1.0f, 0.0f);
//        transform = CATransform3DRotate(transform, M_PI, 0, 1, 0);
////        transform = CATransform3DScale(transform, 3.0f, 3.0f, 3.0f);
//        
//        
//        CALayer *layer = cardView.layer;
//        CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
//        rotationAndPerspectiveTransform.m34 = 1.0 / 500;
//        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, M_PI, 1.0f, 0.0f, 0.0f);
//        
//        
//        rotationAndPerspectiveTransform = transform;
//        layer.transform = rotationAndPerspectiveTransform;
//    };
//    [UIView animateWithDuration:2.25
//                          delay:0.0
//                        options: UIViewAnimationOptionCurveEaseInOut
//                     animations:animationsBlock
//                     completion:^(BOOL finished) {
//                         
//                         NSUInteger index_1 = [cardView.subviews indexOfObject:cardView.frontBgView];
//                         NSUInteger index_2 = [cardView.subviews indexOfObject:cardView.backBgView];
//                         [cardView exchangeSubviewAtIndex:index_1 withSubviewAtIndex:index_2];
//                     }];
    
    
}

- (void)flipAnimationWillStart_Event
{
    [_cardView_Now removeGestureRecognizer:_panGesture];
}

- (void)flipAnimationDidStop_Event
{
    [_cardView_Now addGestureRecognizer:_panGesture];
}

/**
 *
 *  lastPositionX:              上一次的X值
 *  lastView:                   上一次处理的view
 *
 *  leftThreshold_x:            手势阈值 绝对向左手势
 *  rightThreshold_x:           手势阈值 绝对向右手势
 *  position:                   手势在self中的坐标
 *  position_translationInSelf: 手势在self中的坐标(只要手势不抬起，就一直记录)
 *  rotationThreshold_degree:   旋转阈值，旋转角度超出该阈值后不再旋转，开始平移操作
 *  gestureView:                当前手势所在view
 */
- (void)panGesture_Event:(UIPanGestureRecognizer *)panGesture
{
    static CGFloat      lastPositionX = 0;
    static UIView       *lastView;
    
    CGFloat     leftThreshold_x             = self.width * (2.0 / 4);
    CGFloat     rightThreshold_x            = self.width * (2.0 / 4);
    CGPoint     position                    = [panGesture locationInView:self];
    CGPoint     position_translationInSelf  = [panGesture translationInView:self];
    CGFloat     rotationThreshold_degree    = 1.0 * _cardRotateMaxAngle / 180 * M_PI;
    CardView    *gestureView                = (CardView *)panGesture.view;
    
    
    //  back模式，return
    if (gestureView.cardStatus == kCardStatus_Back) {
        return;
    }
    
    //  没有历史数据，每次切换页面时，只存储历史值，然后return
    if (!lastView || ![lastView isEqual:gestureView]) {
        lastView = gestureView;
        lastPositionX = position.x;
        return;
    }

    //  计算旋转角度
    CGFloat tanA = position_translationInSelf.x / (cardView_height / 3.0);
    CGFloat rotation_degree = atan(tanA);
    
    //  旋转
    BOOL res_rotation1 = (rotation_degree > 0 && rotation_degree < rotationThreshold_degree);
    bool res_rotation2 = (rotation_degree < 0 && -rotation_degree < rotationThreshold_degree);
    if ((res_rotation1 || res_rotation2) && _cardRotateWhenPan)
    {
        //  手势改变
        if (panGesture.state == UIGestureRecognizerStateChanged) {
            gestureView.layer.position = CGPointMake(self.width / 2.0, self.height / 2.0 + cardView_height / 2.0);
            gestureView.layer.anchorPoint = CGPointMake(0.5, 1);
            
            gestureView.rotationAnimation.fromValue = gestureView.rotationAnimation.toValue;
            gestureView.rotationAnimation.toValue = [NSNumber numberWithFloat:rotation_degree];
            [gestureView.layer addAnimation:gestureView.rotationAnimation forKey:gestureView.rotationAnimation.keyPath];
        }
        //  手势结束
        else if (panGesture.state == UIGestureRecognizerStateEnded){
            
            //  仍然有旋转角度
            if (gestureView.rotationAnimation.toValue != [NSNumber numberWithFloat:0]) {
                gestureView.rotationAnimation.fromValue = gestureView.rotationAnimation.toValue;
                gestureView.rotationAnimation.toValue = [NSNumber numberWithFloat:0];
                [gestureView.layer addAnimation:gestureView.rotationAnimation forKey:gestureView.rotationAnimation.keyPath];
            }
        }
        
        
        
    }
    //  平移
    else{
        
        if (_cardRotateWhenPan == YES) {
            //  旋转最终角度校对
            BOOL res_1 = (gestureView.rotationAnimation.toValue != [NSNumber numberWithFloat:rotationThreshold_degree]);
            BOOL res_2 = (gestureView.rotationAnimation.toValue != [NSNumber numberWithFloat:-rotationThreshold_degree]);
            BOOL res_3 = (rotation_degree > 0);
            if ((res_3 && res_1) || (!res_3 && res_2)) {
                
                NSNumber *toValue = [NSNumber numberWithFloat:rotationThreshold_degree];
                if (res_3 && res_1) {
                    
                    toValue = [NSNumber numberWithFloat:rotationThreshold_degree];
                }else if (!res_3 && res_2){
                    toValue = [NSNumber numberWithFloat:-rotationThreshold_degree];
                }
                
                gestureView.layer.position = CGPointMake(gestureView.layer.position.x, self.height / 2.0 + cardView_height / 2.0);
                gestureView.layer.anchorPoint = CGPointMake(0.5, 1);
                
                gestureView.rotationAnimation.fromValue = gestureView.rotationAnimation.toValue;
                gestureView.rotationAnimation.toValue = toValue;
                [gestureView.layer addAnimation:gestureView.rotationAnimation forKey:gestureView.rotationAnimation.keyPath];
            }
        }
        
        
        //  和历史坐标比较，判断左滑
        if (lastPositionX > position.x) {
            panDir = kPanDir_Left;
        }
        //  和历史坐标比较，判断右滑
        else if (lastPositionX < position.x){
            panDir = kPanDir_Right;
        }
        
        
        //  绝对左滑
        if (position.x < leftThreshold_x) {
            panDir = kPanDir_Left;
        }
        //  绝对右滑
        else if (position.x > rightThreshold_x){
            panDir = kPanDir_Right;
        }
        
        
        //  判断手势
        switch (panGesture.state) {
            case UIGestureRecognizerStateChanged:
            {
                [gestureView setX:gestureView.x + (position.x - lastPositionX)];
            }
                break;
                
            case UIGestureRecognizerStateEnded:
            {
                
                switch (panDir) {
                    case kPanDir_Left:
                    {
                        [self disappearToLeft:panGesture];
                    }
                        break;
                        
                    case kPanDir_Right:
                    {
                        [self disappearToRight:panGesture];
                    }
                        break;
                        
                    case kPanDir_Null:
                    {
                        nil;
                    }
                        break;
                        
                    default:
                        break;
                }
            }
                break;
                
            default:
                break;
        }
    }
    

    //  存储历史X值
    lastPositionX = position.x;
}

//  从左侧消失
- (void)disappearToLeft:(UIPanGestureRecognizer *)panGesture
{
    if (self.cardIndex + 2 > [_cardArray count]) {
        self.cardIndex = 0;
    }else{
        self.cardIndex = self.cardIndex + 1;
    }
}

//  从右侧消失
- (void)disappearToRight:(UIPanGestureRecognizer *)panGesture
{
    if (self.cardIndex + 2 > [_cardArray count]) {
        self.cardIndex = 0;
    }else{
        self.cardIndex = self.cardIndex + 1;
    }
}


#pragma mark - 重写cardIndex

@synthesize cardIndex = _cardIndex;
- (void)setCardIndex:(int)cardIndex
{
    _cardIndex = cardIndex;
    
    _cardView_Now = _cardArray[_cardIndex];
    [self updateCardsWithAnimation:YES];
}

@end