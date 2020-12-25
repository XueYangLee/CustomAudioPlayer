//
//  PlayerControlView.m
//  CustomAudioPlayer
//
//  Created by Singularity on 2020/12/25.
//

#import "PlayerControlView.h"
#import "PlayerControlRippleView.h"
#import <FuncChains.h>
#import <Masonry.h>

@interface PlayerControlView ()

@property (nonatomic,strong) UIView *loadingView;

@property (nonatomic,strong) UIButton *forwardBtn;
@property (nonatomic,strong) UIButton *backwardBtn;

@end

#define UIImageName(imageName)  [UIImage imageNamed:imageName]

@implementation PlayerControlView

- (instancetype)init{
    self=[super init];
    if (self) {
        self.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WINDOW_HEIGHT);
        self.backgroundColor=UIColor.clearColor;
        
        [self initUI];
    }
    return self;
}

- (void)initUI{
    PlayerControlRippleView *ripple=[[PlayerControlRippleView alloc]initWithFrame:CGRectMake(0, 0, 185, 185)];
    [self addSubview:ripple];
    
    
    _slider=[CustomCircleSlider new];
    _slider.minimumTrackTintColor=[[UIColor whiteColor]colorWithAlphaComponent:0.23];
    _slider.maximumTrackTintColor=[UIColor greenColor];
    _slider.bufferTrackTintColor=[[UIColor lightGrayColor]colorWithAlphaComponent:0.5];
    _slider.thumbTintColor=[UIColor whiteColor];
    _slider.circleRadius=180/2;
    _slider.sliderWidth=6;
    _slider.thumbRadius=5;
    _slider.thumbExpandRadius=8;
    [self addSubview:_slider];
    [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(50);
        make.centerX.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH));
    }];
    
    
    [ripple mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(185, 185));
        make.centerY.mas_equalTo(self.slider.mas_centerY);
    }];
    
    __weak typeof(self) weakSelf = self;
    _slider.sliderValueChanged = ^(CustomCircleSlider * _Nonnull slider, float value) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(sliderValueChanged:value:)]) {
            [strongSelf.delegate sliderValueChanged:slider value:value];
        }
    };
    
    _playBtn=[UIButton new].func_image(UIImageName(@"coursePlay_play")).func_image_state(UIImageName(@"coursePlay_pause"),UIControlStateSelected).func_addTarget_action(self,@selector(playBtnClick:));
    [self addSubview:_playBtn];
    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(self.slider.mas_centerY).offset(-30);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    UILabel *timeSegment=[UILabel new].func_font([UIFont systemFontOfSize:14]).func_textColor(UIColor.whiteColor).func_text(@"/");
    [self addSubview:timeSegment];
    [timeSegment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(self.playBtn.mas_bottom).offset(20);
    }];
    
    _currentTime=[UILabel new].func_font([UIFont systemFontOfSize:14]).func_textColor(UIColor.whiteColor).func_text(@"00:00");
    [self addSubview:_currentTime];
    [_currentTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(timeSegment.mas_centerY);
        make.right.mas_equalTo(timeSegment.mas_left);
    }];
    
    _totalTime=[UILabel new].func_font([UIFont systemFontOfSize:14]).func_textColor(UIColor.whiteColor).func_text(@"00:00");
    [self addSubview:_totalTime];
    [_totalTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(timeSegment.mas_centerY);
        make.left.mas_equalTo(timeSegment.mas_right);
    }];
    
    
    
    _backwardBtn=[UIButton new].func_image(UIImageName(@"coursePlay_backward")).func_addTarget_action(self,@selector(towardBtnClick:));
    _backwardBtn.tag=21;
    [self addSubview:_backwardBtn];
    [_backwardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.slider.mas_bottom);
        make.right.mas_equalTo(self.mas_centerX).offset(-50);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    _forwardBtn=[UIButton new].func_image(UIImageName(@"coursePlay_forward")).func_addTarget_action(self,@selector(towardBtnClick:));
    _forwardBtn.tag=20;
    [self addSubview:_forwardBtn];
    [_forwardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.backwardBtn.mas_centerY);
        make.left.mas_equalTo(self.mas_centerX).offset(50);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
}


- (void)playBtnClick:(UIButton *)sender{
    sender.selected=!sender.selected;
    if ([self.delegate respondsToSelector:@selector(playBtnClick:selected:)]) {
        [self.delegate playBtnClick:sender selected:sender.selected];
    }
}

- (void)towardBtnClick:(UIButton *)sender{
    
    if (sender.tag==20) {
        if ([self.delegate respondsToSelector:@selector(forwardQuarterSecClick)]) {
            [self.delegate forwardQuarterSecClick];
        }

    }else{
        if ([self.delegate respondsToSelector:@selector(backwardQuarterSecClick)]) {
            [self.delegate backwardQuarterSecClick];
        }
    }
}


- (void)startLoading{
    self.playBtn.hidden=YES;
    
    [self addSubview:self.loadingView];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(self.slider.mas_centerY).offset(-30);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
}

- (void)stopLoading{
    self.playBtn.hidden=NO;
    [self.loadingView removeFromSuperview];
}

- (UIView *)loadingView{
    if (!_loadingView) {
        _loadingView=[UIView new].func_backgroundColor(UIColor.clearColor);
        CGRect frame = self.frame;
        frame.size = CGSizeMake(40, 40);
        _loadingView.frame=frame;
        
        UIBezierPath *beizPath=[UIBezierPath bezierPathWithArcCenter:CGPointMake(_loadingView.frame.size.width/2, _loadingView.frame.size.width/2) radius:10 startAngle:-M_PI_2 endAngle:M_PI_2 clockwise:YES];
        //先画一个圆
        CAShapeLayer *layer=[CAShapeLayer layer];
        layer.path=beizPath.CGPath;
        layer.fillColor=[UIColor clearColor].CGColor;//填充色
        layer.strokeColor=[UIColor whiteColor].CGColor;//边框颜色
        layer.lineWidth=3.0f;
        layer.lineCap=kCALineCapRound;//线框类型
        [_loadingView.layer addSublayer:layer];
        
        CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.fromValue=@(0);
        animation.toValue=@(M_PI*2);
        animation.duration=.6;
        animation.repeatCount=HUGE;//永久重复动画
        animation.fillMode=kCAFillModeForwards;
        animation.removedOnCompletion=NO;
        animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [_loadingView.layer addAnimation:animation forKey:@"animation"];
    }
    return _loadingView;
}

@end
