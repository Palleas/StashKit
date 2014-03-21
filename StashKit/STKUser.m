//
//  STKUser.m
//  StashKit
//
//  Created by Romain Pouclet on 2014-03-21.
//  Copyright (c) 2014 Perfectly-Cooked. All rights reserved.
//

#import "STKUser.h"

@implementation STKUser

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password baseUrl:(NSURL *)baseUrl {
    self = [super init];
    if (self) {
        self.username = username;
        self.password = password;
        self.baseUrl = baseUrl;
    }
    
    return self;
}

- (NSString *)HTTPBasicAuthorizationHeaderValue {
    NSData *credentials = [[[NSString stringWithFormat: @"%@:%@", self.username, self.password] dataUsingEncoding: NSUTF8StringEncoding] base64EncodedDataWithOptions: 0];
    
    return [NSString stringWithFormat: @"Basic %@", [[NSString alloc] initWithData: credentials encoding: NSUTF8StringEncoding]];
}
            
@end
