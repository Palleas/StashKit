//
//  STKClient.h
//  StashKit
//
//  Created by Romain Pouclet on 2014-03-21.
//  Copyright (c) 2014 Perfectly-Cooked. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;
@class STKUser;

@interface STKClient : NSObject

- (instancetype)initWithUser:(STKUser *)user;

- (RACSignal *)fetchProjects;
- (RACSignal *)createProject:(NSString *)name key:(NSString *)key description:(NSString *)description avatar:(NSData *)avatar;

- (RACSignal *)createRepository:(NSString *)name projectKey:(NSString *)key scmId:(NSString *)scmId forkable:(BOOL)forkable;

@end
