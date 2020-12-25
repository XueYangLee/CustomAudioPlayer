//
//  PlayerControlRippleView.m
//  CustomAudioPlayer
//
//  Created by Singularity on 2020/12/25.
//

#import "PlayerControlRippleView.h"

#define _multiple 1.35

@implementation PlayerControlRippleView

- (instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
//        self.layer.cornerRadius=30;
        
    }
    return self;;
}


- (CABasicAnimation *)scaleAnimation {
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
     
    scaleAnimation.fromValue = @1;
    scaleAnimation.toValue = @(_multiple);
    scaleAnimation.beginTime = CACurrentMediaTime();
    scaleAnimation.duration = 1.7;
    scaleAnimation.repeatCount = INFINITY;
    return scaleAnimation;
}

- (void)drawRect:(CGRect)rect {
     
    CALayer *animationLayer = [CALayer layer];
     
    // 新建缩放动画
    CABasicAnimation *animation = [self scaleAnimation];
     
    // 新建一个动画 Layer，将动画添加上去
    CALayer *pulsingLayer = [self pulsingLayer:rect animation:animation];
     
    //将动画 Layer 添加到 animationLayer
    [animationLayer addSublayer:pulsingLayer];
     
    [self.layer addSublayer:animationLayer];
}


- (CALayer *)pulsingLayer:(CGRect)rect animation:(CABasicAnimation *)animation {
    CALayer *pulsingLayer = [CALayer layer];
     
    pulsingLayer.borderWidth = 1;
    pulsingLayer.borderColor = [UIColor.whiteColor colorWithAlphaComponent:0.3].CGColor;
    pulsingLayer.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    pulsingLayer.cornerRadius = rect.size.height / 2;
    [pulsingLayer addAnimation:animation forKey:@"plulsing"];
     
    return pulsingLayer;
}

@end
