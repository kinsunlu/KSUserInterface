//
//  KSVideoPlayerLiteView.h
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/10.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSVideoLayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSVideoPlayerLiteView : UIControl

@property (nonatomic, assign, readonly, getter=isPlaying) BOOL playing;
@property (nonatomic, weak, readonly) UIImageView *coverView;
@property (nonatomic, weak, readonly) UIButton *playButton;
@property (nonatomic, assign) KSVideoLayerGravity videoGravity;
@property (nonatomic) float volume;

@property (nonatomic, copy) void (^videoPlaybackFinished)(void);

@property (nonatomic, strong) AVPlayerItem *playerItem;

- (void)settingToolsViewHidden:(BOOL)hidden;

- (void)play;
- (void)pause;

@end

NS_ASSUME_NONNULL_END
