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

+(BOOL)convertWavToMp3:(NSString*)wavFilePath withSavePath:(NSString*)savePath
{
    BOOL flag = NO;
    @try {
        int read, write;
        
        FILE *pcm = fopen([wavFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024,SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([savePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        //这里的44100值和录音的字典中的AVSampleRateKey一样
        lame_set_in_samplerate(lame, 44100);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            fwrite(mp3_buffer, write, 1, mp3);
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
        
        flag = YES;
    }
    @catch (NSException *exception) {
        flag = NO;
    }
    @finally {

    }
    
    return flag;
    
}


@end


