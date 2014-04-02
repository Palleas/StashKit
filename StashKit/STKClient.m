//
//  STKClient.m
//  StashKit
//
//  Created by Romain Pouclet on 2014-03-21.
//  Copyright (c) 2014 Perfectly-Cooked. All rights reserved.
//

NSString * const STKClientAPIEndPoint = @"/rest/api/1.0/";
NSString * const STKClientResponseValuesKey = @"values";

#import "STKClient.h"
#import "STKUser.h"
#import "STKProject.h"
#import "STKRepository.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Mantle/Mantle.h>

@interface STKClient ()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) STKUser *user;

@end

@implementation STKClient

- (id)initWithUser:(STKUser *)user {
    self = [super init];
    if (self) {
        self.user = user;
        self.session = [NSURLSession sharedSession]; // FIXME
    }
    
    return self;
}

- (RACSignal *)enqueueRequest:(NSURLRequest *)request modelClass:(Class)class fetchAllPages:(BOOL)fetchAll {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *task = [self.session dataTaskWithRequest: request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                [subscriber sendError: error];
                return;
            }

            NSError *jsonError = nil;
            id payload = [NSJSONSerialization JSONObjectWithData: data options: 0 error: &jsonError];
            if (jsonError) {
                [subscriber sendError: error];
                return;
            }

            // This is a paged API
            RACSignal *nextPageSignal = [RACSignal empty];
            [[[RACSignal return:RACTuplePack(payload)] concat: nextPageSignal] subscribe: subscriber];
//            if (payload[@"values"]) {
//                if (fetchAll && ![payload[@"isLastPage"] boolValue]) {
//                    // TODO load more
//                }
//
//                [payload[@"values"] enumerateObjectsUsingBlock:^(NSDictionary *objectPayload, NSUInteger idx, BOOL *stop) {
//                    NSError *jsonError = nil;
//                    STKProject *project = [MTLJSONAdapter modelOfClass: class fromJSONDictionary: objectPayload error: &jsonError];
//
//                    if (jsonError) {
//                        [subscriber sendError: jsonError];
//                        *stop = YES;
//                        return;
//                    }
//
//                    [subscriber sendNext: project];
//                }];
//            } else {
//                NSError *jsonError = nil;
//                STKProject *project = [MTLJSONAdapter modelOfClass: class fromJSONDictionary: payload error: &jsonError];
//
//                if (jsonError) {
//                    [subscriber sendError: jsonError];
//                    return;
//                }
//
//                [subscriber sendNext: project];
//            }
//
//            [subscriber sendCompleted];
        }];

        [task resume];

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];

    }];
}

- (NSURLRequest *)createNextPageRequest:(NSURLRequest *)request nextStart:(NSNumber *)nextStart {
    NSURL *url;
    if ([request.URL.absoluteString rangeOfString: @"?"].location == NSNotFound) {
        url = [NSURL URLWithString: [request.URL.absoluteString stringByAppendingFormat: @"?start=%@", nextStart]];
    } else {
        NSString *baseUrl = [[request.URL.absoluteString componentsSeparatedByString: @"?"] firstObject];
        url = [NSURL URLWithString: [baseUrl stringByAppendingFormat: @"?start=%@", nextStart]];
    }

    NSMutableURLRequest *nextPageRequest = [request mutableCopy];
    nextPageRequest.URL = url;

    return nextPageRequest;
}


- (RACSignal *)fetchProjects:(BOOL)all {
    NSURL *url = [[self.user.baseUrl URLByAppendingPathComponent: STKClientAPIEndPoint] URLByAppendingPathComponent: @"projects"];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    [request setValue: [self.user HTTPBasicAuthorizationHeaderValue] forHTTPHeaderField: @"Authorization"];
    [request setValue: @"application/json" forHTTPHeaderField: @"Content-Type"];
    [request setValue: @"application/json" forHTTPHeaderField: @"Accept"];

    return [[[self enqueueRequest: request modelClass: [STKProject class] fetchAllPages: all] reduceEach:^id (NSDictionary *payload){
        NSLog(@"Reducing each payload");

        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            if (payload[@"values"]) {
                [payload[@"values"] enumerateObjectsUsingBlock:^(NSDictionary *objectPayload, NSUInteger idx, BOOL *stop) {
                    NSError *jsonError = nil;
                    STKProject *project = [MTLJSONAdapter modelOfClass: [STKProject class] fromJSONDictionary: objectPayload error: &jsonError];

                    if (jsonError) {
                        [subscriber sendError: jsonError];
                        *stop = YES;
                        return;
                    }

                    [subscriber sendNext: project];
                }];
            } else {
                NSError *jsonError = nil;
                STKProject *project = [MTLJSONAdapter modelOfClass: [STKProject class] fromJSONDictionary: payload error: &jsonError];

                if (jsonError) {
                    [subscriber sendError: jsonError];
                } else {
                    [subscriber sendNext: project];
                }
            }

            [subscriber sendCompleted];

            return nil;
        }];
    }] concat];
}

- (RACSignal *)createProject:(NSString *)name key:(NSString *)key description:(NSString *)description avatar:(NSData *)avatar {
    return nil;
//    NSDictionary *body = @{@"key": key, @"name" : name, @"description" : description};
//    return [[self sendRequestForRessource: @"projects" body: body HTTPMethod: @"POST"] map:^id(NSDictionary *payload) {
//        NSError *error = nil;
//        STKProject *newProject = [MTLJSONAdapter modelOfClass: [STKProject class] fromJSONDictionary: payload error: &error];
//        if (error) {
//            NSLog(@"Got error = %@", error);
//            return nil;
//        }
//
//        return newProject;
//    }];
}

- (RACSignal *)createRepository:(NSString *)name projectKey:(NSString *)key scmId:(NSString *)scmId forkable:(BOOL)forkable {
    return nil;
//    NSDictionary *body = @{@"projectKey": key, @"name" : name, @"scmId" : scmId, @"forkable": @(forkable)};
//    NSString *endpoint = [NSString stringWithFormat: @"projects/%@/repos", key];
//    return [[self sendRequestForRessource: endpoint body: body HTTPMethod: @"POST"] map:^id(NSDictionary *payload) {
//        NSLog(@"payload = %@", payload);
//        NSError *error = nil;
//        STKProject *newProject = [MTLJSONAdapter modelOfClass: [STKRepository class] fromJSONDictionary: payload error: &error];
//        if (error) {
//            NSLog(@"Got error = %@", error);
//            return nil;
//        }
//
//        return newProject;
//    }];
}

@end
