//
//  ZWAMRPlayer.h
//  ZWAudioPlayer
//
//  Created by 流年划过颜夕 on 2018/10/15.
//  Copyright © 2018年 liunianhuaguoyanxi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZWAMRPlayer;

@protocol ZWAMRPlayerDelegate <NSObject>
@optional
- (void)amrPlayerDidFinishPlaying:(ZWAMRPlayer*)player;
@end

@interface ZWAMRPlayer : NSObject

@property (weak, nonatomic) id <ZWAMRPlayerDelegate> delegate;

+ (NSString*)defaultCachePathWithURL:(NSString*)url;

- (instancetype)initWithDelegate:(id)delegate;

- (void)stopPlaying;

- (void)playAMRAtURL:(NSString*)url;
- (void)playAMRAtPath:(NSString*)path;
@end
