//
//  CustomAudioPlayer.m
//  NowMeditation
//
//  Created by Singularity on 2020/11/5.
//

#import "CustomAudioPlayer.h"
#import "CustomAudioTimer.h"

@interface CustomAudioPlayer ()

/** 播放计时器 */
@property (nonatomic,strong) dispatch_source_t playTimer;

/** 缓冲计时器 */
@property (nonatomic,strong) dispatch_source_t bufferTimer;

@end

@implementation CustomAudioPlayer

+ (instancetype)sharedAudio {
    static CustomAudioPlayer *shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[CustomAudioPlayer alloc] init];
    });
    return shareManager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.playerState = AudioPlayerStateStopped;
        
        __weak typeof(self) weakSelf = self;
        
        //MARK: 播放状态改变
        self.player.onStateChange = ^(FSAudioStreamState state) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            if (state == kFsAudioStreamRetrievingURL) {//检索URL
                strongSelf.playerState = AudioPlayerStateLoading;
                
            }else if (state == kFsAudioStreamStopped){//停止
                strongSelf.playerState = AudioPlayerStateStopped;
                
            }else if (state == kFsAudioStreamBuffering){//缓冲中
                strongSelf.playerState = AudioPlayerStateBuffering;
                strongSelf.bufferState = AudioBufferStateBuffering;
                
            }else if (state == kFsAudioStreamPlaying){//播放
                strongSelf.playerState = AudioPlayerStatePlaying;
                
            }else if (state == kFsAudioStreamPaused){//暂停
                strongSelf.playerState = AudioPlayerStatePaused;
                
            }else if (state == kFsAudioStreamSeeking){//检索、跳转进度中
                strongSelf.playerState = AudioPlayerStateLoading;
                
            }else if (state == kFSAudioStreamEndOfFile){//缓冲结束
                strongSelf.playerState = AudioPlayerStateBufferFinished;
                if (strongSelf.bufferState != AudioBufferStateFinished) {
                    strongSelf.bufferState = AudioBufferStateFinished;
                    [CustomAudioTimer cancelTimer:strongSelf.bufferTimer];
                }
                
            }else if (state == kFsAudioStreamFailed){//播放失败
                strongSelf.playerState = AudioPlayerStateError;
                
            }else if (state == kFsAudioStreamRetryingStarted){//检索开始
                strongSelf.playerState = AudioPlayerStateLoading;
                
            }else if (state == kFsAudioStreamRetryingSucceeded){//检索成功
                strongSelf.playerState = AudioPlayerStateLoading;
                
            }else if (state == kFsAudioStreamRetryingFailed){//检索失败
                strongSelf.playerState = AudioPlayerStateError;
                
            }else if (state == kFsAudioStreamPlaybackCompleted){//播放完成
                strongSelf.playerState = AudioPlayerStateCompleted;
                
            }else if (state == kFsAudioStreamUnknownState){//未知状态
                strongSelf.playerState = AudioPlayerStateError;
            }
            
            if ([strongSelf.delegate respondsToSelector:@selector(customAudioPlayer:stateChange:)]) {
                [strongSelf.delegate customAudioPlayer:strongSelf stateChange:strongSelf.playerState];
            }
        };
        
        //MARK: 播放完成
        self.player.onCompletion = ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            if ([strongSelf.delegate respondsToSelector:@selector(customAudioPlayerDidPlayCompleted)]) {
                [strongSelf.delegate customAudioPlayerDidPlayCompleted];
            }
        };
        
        //MARK: 播放失败
        self.player.onFailure = ^(FSAudioStreamError error, NSString *errorDescription) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            if (error == kFsAudioStreamErrorNone) {//无错误
                strongSelf.errorState = AudioErrorStateNone;
                
            }else if (error == kFsAudioStreamErrorOpen){//无法打开系统
                strongSelf.errorState = AudioErrorStateOpen;
                
            }else if (error == kFsAudioStreamErrorStreamParse){//无法解析
                strongSelf.errorState = AudioErrorStateParse;
                
            }else if (error == kFsAudioStreamErrorNetwork){//网络错误
                strongSelf.errorState = AudioErrorStateNetwork;
                
            }else if (error == kFsAudioStreamErrorUnsupportedFormat){//不支持的格式
                strongSelf.errorState = AudioErrorStateUnsupportedFormat;
                
            }else if (error == kFsAudioStreamErrorStreamBouncing){//缓冲频繁 没有足够的数据流
                strongSelf.errorState = AudioErrorStateBouncing;
                
            }else if (error == kFsAudioStreamErrorTerminated){//被系统终止
                strongSelf.errorState = AudioErrorStateTerminated;
                
            }
            
            if ([strongSelf.delegate respondsToSelector:@selector(customAudioPlayer:error:errorMsg:)]) {
                [strongSelf.delegate customAudioPlayer:strongSelf error:strongSelf.errorState errorMsg:errorDescription];
            }
        };
    }
    return self;
}

//MARK: 加载播放网址
- (void)setPlayURLString:(NSString *)playURLString{
    if (![_playURLString isEqualToString:playURLString]) {
//        [self removeCache];
    }
    
    _playURLString = playURLString;
    
    NSURL *audioURL = [NSURL URLWithString:playURLString];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.player.url = audioURL;
    });
    
}

//MARK: 播放计时器
- (void)startPlayTimer{
    if (self.playTimer) {
        self.playTimer = nil;
    }
    
    self.listenedDuration = 0;
    
    __weak typeof(self) weakSelf = self;
    self.playTimer = [CustomAudioTimer timeCountStartWithInterval:1 handler:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf audioPlayTimerHandler];
    }];
}
//MARK: 缓冲计时器
- (void)startBufferTimer{
    if (self.bufferTimer) {
        self.bufferTimer = nil;
    }
    __weak typeof(self) weakSelf = self;
    self.bufferTimer = [CustomAudioTimer timeCountStartWithInterval:0.1 handler:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf audioBufferTimerHandler];
    }];
}

//MARK: 播放计时器计时事件
- (void)audioPlayTimerHandler{
    if (self.player.isPlaying) {
        self.listenedDuration ++;
    }
    
    if ([self.delegate respondsToSelector:@selector(customAudioPlayer:currentTimePosition:durationPosition:)]) {
        [self.delegate customAudioPlayer:self currentTimePosition:self.player.currentTimePlayed durationPosition:self.player.duration];
    }

}

//MARK: 缓冲计时器计时事件
- (void)audioBufferTimerHandler{
    float preBuffer      = (float)self.player.prebufferedByteCount;
    float contentLength  = (float)self.player.contentLength;
    
    // 这里获取的进度不能准确地获取到1
    float bufferProgress = (contentLength > 0) ? (preBuffer / contentLength) : 0;
    
    // 为了能使进度准确的到1，这里做了一些处理
    int buffer = (int)(bufferProgress + 0.5);
    
    if (bufferProgress > 0.9 && buffer >= 1) {
        self.bufferState = AudioBufferStateFinished;
        [CustomAudioTimer cancelTimer:self.bufferTimer];
        self.bufferTimer = nil;
        
        // 这里把进度设置为1，防止进度条出现不准确的情况
        bufferProgress = 1.0f;
//        DLog(@"缓冲结束了，停止进度");
    }else {
        self.bufferState = AudioBufferStateBuffering;
    }
    
    if ([self.delegate respondsToSelector:@selector(customAudioPlayer:bufferProgress:)]) {
        [self.delegate customAudioPlayer:self bufferProgress:bufferProgress];
    }
}


//MARK: 跳转进度到指定时间  秒
- (void)seekToTimeInSeconds:(float)timeInSeconds{
    if (timeInSeconds <= 0) {
        timeInSeconds = 1;
    }
    if (timeInSeconds > self.player.duration.playbackTimeInSeconds) {
        timeInSeconds = self.player.duration.playbackTimeInSeconds;
    }
    FSStreamPosition position = {0};
    unsigned u = timeInSeconds;
    unsigned s,m;

    s = u % 60;
    u /= 60;
    m = u;

    position.minute = m;
    position.second = s;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player seekToPosition:position];
    });
}

//MARK: 跳转进度  0-1
- (void)seekToProgress:(float)progress{
    if (progress == 0) {
        progress = 0.001;
    }
    if (progress == 1 || progress > 1.0) {
        progress = 0.999;
    }
    
    FSStreamPosition position = {0};
    position.position = progress;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player seekToPosition:position];
    });
}

//MARK: 从某个进度开始播放
- (void)playFromProgress:(float)progress{
    FSSeekByteOffset offset = {0};
    offset.position = progress;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player playFromOffset:offset];
    });
    
    [self startPlayTimer];
    if (self.bufferState != AudioBufferStateFinished) {//缓冲未完成
        self.bufferState = AudioBufferStateNone;
        [self startBufferTimer];
    }
}

//MARK: 设置播放速率  0.5-2.0  1.0为正常速率
- (void)setPlayRate:(float)playRate{
    if (playRate < 0.5) {
        playRate = 0.5f;
    }
    if (playRate > 2.0) {
        playRate = 2.0f;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player setPlayRate:playRate];
    });
}

//MARK: 设置播放声音
- (void)setPlayerVolume:(float)volume{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player setVolume:volume];
    });
}

//MARK: 是否播放中
- (BOOL)isPlaying{
    return self.player.isPlaying;
}

//MARK: 当前的时间
- (FSStreamPosition)currentTime{
    return self.player.currentTimePlayed;
}

//MARK: 总时长 
- (FSStreamPosition)duration{
    return self.player.duration;
}



//MARK: 播放
- (void)play{
    if (self.playerState == AudioPlayerStatePlaying) {
        return;
    }
    if (self.playerState == AudioPlayerStatePaused) {
        [self resume];
        return;
    }
    NSAssert(self.playURLString, @"URL不能为空");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player play];
    });
    
    [self startPlayTimer];
    if (self.bufferState != AudioBufferStateFinished) {//缓冲未完成
        self.bufferState = AudioBufferStateNone;
        [self startBufferTimer];
    }
}

//MARK: 暂停
- (void)pause{
    if (self.playerState == AudioPlayerStatePlaying) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.player pause];
        });
        [CustomAudioTimer suspendTimer:self.playTimer];
    }
}

//MARK: 恢复播放
- (void)resume{
    if (self.playerState == AudioPlayerStatePaused) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.player pause];
        });
        [CustomAudioTimer resumeTimer:self.playTimer];
    }
}

//MARK: 停止
- (void)stop{
    if (self.playerState == AudioPlayerStateStopped) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player stop];
    });
    [CustomAudioTimer cancelTimer:self.playTimer];
    self.playTimer = nil;
    self.listenedDuration = 0;
}

- (void)removeCache {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *arr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.player.configuration.cacheDirectory error:nil];
        
        for (NSString *filePath in arr) {
            if ([filePath hasPrefix:@"FSCache-"]) {
                NSString *path = [NSString stringWithFormat:@"%@/%@", self.player.configuration.cacheDirectory, filePath];
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            }
        }
    });
}


//MARK: 懒加载
- (FSAudioStream *)player{
    if (!_player) {
        FSStreamConfiguration *configuration = [FSStreamConfiguration new];
        configuration.enableTimeAndPitchConversion = YES;
        
        _player = [[FSAudioStream alloc] initWithConfiguration:configuration];
        _player.strictContentTypeChecking = NO;
        _player.defaultContentType = @"audio/x-m4a";
    }
    return _player;
}

@end
