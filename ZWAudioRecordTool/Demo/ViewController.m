//
//  ViewController.m
//  ZWAudioPlayer
//
//  Created by 流年划过颜夕 on 2018/10/15.
//  Copyright © 2018年 liunianhuaguoyanxi. All rights reserved.
//


#import "ZWTalkingRecordView.h"
#import "ZWAMRPlayer.h"
#import "ZWMP3Player.h"

#import "ViewController.h"
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
@interface ViewController ()<ZWTalkingRecordViewDelegate>

@property (weak,   nonatomic)   ZWTalkingRecordView *recordView;
@property (strong, nonatomic) ZWAMRPlayer * audioAmrPlayer;
@property (strong, nonatomic) ZWMP3Player * audioMP3Player;
@property (weak,   nonatomic)   UIButton  * btnStartPlay;
@property (weak,   nonatomic)   UILabel   * lab;
@property (assign, nonatomic)   ZWAudio     audioStyle;
@property (copy,   nonatomic)   NSString  *  path;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    ZWTalkingRecordView * recordView = [[ZWTalkingRecordView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 160) / 2, (self.view.frame.size.height - 160) / 2, 160, 160) delegate:self WithAudio:ZWAudioMP3];
    [self.view addSubview:recordView];
    self.recordView = recordView;
    
    UIButton * btnStartRecord = [UIButton buttonWithType:UIButtonTypeCustom];
    btnStartRecord.backgroundColor = [UIColor lightGrayColor];
    btnStartRecord.layer.cornerRadius = 5;
    btnStartRecord.layer.masksToBounds = YES;
    [btnStartRecord setTitle:@"按住说话" forState:UIControlStateNormal];
    [btnStartRecord setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnStartRecord.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnStartRecord addTarget:self action:@selector(btnStartRecordTouchDown:) forControlEvents:UIControlEventTouchDown];
    [btnStartRecord addTarget:self action:@selector(btnStartRecordMoveIn:) forControlEvents:UIControlEventTouchDragInside];
    [btnStartRecord addTarget:self action:@selector(btnStartRecordMoveOut:) forControlEvents:UIControlEventTouchDragOutside];
    [btnStartRecord addTarget:self action:@selector(btnStartRecordTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [btnStartRecord addTarget:self action:@selector(btnStartRecordTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    btnStartRecord.frame = CGRectMake((self.view.frame.size.width - 200)/2,self.view.frame.size.height - 60, 200, 40);
    [self.view addSubview:btnStartRecord];
    
    UIButton * btnStartPlay = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnStartPlay setImage:[UIImage imageNamed:@"播放"] forState:0];
    [btnStartPlay addTarget:self action:@selector(btnStartpPlayTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    btnStartPlay.frame = CGRectMake((self.view.frame.size.width - 60)/2,self.view.frame.size.height - 360, 60, 60);
    [self.view addSubview:btnStartPlay];
    btnStartPlay.hidden = YES;
    self.btnStartPlay = btnStartPlay;
}

- (void)btnStartRecordTouchDown:(id)sender {
    [self actionBarZWTalkStateChanged:ZWTalkStateTalking];
}
- (void)btnStartRecordMoveOut:(id)sender {
    [self actionBarZWTalkStateChanged:ZWTalkStateCanceling];
}
- (void)btnStartRecordMoveIn:(id)sender {
    [self actionBarZWTalkStateChanged:ZWTalkStateTalking];
}
- (void)btnStartRecordTouchUpInside:(id)sender {
    [self actionBarTalkFinished];
}
- (void)btnStartRecordTouchUpOutside:(id)sender {
    [self actionBarZWTalkStateChanged:ZWTalkStateNone];
}
- (void)actionBarZWTalkStateChanged:(ZWTalkState)sts {
    
    
    if (sts == ZWTalkStateTalking) {
        self.recordView.hidden = NO;
            self.btnStartPlay.hidden = YES;
    } else if (sts == ZWTalkStateCanceling) {
        self.recordView.hidden = NO;
    } else {
        self.recordView.hidden = YES;
        [_recordView recordCancel];
    }
    self.recordView.state = sts;
    
    self.lab.hidden = self.btnStartPlay.hidden;
}

- (void)actionBarTalkFinished {
    self.recordView.hidden = YES;
    [self.recordView recordEnd];
}

- (void)btnStartpPlayTouchUpInside:(id)sender
{
    if (self.audioStyle ==ZWAudioMP3) {
        self.audioMP3Player = [[ZWMP3Player alloc] initWithDelegate:self];
         [self.audioMP3Player  playAtPath:self.path];
    }else if(self.audioStyle ==ZWAudioAMR)
    {
        self.audioAmrPlayer = [[ZWAMRPlayer alloc] initWithDelegate:self];
        [self.audioAmrPlayer  playAMRAtPath:self.path];
    }
}
#pragma mark - TalkingRecordViewDelegate
- (void)recordView:(ZWTalkingRecordView *)sender didFinish:(NSString*)path duration:(NSTimeInterval)du WithAudio:(ZWAudio)Audio{
    NSLog(@"%@ didFinishPath \n",path );
    NSLog(@"%f duration",du);
    _recordView.hidden = YES;
    self.path = path;
    self.audioStyle = Audio;
    self.btnStartPlay.hidden = NO;
    if (!self.lab) {
        UILabel * lab = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 350)/2,self.view.frame.size.height - 290, 350, 30)];
        lab.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:lab];
        self.lab= lab;
    }
    if (Audio == ZWAudioMP3) {
        self.lab.text = [NSString stringWithFormat:@"MP3音频录制成功，时长%ld秒",(long)du];
    }else
    {
        self.lab.text = [NSString stringWithFormat:@"AMR音频录制成功，时长%ld秒",(long)du];
    }

}

- (UILabel*)linesText:(NSString*)text font:(UIFont*)font wid:(CGFloat)wid lines:(int)lines color:(UIColor*)color {
    CGFloat maxH = 0;
    if (lines > 0) {
        maxH = (font.pointSize + 2) * lines + 4;
    } else {
        maxH = 6000;
    }
    CGSize size = CGSizeMake(wid, maxH);
    
    NSMutableParagraphStyle * paragraph = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraph.alignment = NSTextAlignmentLeft;
    if (lines == 1) {
        paragraph.lineBreakMode = NSLineBreakByTruncatingTail;
    } else {
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    }
    NSDictionary * attr = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraph};
    size = [text length] > 0 ? [text boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin) attributes:attr context:nil].size : CGSizeZero;
    UILabel * lab = [[[self class] alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    lab.numberOfLines = lines;
    lab.backgroundColor = [UIColor clearColor];
    lab.lineBreakMode = NSLineBreakByTruncatingTail;
    lab.textAlignment = NSTextAlignmentLeft;
    lab.textColor = color;
    lab.font = font;
    lab.text = text;
    //    lab.highlightedTextColor = [UIColor whiteColor];
    return lab;
}

@end
