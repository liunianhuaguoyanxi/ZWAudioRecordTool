//
//  ZWTalkingRecordView.m
//  ZWAudioPlayer
//
//  Created by 流年划过颜夕 on 2018/10/15.
//  Copyright © 2018年 liunianhuaguoyanxi. All rights reserved.
//

#import "ZWTalkingRecordView.h"

#import <AVFoundation/AVFoundation.h>
#import "ZWTalkingRecordView.h"
#import "AudioConverter.h"
#import "lame.h"

#define kChannels   1
#define kSampleRate 8000.0

@interface ZWTalkingRecordView () <AVAudioRecorderDelegate> {
    UIImageView * _iconView;
    
    UILabel     * _labText;
    
    NSTimeInterval _duration;
    
}
@property (nonatomic, strong) AVAudioRecorder * recorder;
@property (nonatomic, strong) NSString * audioTemporarySavePath;
@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, assign) BOOL recording;
@property (nonatomic, weak)  UIImageView * powerView;
@property (nonatomic, assign)  ZWAudio  Audio;
@end

@implementation ZWTalkingRecordView

- (id)initWithFrame:(CGRect)frame delegate:(id)delegate WithAudio:(ZWAudio )Audio{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = delegate;
        //        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.5];
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 0;
        self.layer.cornerRadius = 8;
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 120, 100)];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_iconView];
        UIImageView *powerView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 20, 30, 100)];
        [self addSubview:powerView];
        self.powerView = powerView;
        _labText = [[UILabel alloc] initWithFrame:CGRectMake(20, 125, 120, 20)];
        _labText.backgroundColor = [UIColor clearColor];
        _labText.font = [UIFont boldSystemFontOfSize:15];
        _labText.textColor = [UIColor whiteColor];
        _labText.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_labText];
        
        self.audioTemporarySavePath = [NSString stringWithFormat:@"%@/tmp/temporary.wav", NSHomeDirectory()];
        _recording = NO;
        self.Audio =Audio;
        self.hidden = YES;
    }
    return self;
}

- (void)dealloc {
    _iconView = nil;
    _labText = nil;
    self.timer = nil;
    self.recorder = nil;
    self.audioTemporarySavePath = nil;
    self.audioFileSavePath = nil;
}

- (void)setState:(int)sts {
    if (_state != sts) {
        if (sts == 1) {
            self.powerView.hidden = NO;
            _iconView.frame = CGRectMake(20, 20, 120, 100);
            _iconView.image = [UIImage imageNamed:@"talk_icon_recoder"];
            _labText.text = @"录制中...";
            if (!_recording) {
                [self recordStart];
            }
        } else if (sts == 2) {
            self.powerView.hidden = YES;
            _iconView.frame = CGRectMake(20, 50, 120, 40);
            _iconView.image = [UIImage imageNamed:@"talk_icon_recordCancel"];
            _labText.text = @"放开手指取消";
        } else {
            _iconView.image = nil;
        }
        _state = sts;
    }
}

- (void)recordStart {
    AVAudioSession * audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
    
    __weak __typeof(self) weakSelf = self;
    [self checkMicrophoneAuthorization:^{
        weakSelf.recording = YES;
        if (self.Audio == ZWAudioAMR) {
          weakSelf.audioFileSavePath = [NSString stringWithFormat:@"%@/tmp/%.0f.amr", NSHomeDirectory(), [NSDate timeIntervalSinceReferenceDate] * 1000];
        }else if (self.Audio == ZWAudioMP3)
        {
        weakSelf.audioFileSavePath = [NSString stringWithFormat:@"%@/tmp/%.0f.mp3", NSHomeDirectory(), [NSDate timeIntervalSinceReferenceDate] * 1000];
        }
        if (weakSelf.recorder == nil) {
            NSMutableDictionary *recSet = [[NSMutableDictionary alloc] init];
            [recSet setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];
            [recSet setValue :[NSNumber numberWithFloat:kSampleRate] forKey: AVSampleRateKey];//44100.0
            [recSet setValue :[NSNumber numberWithInt:kChannels] forKey: AVNumberOfChannelsKey];
            //[recSet setValue :[NSNumber numberWithInt:16] forKey: AVLinearPCMBitDepthKey];
            [recSet setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
#if TARGET_IPHONE_SIMULATOR
            NSURL * pathU = [NSURL fileURLWithPath:weakSelf.audioTemporarySavePath];
#elif TARGET_OS_IPHONE
            NSURL * pathU = [NSURL URLWithString:weakSelf.audioTemporarySavePath];
#endif
            
            AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:pathU settings:recSet error:nil];
            weakSelf.recorder = recorder;
        }
        weakSelf.recorder.delegate = self;
        weakSelf.recorder.meteringEnabled = YES;
        if ([weakSelf.recorder prepareToRecord]) {
            weakSelf.powerView.hidden = NO;
            [weakSelf.recorder record];
            [weakSelf.timer invalidate];
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.33 target:weakSelf selector:@selector(detectionVoice) userInfo:nil repeats:YES];
            weakSelf.timer = timer;
        }
    } withNoPermission:^(BOOL error) {
        if (error) {
            NSLog(@"无法录音");
        } else {
            NSLog(@"没有录音权限，请前往 “设置” - “隐私” - “麦克风” 为易维帮助台开启权限");
        }
    }];
}

- (void)recordCancel {
    self.powerView.hidden = YES;
    [self.timer invalidate];
    self.timer = nil;
    self.recording = NO;
    self.recorder.delegate = nil;
    [self.recorder stop];
    self.recorder = nil;
    self.state = 0;
}

- (void)recordEnd {
    _duration = self.recorder.currentTime;
    self.powerView.hidden = YES;
    [self.timer invalidate];
    self.timer = nil;
    self.recording = NO;
    [self.recorder stop];
    self.state = 0;
}

- (void)detectionVoice {
    [self.recorder updateMeters];//刷新音量数据
    double lowPassResults = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
    //    TCDemoLog(@"%lf",lowPassResults);
    //最大50  0
    //图片 小-》大
    if (lowPassResults <= 0.10) {
        [self.powerView setImage:[UIImage imageNamed:@"talk_sound_p1.png"]];
    } else if (lowPassResults <= 0.20) {
        [self.powerView setImage:[UIImage imageNamed:@"talk_sound_p2.png"]];
    } else if (lowPassResults <= 0.30) {
        [self.powerView setImage:[UIImage imageNamed:@"talk_sound_p3.png"]];
    } else if (lowPassResults <= 0.40) {
        [self.powerView setImage:[UIImage imageNamed:@"talk_sound_p4.png"]];
    } else if (lowPassResults <= 0.50) {
        [self.powerView setImage:[UIImage imageNamed:@"talk_sound_p5.png"]];
    } else if (lowPassResults <= 0.60) {
        [self.powerView setImage:[UIImage imageNamed:@"talk_sound_p6.png"]];
    } else {
        [self.powerView setImage:[UIImage imageNamed:@"talk_sound_p7.png"]];
    }
    
    if (self.recorder.currentTime >= 59.9) {
        _duration = self.recorder.currentTime;
        self.powerView.hidden = YES;
        [self.timer invalidate];
        self.timer = nil;
        self.recording = NO;
        [self.recorder stop];
        self.state = 0;
    }
}

- (void)checkMicrophoneAuthorization:(void (^)(void))permissionGranted withNoPermission:(void (^)(BOOL error))noPermission {
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (videoAuthStatus) {
        case AVAuthorizationStatusNotDetermined: {
            // 第一次提示用户授权
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                granted ? permissionGranted() : noPermission(NO);
            }];
            break;
        } case AVAuthorizationStatusAuthorized: {
            // 通过授权
            permissionGranted();
            break;
        } case AVAuthorizationStatusRestricted: {
            // 不能授权
            noPermission(YES);
        } case AVAuthorizationStatusDenied: {
            // 提示跳转到相机设置(这里使用了blockits的弹窗方法）
            noPermission(NO);
        }
            break;
        default:
            break;
    }
}

#pragma mark
#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)sender successfully:(BOOL)flag {
    if (flag) {
        [self audioConvert];
        if ([self.delegate respondsToSelector:@selector(recordView:didFinish:duration:WithAudio:)]) {
            NSLog(@"%f,_duration",_duration);
            [self.delegate recordView:self didFinish:self.audioFileSavePath duration:_duration WithAudio:self.Audio];
        }
        self.recorder.delegate = nil;
        self.recorder = nil;
    }
}

#pragma mark
#pragma mark - audioConvert

- (void)audioConvert {
    NSString * audioFileSavePath = self.audioFileSavePath;
    if (self.Audio ==ZWAudioAMR) {
        
        [AudioConverter wavToAmr:self.audioTemporarySavePath amrSavePath:audioFileSavePath];
        
    }else
    {
        @try {
            int read, write;
            
            FILE *pcm = fopen([self.audioTemporarySavePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
            fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header 跳过 PCM header 能保证录音的开头没有噪音
            FILE *mp3 = fopen([audioFileSavePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
            
            const int PCM_SIZE = 8192;
            const int MP3_SIZE = 8192;
            short int pcm_buffer[PCM_SIZE*kChannels];
            unsigned char mp3_buffer[MP3_SIZE];
            
            lame_t lame = lame_init();
            lame_set_in_samplerate(lame, kSampleRate);
            lame_set_num_channels(lame,kChannels);//设置1为单通道，默认为2双通道
            lame_set_mode(lame, MONO);
            lame_set_brate(lame, 16);
            lame_set_VBR(lame, vbr_default);
            lame_init_params(lame);
            
            do {
                read = (int)fread(pcm_buffer, kChannels*sizeof(short int), PCM_SIZE, pcm);
                if (read == 0)
                    write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
                else
                    if (kChannels == 1) {
                        write = lame_encode_buffer(lame, pcm_buffer, nil, read, mp3_buffer, MP3_SIZE);
                    } else if (kChannels == 2) {
                        write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                    }
                
                fwrite(mp3_buffer, write, 1, mp3);
                
            } while (read != 0);
            
            lame_close(lame);
            fclose(mp3);
            fclose(pcm);
        }
        @catch (NSException *exception) {
            NSLog(@"%@", [exception description]);
            self.audioFileSavePath = nil;
        }
        @finally {
            NSLog(@"MP3 file generated successfully: %@",self.audioFileSavePath);
        }
 
    }
}
@end
