//
//  SMp3EncodeOperation.h
//  Sjw
//
//  Created by Sjw on 15/11/12.
//  Copyright © 2015年 Sjw. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SMp3Delegate <NSObject>

@optional
- (void)beginEncoder;
//mp3数据流
- (void)writeData:(unsigned char *)data Len:(NSInteger)length;
//
- (void)finishEncoder:(BOOL)success Duration:(NSInteger)duration;

@end

@interface SMp3EncodeOperation : NSOperation

@property (nonatomic, assign) BOOL setToStopped;
@property (nonatomic, weak) NSMutableArray *recordQueue;

@property (nonatomic, weak) id<SMp3Delegate> delegate;

@end
