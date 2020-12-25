//
//  CustomAudioPlayer.h
//  NowMeditation
//
//  Created by Singularity on 2020/11/5.
//

#import <Foundation/Foundation.h>
#import <FreeStreamer/FSAudioStream.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CustomAudioPlayerState) {
    /** 加载中 */
    AudioPlayerStateLoading,
    /** 缓冲中 */
    AudioPlayerStateBuffering,
    /** 缓冲完成 */
    AudioPlayerStateBufferFinished,
    /** 播放 */
    AudioPlayerStatePlaying,
    /** 暂停 */
    AudioPlayerStatePaused,
    /** 停止（播放器主动发出：如播放被打断） */
    AudioPlayerStateStopped,
    /** 播放完成（结束） */
    AudioPlayerStateCompleted,
    /** 错误（未知） */
    AudioPlayerStateError,
};

typedef NS_ENUM(NSUInteger, CustomAudioBufferState) {
    /** 无缓冲 */
    AudioBufferStateNone,
    /** 缓冲中 */
    AudioBufferStateBuffering,
    /** 缓冲结束 */
    AudioBufferStateFinished
};

typedef NS_ENUM(NSUInteger, CustomAudioErrorState) {
    /** 无错误 */
    AudioErrorStateNone,
    /** 无法打开系统 */
    AudioErrorStateOpen,
    /** 无法解析 */
    AudioErrorStateParse,
    /** 网络错误 */
    AudioErrorStateNetwork,
    /** 不支持的格式 */
    AudioErrorStateUnsupportedFormat,
    /** 缓冲频繁 没有足够的数据流 */
    AudioErrorStateBouncing,
    /** 被系统终止 */
    AudioErrorStateTerminated,
};

@class CustomAudioPlayer;

@protocol CustomAudioPlayerDelegate <NSObject>

@optional
/** 播放状态改变 */
- (void)customAudioPlayer:(CustomAudioPlayer *)audioPlayer stateChange:(CustomAudioPlayerState)state;

/** 播放完成 */
- (void)customAudioPlayerDidPlayCompleted;

/** 播放失败 */
- (void)customAudioPlayer:(CustomAudioPlayer *)audioPlayer error:(CustomAudioErrorState)errorState errorMsg:(NSString *)errorMsg;


/** 播放时长位置信息   position.playbackTimeInSeconds->时长秒数  position.position->进度位置  position.second->当前的秒数   position.minute->当前的分钟数 */
- (void)customAudioPlayer:(CustomAudioPlayer *)audioPlayer currentTimePosition:(FSStreamPosition)currentPosition durationPosition:(FSStreamPosition)durationPosition;

/** 缓冲进度 */
- (void)customAudioPlayer:(CustomAudioPlayer *)audioPlayer bufferProgress:(float)bufferProgress;

@end


@interface CustomAudioPlayer : NSObject

/** 播放器对象单例 */
+ (instancetype)sharedAudio;

/** 代理 */
@property (nonatomic,weak) id <CustomAudioPlayerDelegate> delegate;

/** FSAudioStream 播放器 */
@property (nonatomic,strong) FSAudioStream *player;

/** 音频源网络地址 */
@property (nonatomic,copy) NSString *playURLString;


/** 播放状态 */
@property (nonatomic,assign) CustomAudioPlayerState playerState;

/** 缓冲状态 */
@property (nonatomic,assign) CustomAudioBufferState bufferState;

/** 错误状态 */
@property (nonatomic,assign) CustomAudioErrorState errorState;


/** 移除缓存 */
- (void)removeCache;


/** 跳转进度到指定时间  秒 */
- (void)seekToTimeInSeconds:(float)timeInSeconds;

/** 跳转进度  0-1 */
- (void)seekToProgress:(float)progress;

/** 从某个进度开始播放 */
- (void)playFromProgress:(float)progress;

/** 设置播放速率  0.5-2.0  1.0为正常速率  */
- (void)setPlayRate:(float)playRate;

/** 设置播放声音   0-1 */
- (void)setPlayerVolume:(float)volume;


/** 是否处于播放中 */
- (BOOL)isPlaying;

/** 当前的时间 position.playbackTimeInSeconds->时长秒数  position.position->进度位置  position.second->秒数位   position.minute->分钟数位*/
- (FSStreamPosition)currentTime;

/** 总时长 position.playbackTimeInSeconds->时长秒数  position.position->进度位置  position.second->秒数位   position.minute->分钟数位*/
- (FSStreamPosition)duration;

/** 实际听过的时长 */
@property (nonatomic,assign) NSTimeInterval listenedDuration;

/** 播放 */
- (void)play;

/** 暂停 */
- (void)pause;

/** 恢复播放 （暂停后再次播放使用） */
- (void)resume;

/** 停止播放 */
- (void)stop;


@end

NS_ASSUME_NONNULL_END
