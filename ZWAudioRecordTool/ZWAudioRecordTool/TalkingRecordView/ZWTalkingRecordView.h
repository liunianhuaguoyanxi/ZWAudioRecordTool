//
//  ZWTalkingRecordView.h
//  ZWAudioPlayer
//
//  Created by 流年划过颜夕 on 2018/10/15.
//  Copyright © 2018年 liunianhuaguoyanxi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum ZWTalkState {
    ZWTalkStateNone = 0,
    ZWTalkStateTalking = 1,
    ZWTalkStateCanceling = 2
}ZWTalkState;

typedef enum ZWAudio {
    ZWAudioMP3 = 0,
    ZWAudioAMR = 1,
}ZWAudio;

@class ZWTalkingRecordView;

@protocol ZWTalkingRecordViewDelegate <NSObject>
@optional
- (void)recordView:(ZWTalkingRecordView*)sender didFinish:(NSString*)path duration:(NSTimeInterval)du WithAudio:(ZWAudio)Audio;


@end

@interface ZWTalkingRecordView : UIView

@property (nonatomic, assign) id <ZWTalkingRecordViewDelegate> delegate;
@property (nonatomic, assign) int state;
@property (nonatomic, strong) NSString * audioFileSavePath;

- (id)initWithFrame:(CGRect)frame delegate:(id)delegate WithAudio:(ZWAudio )Audio ;
- (void)recordCancel;
- (void)recordEnd;
@end
