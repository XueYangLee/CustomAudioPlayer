//
//  CustomAudioTimer.h
//  CustomAudioPlayer
//
//  Created by Singularity on 2020/12/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomAudioTimer : NSObject

/**
 初始化计时器并开始   dispatch_source_t
 @param interval 计时时间间隔
 @param event_handle 时间操作
 */
+ (dispatch_source_t)timeCountStartWithInterval:(float)interval handler:(dispatch_block_t)event_handle;


/** 继续已暂停的定时器 */
+ (void)resumeTimer:(dispatch_source_t)timer;

/** 暂停计时器 */
+ (void)suspendTimer:(dispatch_source_t)timer;

/** 停止结束计时器 */
+ (void)cancelTimer:(dispatch_source_t)timer;

@end

NS_ASSUME_NONNULL_END
