//
//  SMp3EncodeOperation.m
//  Sjw
//
//  Created by Sjw on 15/11/12.
//  Copyright © 2015年 Sjw. All rights reserved.
//

#import "SMp3EncodeOperation.h"
#import "lame.h"
#import <AVFoundation/AVFoundation.h>

// 全局指针
lame_t lame;

@implementation SMp3EncodeOperation

- (void)main
{
    // mp3压缩参数
    lame = lame_init();
    //通道
    lame_set_num_channels(lame, 1);
    //采样率
    lame_set_in_samplerate(lame, 16000);
    //位速率
    lame_set_brate(lame, 16);
    
    lame_set_mode(lame, 1);
    //音频质量
    lame_set_quality(lame, 2);
    
//    id3tag_init(lame);
//    id3tag_add_v2(lame);
//    id3tag_space_v1(lame);
//    id3tag_pad_v2(lame);
//    id3tag_set_artist(lame,"");
//    id3tag_set_album(lame,"");
//    id3tag_set_title(lame,"");
//    id3tag_set_track(lame,"0");
//    id3tag_set_year(lame,"");
      id3tag_set_comment(lame,"sjw");
//    id3tag_set_genre(lame,"");

    lame_init_params(lame);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(beginEncoder)]) {
            [self.delegate beginEncoder];
        }
    });
    
    while (true) {
        
        NSData *audioData = nil;
        @synchronized(_recordQueue){
            
            if (_recordQueue.count > 0) {
                // 获取队头数据
                audioData = [_recordQueue objectAtIndex:0];
                [_recordQueue removeObjectAtIndex:0];
            }
        }
        
        if (audioData != nil) {
            
            short *recordingData = (short *)audioData.bytes;
            int pcmLen = (int)audioData.length;
            int nsamples = pcmLen / 2;
            
            unsigned char buffer[pcmLen];
            // mp3 encode
            int recvLen = lame_encode_buffer(lame, recordingData, recordingData, (int)nsamples, buffer, pcmLen);
            if (self.delegate && [self.delegate respondsToSelector:@selector(writeData:Len:)])
            {
                [self.delegate writeData:buffer Len:recvLen];
            }
            
        }else{
            if (_setToStopped) {
                break;
            }else{
                [NSThread sleepForTimeInterval:0.25];
            }
        }
    }
    
    lame_close(lame);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(finishEncoder:Duration:)]) {
            [self.delegate finishEncoder:YES Duration:0];
        }
    });
}

@end


