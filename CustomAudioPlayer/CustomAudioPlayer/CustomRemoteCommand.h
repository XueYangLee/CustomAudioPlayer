//
//  CustomRemoteCommand.h
//  NowMeditation
//
//  Created by Singularity on 2020/11/17.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CustomRemoteContentModel;

typedef void(^RemoteContent)(CustomRemoteContentModel *remoteContent);

@interface CustomRemoteCommand : NSObject

/** 初始化后台远程控制界面 */
+ (void)initRemoteCommandControlInfo;

/** 更新后台控制界面 */
+ (void)updateRemoteCommandPlayInfoWithContent:(RemoteContent)remoteContent;

/** 退出移除后台控制界面 */
+ (void)removeCommandCenterTargets;

@end



@interface CustomRemoteContentModel : NSObject

/** 歌曲 */
@property (nonatomic,copy) NSString *title;
/** 歌手 */
@property (nonatomic,copy) NSString *artist;
/** 专辑 */
@property (nonatomic,copy) NSString *albumTitle;
/** 封面图 */
@property (nonatomic,strong) UIImage *artwork;

@end

NS_ASSUME_NONNULL_END
