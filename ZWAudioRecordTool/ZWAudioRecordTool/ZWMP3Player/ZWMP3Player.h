//
//  ZWMP3Player.h
//  ZWAudioPlayer
//
//  Created by 流年划过颜夕 on 2018/10/15.
//  Copyright © 2018年 liunianhuaguoyanxi. All rights reserved.
//

#import <Foundation/Foundation.h>


@class ZWMP3Player;

@protocol ZWMP3PlayerDelegate <NSObject>
@optional
- (void)audioPlayerDidFinishPlaying:(ZWMP3Player*)player;
@end

@interface ZWMP3Player : NSObject

@property (unsafe_unretained, nonatomic) id <ZWMP3PlayerDelegate> delegate;

+ (NSString*)defaultCachePathWithURL:(NSString*)url;

- (instancetype)initWithDelegate:(id)delegate;

- (void)stopPlaying;

- (void)playAtURL:(NSString*)url;
- (void)playAtPath:(NSString*)path;
@end
