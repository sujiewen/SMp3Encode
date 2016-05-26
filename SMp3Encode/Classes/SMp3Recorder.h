//
//  SMp3Recorder.h
//  Sjw
//
//  Created by Sjw on 15/11/12.
//  Copyright © 2015年 ekangtong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#define kNumberAudioQueueBuffers 3
#define kBufferDurationSeconds 0.1f


@interface SMp3Recorder : NSObject
{
    AudioQueueRef				_audioQueue;
    AudioQueueBufferRef			_audioBuffers[kNumberAudioQueueBuffers];
    AudioStreamBasicDescription	_recordFormat;
    
}

@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) NSMutableArray *recordQueue;

- (void) startRecording;
- (void) stopRecording;

@end
