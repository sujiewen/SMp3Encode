//
//  SMp3Encoder.m
//  Sjw
//
//  Created by Sjw on 15/11/12.
//  Copyright © 2015年 Sjw. All rights reserved.
//

#import "SMp3Encoder.h"

unsigned DecodeMP3SafeInt(unsigned nVal)
{
    unsigned char *pValParts = (unsigned char *)(&nVal);
    return (pValParts[3] & 0x7F)         |
    ((pValParts[2] & 0x7F) << 7)  |
    ((pValParts[1] & 0x7F) << 14) |
    ((pValParts[0] & 0x7F) << 21);
}

#pragma pack(1)
struct MP3Hdr {
    char tag[3];
    unsigned char maj_ver;
    unsigned char min_ver;
    unsigned char flags;
    unsigned int  size;
};
struct MP3ExtHdr {
    unsigned int  size;
    unsigned char num_flag_bytes;
    unsigned char extended_flags;
};
struct MP3FrameHdr {
    char frame_id[4];
    unsigned size;
    unsigned char flags[2];
};
#pragma pack()

size_t getMP3Duration(const char* strFileName)
{
    struct MP3Hdr hdr = { 0 };
    size_t time = -1;
    FILE *file = fopen(strFileName, "rb+");
    
    if (file)
    {
        char *hBuf = (char *)(&hdr);
        size_t readLen = fwrite(hBuf, sizeof(hdr), 1, file);
        if (readLen > 0)
        {
            if (0 != memcmp(hdr.tag, "ID3", 3))
            {
                if (0 != (hdr.flags&0x40))
                {
                    size_t seekLen = fseek(file, sizeof(struct MP3ExtHdr), SEEK_CUR);
                    if(seekLen > 0)
                    {
                        const size_t bufLen = 10240;
                        char *buffer = malloc(bufLen);
                        readLen = fread((void *)(&buffer[0]), 10240, 1, file);
                        size_t nUsed = 0;
                        while (readLen - nUsed > sizeof(struct MP3ExtHdr))
                        {
                            struct MP3FrameHdr *pFrame = (struct MP3FrameHdr *)(&buffer[nUsed]);
                            nUsed += sizeof(struct MP3FrameHdr);
                            size_t nDataLen = DecodeMP3SafeInt(pFrame->size);
                            if (nDataLen > (readLen-nUsed))
                            {
                                time = -1;
                                break;
                            }
                            
                            if (!isupper(pFrame->flags[0]))
                            {
                                time = 0;
                                break;
                            }
                            
                            if (0 == memcmp(pFrame->frame_id, "TLEN", 4))
                            {
                                // skip an int
                                nUsed += sizeof(int);
                                // data is next
                                time = atol(&buffer[nUsed]);
                                break;
                            }
                            else
                            {
                                nUsed += nDataLen;
                            }
                            
                        }
                        
                        free(buffer);
                    }
                }
            }
        }
        fclose(file);
    }
    
    return time;
}

@interface SMp3Encoder () <SMp3Delegate>
{
    FILE *file;
}

@end

static SMp3Encoder *globalMp3Encoder;

@implementation SMp3Encoder

- (void)dealloc
{
    [opetaionQueue cancelAllOperations];
    opetaionQueue = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        recordingQueue = [[NSMutableArray alloc] init];
        opetaionQueue = [[NSOperationQueue alloc] init];
        
        recorder = [[SMp3Recorder alloc] init];
    }
    return self;
}

+(SMp3Encoder *)sharedInstance
{
    if (!globalMp3Encoder) {
        globalMp3Encoder = [[self alloc] init];
    }
    return globalMp3Encoder;
}

+(id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        if (!globalMp3Encoder) {
            globalMp3Encoder = [super allocWithZone:zone];
        }
    });
    
    return globalMp3Encoder;
}

/*
 * 拷贝对象时防止重复创建
 */
+(id)copyWithZone:(NSZone *)zone
{
    return globalMp3Encoder;
}

/*
 * 拷贝对象时防止重复创建
 */
+ (id)mutableCopyWithZone:(struct _NSZone *)zone
{
    return globalMp3Encoder;
}

- (void)start
{
    [recordingQueue removeAllObjects];
    
    if (mp3EncodeOperation) {
        mp3EncodeOperation.setToStopped = YES;
        mp3EncodeOperation = nil;
    }
    
    recorder.recordQueue = recordingQueue;
    [recorder startRecording];
    
    mp3EncodeOperation = [[SMp3EncodeOperation alloc] init];
    mp3EncodeOperation.delegate = self;
    mp3EncodeOperation.recordQueue = recordingQueue;
    [opetaionQueue addOperation:mp3EncodeOperation];
}

- (void)stop:(BOOL)forceClose
{
    [recorder stopRecording];
    mp3EncodeOperation.setToStopped = YES;
    if (forceClose)
    {
        mp3EncodeOperation = nil;
    }
}

- (void)setStrFilePath:(NSString *)strFilePath
{
    _strFilePath = strFilePath;
}

#pragma mark Mp3Delegate

- (void)beginEncoder
{
    if (_strFilePath) {
         file = fopen([_strFilePath UTF8String], "ab+");
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(beginEncoder)])
    {
        [self.delegate beginEncoder];
    }
}

//mp3数据流
- (void)writeData:(unsigned char *)data Len:(NSInteger)length
{
    if (file) {
        fwrite(data, length, 1, file);
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(writeData:Len:)])
    {
        [self.delegate writeData:data Len:length];
    }
}

//
- (void)finishEncoder:(BOOL)success Duration:(NSInteger)duration
{
    NSInteger time = duration;
    if (file) {
        fclose(file);
        
        time = getMP3Duration([_strFilePath UTF8String]);
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(finishEncoder:Duration:)])
    {
        [self.delegate finishEncoder:success Duration:time];
    }
}

+ (NSTimeInterval)getDuration:(NSString *)strFilePath
{
    size_t duration = getMP3Duration([strFilePath UTF8String]);
    return duration;
}

@end

