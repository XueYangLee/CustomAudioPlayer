//
//  ViewController.m
//  CustomAudioPlayer
//
//  Created by Singularity on 2020/12/25.
//

#import "ViewController.h"
#import "CustomAudioPlayer.h"
#import "CustomRemoteCommand.h"
#import "PlayerControlView.h"

#import <FuncChains.h>
#import <Masonry.h>

@interface ViewController () <CustomAudioPlayerDelegate,PlayerControlViewDelegate>

@property (nonatomic,strong) PlayerControlView *controlView;

@end

@implementation ViewController

- (void)didMoveToParentViewController:(UIViewController *)parent{
    [super didMoveToParentViewController:parent];
    if(!parent){
        [[CustomAudioPlayer sharedAudio] stop];
        [CustomRemoteCommand removeCommandCenterTargets];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
}

//MARK: - UI
- (void)initUI{
    self.view.func_backgroundImage([UIImage imageNamed:@"coursePlay_back"]);
    

    _controlView=[PlayerControlView new];
    _controlView.delegate=self;
    [self.view addSubview:_controlView];
    
    [CustomAudioPlayer sharedAudio].delegate=self;
    [CustomRemoteCommand initRemoteCommandControlInfo];
    
    [CustomAudioPlayer sharedAudio].playURLString=@"https://resource.navoinfo.cn/Now/audio/course_4/20200803151339-5f27b923ba905.mp3";
    [[CustomAudioPlayer sharedAudio] play];
    
}

//MARK: controlView
- (void)sliderValueChanged:(CustomCircleSlider *)slider value:(float)value{
    [[CustomAudioPlayer sharedAudio] seekToProgress:value];
}

- (void)playBtnClick:(UIButton *)sender selected:(BOOL)selected{
    if (selected) {
        [[CustomAudioPlayer sharedAudio]resume];
        NSLog(@"play");
    }else{
        [[CustomAudioPlayer sharedAudio]pause];
        NSLog(@"pause");
    }
}

- (void)forwardQuarterSecClick{
    float sec = [CustomAudioPlayer sharedAudio].currentTime.playbackTimeInSeconds + 15;
    [[CustomAudioPlayer sharedAudio]seekToTimeInSeconds:sec];
}

- (void)backwardQuarterSecClick{
    float sec = [CustomAudioPlayer sharedAudio].currentTime.playbackTimeInSeconds - 15;
    [[CustomAudioPlayer sharedAudio]seekToTimeInSeconds:sec];
}


//MARK: audioPlayer
- (void)customAudioPlayer:(CustomAudioPlayer *)audioPlayer currentTimePosition:(FSStreamPosition)currentPosition durationPosition:(FSStreamPosition)durationPosition{
    
//    float currentTime=currentPosition.playbackTimeInSeconds;
//    float duration=durationPosition.playbackTimeInSeconds;
//    NSLog(@"%f>>>>%f>>>>",currentTime,duration);
    self.controlView.slider.value=currentPosition.position;
    
    self.controlView.currentTime.text=[NSString stringWithFormat:@"%02u:%02u",currentPosition.minute,currentPosition.second];
    self.controlView.totalTime.text=[NSString stringWithFormat:@"%02u:%02u",durationPosition.minute,durationPosition.second];
    [CustomRemoteCommand updateRemoteCommandPlayInfoWithContent:^(CustomRemoteContentModel * _Nonnull remoteContent) {
        remoteContent.title=@"title";
        remoteContent.albumTitle=@"albumTitle";
        remoteContent.artist=@"artist";
    }];
}

- (void)customAudioPlayer:(CustomAudioPlayer *)audioPlayer stateChange:(CustomAudioPlayerState)state{
//    NSLog(@"%lu>>>>>>",(unsigned long)state);
    [self.controlView stopLoading];
    
    if (state == AudioPlayerStateLoading) {
        [self.controlView startLoading];
    }else if (state == AudioPlayerStatePlaying){
        self.controlView.playBtn.selected=YES;
    }else if (state == AudioPlayerStatePaused){
        self.controlView.playBtn.selected=NO;
    }else if (state == AudioPlayerStateStopped || state == AudioPlayerStateError){
        self.controlView.playBtn.selected=NO;
    }else if (state == AudioPlayerStateCompleted){
        self.controlView.playBtn.selected=NO;
    }
}

- (void)customAudioPlayer:(CustomAudioPlayer *)audioPlayer bufferProgress:(float)bufferProgress{
//    NSLog(@"%f>>>buffer>>",bufferProgress);
    self.controlView.slider.bufferValue=bufferProgress;
}

- (void)customAudioPlayerDidPlayCompleted{
    [[CustomAudioPlayer sharedAudio] stop];
    
    NSLog(@"完成");
}



@end
