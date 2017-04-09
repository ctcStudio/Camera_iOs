//
//  HPZSoketXXXXX.m
//  CameraDemo
//
//  Created by Thuy Do Thanh on 12/27/16.
//  Copyright © 2016 Thuy Do Thanh. All rights reserved.
//

#import "HPZSoketXXXXX.h"


@interface HPZSoketXXXXX () <NSStreamDelegate> {
    
    @public NSInputStream	*inputStream;
    @public NSOutputStream	*outputStream;
    
    NSString *host;
    int port;
}

@end


@implementation HPZSoketXXXXX



- (instancetype)initWithHost:(NSString *)ihost port:(int)iport{
    self = [super init];
    if (self) {
        host = ihost;
        port = iport;
        [self initNetworkCommunication];
    }
    return self;
}

- (void) initNetworkCommunication {
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)host, port, &readStream, &writeStream);
    
    inputStream = (NSInputStream *)readStream;
    outputStream = (NSOutputStream *)writeStream;
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
    
}



- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
    NSLog(@"stream event %i", (int)streamEvent);
    
    switch (streamEvent) {
            
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened");
            if (theStream == inputStream) {
                if ([self.delegate respondsToSelector:@selector(socketDidConnect)]) {
                    [self.delegate socketDidConnect];
                }
            }
            break;
        case NSStreamEventHasBytesAvailable:
            
            if (theStream == inputStream) {
                
                uint8_t buffer[4096];
                int len;
                
                while ([inputStream hasBytesAvailable]) {
                    len = (int)[inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        NSData* data = [NSData dataWithBytes:buffer length:len];
                        
                        if (nil != output || nil != data) {
                            NSLog(@"server said: %@", output);
                            if(self.type == REALTIME
                               || self.type == VODDATA) {
                                if ([self.delegate respondsToSelector:@selector(messageReceivedData:messageType:)]) {
                                    [self.delegate messageReceivedData:data messageType:self.type];
                                } else if ([self.delegate respondsToSelector:@selector(messageReceived:messageType:)]) {
                                    [self.delegate messageReceived:output messageType:self.type];
                                }
                            } else {
                                if ([self.delegate respondsToSelector:@selector(messageReceived:messageType:)]) {
                                    [self.delegate messageReceived:output messageType:self.type];
                                } else if ([self.delegate respondsToSelector:@selector(messageReceivedData:messageType:)]) {
                                    [self.delegate messageReceivedData:data messageType:self.type];
                                }
                            }
                        }
                    }
                }
            }
            break;
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"NSStreamEventHasSpaceAvailable");
            break;
            
        case NSStreamEventErrorOccurred:
            
            NSLog(@"Can not connect to the host!");
            break;
            
        case NSStreamEventEndEncountered:
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [theStream release];
            theStream = nil;
            
            break;
        default:
            NSLog(@"Unknown event");
    }
}

- (void)sendMessageToServer:(NSString *)mesage
                messageType:(MessageType) type{
    NSLog(@"message send:%@",mesage);
    self.type = type;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSData *data = [[NSData alloc] initWithData:[mesage dataUsingEncoding:NSASCIIStringEncoding]];
        [outputStream write:[data bytes] maxLength:[data length]];
    });
    
}


- (void) sendDataToServer:(NSData *)data
              messageType:(MessageType) type {
    NSLog(@"message send:%@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    self.type = type;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [outputStream write:[data bytes] maxLength:[data length]];
    });
}

- (void) close {
    [inputStream close];
    [outputStream close];
}

- (void)dealloc {
    [inputStream release];
    [outputStream release];
    self.delegate = nil;
    [super dealloc];
    
}
@end
