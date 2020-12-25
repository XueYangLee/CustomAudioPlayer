## CustomAudioPlayer
基于 ` FreeStreamer`实现的纯音频播放控制器

#### 使用方法
拖动 ` CustomAudioPlayer` 文件夹至你的项目

- 音频调用方法
```
[CustomAudioPlayer sharedAudio].playURLString=@"音频播放地址";
[[CustomAudioPlayer sharedAudio] play];
```

- 音频代理监听方法
```
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
```

- 后台远程控制器实现方法
```
[CustomRemoteCommand initRemoteCommandControlInfo];
```

- 后台远程控制器页面更新方法
```
[CustomRemoteCommand updateRemoteCommandPlayInfoWithContent:^(CustomRemoteContentModel * _Nonnull remoteContent) {
    remoteContent.title=@"歌曲名";
    remoteContent.albumTitle=@"歌手名";
    remoteContent.artist=@"专辑";
    remoteContent.artwork=[UIImage imageNamed:@"封面图"];
}];
```
