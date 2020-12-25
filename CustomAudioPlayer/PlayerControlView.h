//
//  PlayerControlView.h
//  CustomAudioPlayer
//
//  Created by Singularity on 2020/12/25.
//

#import <UIKit/UIKit.h>
#import "CustomCircleSlider.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define NAVI_HEIGHT 44
#define STATUS_HEIGHT [[UIApplication sharedApplication] statusBarFrame].size.height
#define SCREEN_WINDOW_HEIGHT (SCREEN_HEIGHT-(STATUS_HEIGHT+NAVI_HEIGHT))

NS_ASSUME_NONNULL_BEGIN

@protocol PlayerControlViewDelegate <NSObject>

- (void)sliderValueChanged:(CustomCircleSlider *)slider value:(float)value;

- (void)playBtnClick:(UIButton *)sender selected:(BOOL)selected;

- (void)forwardQuarterSecClick;

- (void)backwardQuarterSecClick;

@end

@interface PlayerControlView : UIView

@property (nonatomic,weak) id<PlayerControlViewDelegate>delegate;

@property (nonatomic,strong) CustomCircleSlider *slider;

@property (nonatomic,strong) UIButton *playBtn;

@property (nonatomic,strong) UILabel *currentTime;
@property (nonatomic,strong) UILabel *totalTime;


- (void)startLoading;

- (void)stopLoading;

@end

NS_ASSUME_NONNULL_END
