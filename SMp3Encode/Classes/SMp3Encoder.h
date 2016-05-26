//
//  SMp3Encoder.h
//  Sjw
//
//  Created by Sjw on 15/11/12.
//  Copyright © 2015年 Sjw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMp3Recorder.h"
#import "SMp3EncodeOperation.h"

@interface SMp3Encoder : NSObject
{
    SMp3Recorder *recorder;
    NSMutableArray *recordingQueue;
    SMp3EncodeOperation *mp3EncodeOperation;
    NSOperationQueue *opetaionQueue;
}

@property (nonatomic, weak) id<SMp3Delegate> delegate;

+(SMp3Encoder *)sharedInstance;
//文件绝对路径
@property (strong, nonatomic) NSString *strFilePath;
//开始录制
- (void)start;
//停止录制
- (void)stop:(BOOL)forceClose;

+ (NSTimeInterval)getDuration:(NSString *)strFilePath;

@end
