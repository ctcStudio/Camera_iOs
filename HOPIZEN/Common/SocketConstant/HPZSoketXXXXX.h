//
//  HPZSoketXXXXX.h
//  CameraDemo
//
//  Created by Thuy Do Thanh on 12/27/16.
//  Copyright © 2016 Thuy Do Thanh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HPZSoketXXXXX;

typedef NS_ENUM(NSInteger, MessageType) {
    LOGIN = 1,
    ONLINE = 2,
    LOGIN_REALTIME = 3,
    REALTIME = 4,
    LOGIN_GETDATA = 5,
    GETDATA = 6,
    VODDATA = 7
};

@protocol HPZSoketXXXXXDelegate <NSObject>

- (void)socketDidConnect;
- (void)messageReceived:(NSString *)message
            messageType:(MessageType) type;

@end

@interface HPZSoketXXXXX : NSObject

@property (nonatomic, strong) id <HPZSoketXXXXXDelegate> delegate;
@property (nonatomic, assign) MessageType type;

- (instancetype)initWithHost:(NSString *)ihost port:(int)iport;

- (void) close;


#pragma - mark send message

- (void) sendMessageToServer:(NSString *)mesage
                 messageType:(MessageType) type;

@end
