//
//  ZWAMRPlayer.m
//  ZWAudioPlayer
//
//  Created by 流年划过颜夕 on 2018/10/15.
//  Copyright © 2018年 liunianhuaguoyanxi. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ZWAMRPlayer.h"
#import "AudioConverter.h"
@interface ZWAMRPlayer () <AVAudioPlayerDelegate>

@property (copy, nonatomic) NSString * localPath;
@property (strong, nonatomic) AVAudioPlayer * currentPlayer;

@end

@implementation ZWAMRPlayer

+ (NSString*)defaultCachePathWithURL:(NSString*)url {
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString * new_path_b = paths[0];
    NSString * new_path_a = [new_path_b stringByAppendingPathComponent:@"AudioCaches"];
    NSString * localPath = [new_path_a stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.amr", url]];
    return localPath;
}

- (instancetype)initWithDelegate:(id)delegate {
    if (self = [super init]) {
        // Initialization Code
        self.delegate = delegate;
    }
    return self;
}

- (void)stopPlaying {
    if (self.currentPlayer) {
        self.currentPlayer.delegate = nil;
        [self.currentPlayer stop];
        self.currentPlayer = nil;
    }
}

- (void)playAMRAtURL:(NSString*)url {
    NSFileManager * fMan = [NSFileManager defaultManager];
    NSString * localPath = [ZWAMRPlayer defaultCachePathWithURL:url];
    self.localPath = localPath;
    if (![fMan fileExistsAtPath:localPath]) {
//        NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
//        [request setValue:[EHEngine engine].loginValue forHTTPHeaderField:[EHEngine engine].loginKey];
//        request.timeoutInterval = 10;
//        NSError * error = nil;
//        NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
//        [data writeToFile:localPath atomically:YES];
    }
    [self playAMRAtPath:localPath];
}

- (void)playAMRAtPath:(NSString*)path {
    AVAudioSession * audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
    if (self.currentPlayer) {
        self.currentPlayer.delegate = nil;
        [self.currentPlayer stop];
        self.currentPlayer = nil;
    }
    NSData * data = [NSData dataWithContentsOfFile:path];
    [self playData:[AudioConverter getWAVEDataFrom:data]];
}

- (void)playData:(NSData*)data {
    NSError * error = nil;
    AVAudioPlayer * player = [[AVAudioPlayer alloc] initWithData:data error:&error];
    if (error) {
        if ([_delegate respondsToSelector:@selector(amrPlayerDidFinishPlaying:)]) {
            [_delegate amrPlayerDidFinishPlaying:self];
        }
        return;
    }
    player.delegate = self;
    [player prepareToPlay];
    [player play];
    self.currentPlayer = player;
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [player stop];
    self.currentPlayer = nil;
    if ([_delegate respondsToSelector:@selector(amrPlayerDidFinishPlaying:)]) {
        [_delegate amrPlayerDidFinishPlaying:self];
    }
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    [player stop];
    if ([_delegate respondsToSelector:@selector(amrPlayerDidFinishPlaying:)]) {
        [_delegate amrPlayerDidFinishPlaying:self];
    }
}
@end
