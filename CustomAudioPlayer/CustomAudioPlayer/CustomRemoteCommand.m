//
//  CustomRemoteCommand.m
//  NowMeditation
//
//  Created by Singularity on 2020/11/17.
//

#import "CustomRemoteCommand.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CustomAudioPlayer.h"

@implementation CustomRemoteCommand

+ (void)initRemoteCommandControlInfo{
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    
    // 锁屏播放
    [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        if (![CustomAudioPlayer sharedAudio].isPlaying) {
            [[CustomAudioPlayer sharedAudio] play];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    // 锁屏暂停
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        if ([CustomAudioPlayer sharedAudio].isPlaying) {
            [[CustomAudioPlayer sharedAudio] pause];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    // 拖动进度条
    [commandCenter.changePlaybackPositionCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        MPChangePlaybackPositionCommandEvent *positionEvent = (MPChangePlaybackPositionCommandEvent *)event;
        if (positionEvent == nil) {
            return MPRemoteCommandHandlerStatusCommandFailed;
        }
        NSTimeInterval positionTime = positionEvent.positionTime;
        [[CustomAudioPlayer sharedAudio]seekToTimeInSeconds:positionTime];
        
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    
    
    // 播放和暂停按钮（耳机控制）
    MPRemoteCommand *playPauseCommand = commandCenter.togglePlayPauseCommand;
    playPauseCommand.enabled = YES;
    [playPauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        
        if ([CustomAudioPlayer sharedAudio].isPlaying) {
            [[CustomAudioPlayer sharedAudio] pause];
        }else {
            [[CustomAudioPlayer sharedAudio] play];
        }
        
        return MPRemoteCommandHandlerStatusSuccess;
    }];
}

+ (void)updateRemoteCommandPlayInfoWithContent:(RemoteContent)remoteContent{
    MPNowPlayingInfoCenter *playingCenter = [MPNowPlayingInfoCenter defaultCenter];
    
    CustomRemoteContentModel *content = [CustomRemoteContentModel new];
    if (remoteContent) {
        remoteContent(content);
    }
    
    NSMutableDictionary *playingInfo = [NSMutableDictionary new];
    if (content.title) {
        [playingInfo setObject:content.title forKey:MPMediaItemPropertyTitle];//歌曲
    }
    if (content.artist) {
        [playingInfo setObject:content.artist forKey:MPMediaItemPropertyArtist];//歌手
    }
    if (content.albumTitle) {
        [playingInfo setObject:content.albumTitle forKey:MPMediaItemPropertyAlbumTitle];//专辑
    }
    
    [playingInfo setObject:[NSNumber numberWithFloat:[CustomAudioPlayer sharedAudio].currentTime.playbackTimeInSeconds] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];//已播放时长
    [playingInfo setObject:[NSNumber numberWithFloat:[CustomAudioPlayer sharedAudio].duration.playbackTimeInSeconds] forKey:MPMediaItemPropertyPlaybackDuration];//歌曲时长
    
    UIImage *image = [UIImage new];//可设置默认图片
    if (content.artwork) {
        image = content.artwork;
    }
    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:image.size requestHandler:^UIImage * _Nonnull(CGSize size) {
        return image;
    }];
    if (artwork) {
        [playingInfo setObject:artwork forKey:MPMediaItemPropertyArtwork];//封面
    }
    
    [playingCenter setNowPlayingInfo:playingInfo];
}



+ (void)removeCommandCenterTargets {
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    
    [commandCenter.playCommand removeTarget:self];
    [commandCenter.pauseCommand removeTarget:self];
    [commandCenter.togglePlayPauseCommand removeTarget:self];
    [commandCenter.changePlaybackPositionCommand removeTarget:self];
    
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

@end






@implementation CustomRemoteContentModel


@end
