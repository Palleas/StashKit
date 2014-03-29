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

- (RACSignal *)enqueueRequest:(NSURLRequest *)request fetchAllPages:(BOOL)fetchAll {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *task = [self.session dataTaskWithRequest: request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                [subscriber sendError: error];
                return;
            }

            NSError *jsonError = nil;
            id results = [NSJSONSerialization JSONObjectWithData: data options: 0 error: &jsonError];
            if (jsonError) {
                [subscriber sendError: error];
                return;
            }

            // This is a paged API
            if (results[@"values"]) {
                for (NSDictionary *payload in results[@"values"]) {
                    NSError *payloadError;
                    STKProject *project = [MTLJSONAdapter modelOfClass: [STKProject class]
                                                    fromJSONDictionary: payload
                                                                 error: &payloadError];
                    if (error) {
                        [subscriber sendError: payloadError];
                        return;
                    }

                    [subscriber sendNext: project];
                }
            }
            [subscriber sendCompleted];
        }];

        [task resume];

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];

    }];
}

- (RACSignal *)fetchProjects:(BOOL)all {
    NSURL *url = [[self.user.baseUrl URLByAppendingPathComponent: STKClientAPIEndPoint] URLByAppendingPathComponent: @"projects"];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    [request setValue: [self.user HTTPBasicAuthorizationHeaderValue] forHTTPHeaderField: @"Authorization"];
    [request setValue: @"application/json" forHTTPHeaderField: @"Content-Type"];
    [request setValue: @"application/json" forHTTPHeaderField: @"Accept"];

    return [self enqueueRequest: request fetchAllPages: all];
//    return [[self sendRequestForRessource: @"projects" body: nil HTTPMethod: @"GET"] map:^id(NSArray *list) {
//        NSMutableArray *projects = [NSMutableArray array];
//
//        [list enumerateObjectsUsingBlock:^(NSDictionary *payload, NSUInteger idx, BOOL *stop) {
//            NSError *error = nil;
//            STKProject *project = [MTLJSONAdapter modelOfClass: [STKProject class] fromJSONDictionary: payload error: &error];
//            [projects addObject: project];
//        }];
//
//        return projects;
//    }];
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
