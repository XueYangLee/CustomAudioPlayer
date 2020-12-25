//
//  CustomCircleSlider.h
//  NowMeditation
//
//  Created by 李雪阳 on 2020/11/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomCircleSlider : UIControl

/** 点击滑块响应 */
@property (nonatomic, copy) void(^sliderTouchDown)(CustomCircleSlider *slider);
/** 滑块滑动中 */
@property (nonatomic, copy) void(^sliderValueChanging)(CustomCircleSlider *slider, float value);
/** 滑块滑动结束 */
@property (nonatomic, copy) void(^sliderValueChanged)(CustomCircleSlider *slider, float value);


/** 设置滑块未滑动线条的颜色 */
@property (nullable, nonatomic, strong) UIColor *minimumTrackTintColor;
/** 设置滑块已滑动线条的颜色 */
@property (nullable, nonatomic, strong) UIColor *maximumTrackTintColor;
/** 设置滑块预加载滑动线条颜色 */
@property (nullable, nonatomic, strong) UIColor *bufferTrackTintColor;
/** 滑块的颜色 */
@property (nullable, nonatomic, strong) UIColor *thumbTintColor;

/** 圆的宽度 */
@property (nonatomic, assign) CGFloat sliderWidth;
/** 圆形进度条的半径，默认比view的宽高中最小者还要小24 */
@property (nonatomic, assign) CGFloat circleRadius;
/** 滑块的半径 */
@property (nonatomic, assign) CGFloat thumbRadius;
/** 滑块放大的半径 */
@property (nonatomic, assign) CGFloat thumbExpandRadius;

/** 判断点击在限定的区域为YES，否则为NO. */
@property (nonatomic, assign, readonly) BOOL interaction;
/** 是否可以重复拖动。默认为NO，即只能转到360；否则任意角度。 */
@property (nonatomic, assign) BOOL canRepeat;

/** slider当前的value */
@property (nonatomic, assign) float value;
/** slider预加载的进度 */
@property (nonatomic, assign) float bufferValue;

@end

NS_ASSUME_NONNULL_END
