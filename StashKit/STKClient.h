//
//  STKClient.h
//  StashKit
//
//  Created by Romain Pouclet on 2014-03-21.
//  Copyright (c) 2014 Perfectly-Cooked. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const STKClientErrorDomain;

typedef NS_ENUM(NSUInteger, STKClientErrorCode) {
    STKClientErrorCodeConflict = 1,
    STKClientErrorCodeUnexpectedResponse
};

@class RACSignal;
@class STKUser;

@interface STKClient : NSObject

- (instancetype)initWithUsername:(NSString *)name password:(NSString *)password baseUrl:(NSURL *)url;

// Fetch the projects the authenticated user has access to
//
// Returns a signal which sends zero or more STKProject objects.
- (RACSignal *)fetchProjects;

// Create a project with a given name, key, description and avatar
//
// Returns a signal which sends zero or more STKProject objects.
- (RACSignal *)createProject:(NSString *)name key:(NSString *)key description:(NSString *)description avatar:(NSData *)avatar;

// Create a repository with a given name for a given project
//
// Returns a signal which sends zero or more STKProject objects.
- (RACSignal *)createRepository:(NSString *)name projectKey:(NSString *)key forkable:(BOOL)forkable;

// Returns URL request for next batch of results
- (NSURLRequest *)createNextPageRequest:(NSURLRequest *)request nextStart:(NSNumber *)nextStart;

@end
