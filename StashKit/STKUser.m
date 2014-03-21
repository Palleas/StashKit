//
//  STKUser.m
//  StashKit
//
//  Created by Romain Pouclet on 2014-03-21.
//  Copyright (c) 2014 Perfectly-Cooked. All rights reserved.
//

#import "STKUser.h"

@implementation STKUser

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password endpoint:(NSURL *)endpoint {
    self = [super init];
    if (self) {
        self.username = username;
        self.password = password;
        self.endpoint = endpoint;
    }
    
    return self;
}

@end
