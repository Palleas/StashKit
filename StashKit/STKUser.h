//
//  STKUser.h
//  StashKit
//
//  Created by Romain Pouclet on 2014-03-21.
//  Copyright (c) 2014 Perfectly-Cooked. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STKUser : NSObject

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, strong) NSURL *endpoint;

- (instancetype)initWithUsername:(NSString *)name password:(NSString *)password endpoint:(NSURL *)url;

@end
