//
//  STKClient.m
//  StashKit
//
//  Created by Romain Pouclet on 2014-03-21.
//  Copyright (c) 2014 Perfectly-Cooked. All rights reserved.
//

NSString * const STKClientAPIEndPoint = @"/rest/api/1.0/";
NSString * const STKClientResponseValuesKey = @"values";

NSString * const STKClientErrorDomain = @"STKClientErrorDomain";

#import "STKClient.h"
#import "STKProject.h"
#import "STKRepository.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Mantle/Mantle.h>

@interface STKClient ()

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, strong) NSURL *baseUrl;

@end

@implementation STKClient

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password baseUrl:(NSURL *)baseUrl {
    self = [super init];
    if (self) {
        _username = [username copy];
        _password = [password copy];
        _baseUrl = [baseUrl copy];

        NSData *credentials = [[[NSString stringWithFormat: @"%@:%@", self.username, self.password] dataUsingEncoding: NSUTF8StringEncoding] base64EncodedDataWithOptions: 0];

        NSString *hashedCredentials = [[NSString alloc] initWithData: credentials encoding: NSUTF8StringEncoding];

        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.HTTPAdditionalHeaders = @{@"Content-Type" : @"application/json",
                                                @"Accept" : @"application/json",
                                                @"Authorization" : [NSString stringWithFormat: @"Basic %@", hashedCredentials]};

        _session = [NSURLSession sessionWithConfiguration: configuration];
    }
    
    return self;
}

- (RACSignal *)fetchProperties {
    NSURL *url = [[self.baseUrl URLByAppendingPathComponent: STKClientAPIEndPoint] URLByAppendingPathComponent: @"application-properties"];

    return [self enqueueRequest: [NSURLRequest requestWithURL: url] fetchAllPages: YES];
}

- (RACSignal *)enqueueRequest:(NSURLRequest *)request fetchAllPages:(BOOL)fetchAll {
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
            if (fetchAll && payload[@"values"] && ![payload[@"isLastPage"] boolValue]) {
                NSURLRequest *nextPageRequest = [self createNextPageRequest: request nextStart: payload[@"nextPageStart"]];
                NSLog(@"Fetching next page %@", nextPageRequest);

                nextPageSignal = [self enqueueRequest: nextPageRequest fetchAllPages: fetchAll];
            }

            [[[RACSignal return: RACTuplePack(payload, response)] concat: nextPageSignal] subscribe: subscriber];
        }];

        [task resume];

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
}

- (RACSignal *)enqueueRequest:(NSURLRequest *)request modelClass:(Class)class fetchAllPages:(BOOL)fetchAll {
    return [[[self enqueueRequest: request fetchAllPages: fetchAll] reduceEach:^id (NSDictionary *payload, NSHTTPURLResponse *response) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            void(^parsePayload)(NSDictionary *) = ^void(NSDictionary *payload) {
                NSError *jsonError = nil;
                MTLModel *model = [MTLJSONAdapter modelOfClass: class fromJSONDictionary: payload error: &jsonError];
                if (jsonError) {
                    [subscriber sendError: jsonError];
                }

                [subscriber sendNext: model];
            };

            if (409 == response.statusCode) {
                NSError *conflictError = [NSError errorWithDomain: STKClientErrorDomain
                                                     code: STKClientErrorCodeConflict
                                                 userInfo: @{}];
                [subscriber sendError: conflictError];
                return nil;
            }

            if ([payload[@"values"] isKindOfClass: [NSArray class]]) {
                [payload[@"values"] enumerateObjectsUsingBlock:^(NSDictionary *modelPayload, NSUInteger idx, BOOL *stop) {
                    parsePayload(modelPayload);
                }];
                [subscriber sendCompleted];
            } else if ([payload isKindOfClass: [NSDictionary class]]) {
                parsePayload(payload);
                [subscriber sendCompleted];
            } else {
                [subscriber sendError: [NSError errorWithDomain: STKClientErrorDomain code: STKClientErrorCodeUnexpectedResponse userInfo: nil]];
            }

            return nil;
        }];
    }] concat];
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

- (RACSignal *)fetchProjects {
    return [self fetchProjects: YES];
}

- (RACSignal *)fetchProjects:(BOOL)fetchAllPages {
    NSURL *url = [[self.baseUrl URLByAppendingPathComponent: STKClientAPIEndPoint] URLByAppendingPathComponent: @"projects"];

    return [self enqueueRequest: [NSURLRequest requestWithURL: url] modelClass: [STKProject class] fetchAllPages: fetchAllPages];
}

- (RACSignal *)createProject:(NSString *)name key:(NSString *)key description:(NSString *)description avatar:(NSData *)avatar {
    NSDictionary *body = @{@"key": key, @"name" : name, @"description" : description};
    NSURL *url = [[self.baseUrl URLByAppendingPathComponent: STKClientAPIEndPoint] URLByAppendingPathComponent: @"projects"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    NSError *jsonError = nil;
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject: body options: 0 error: &jsonError];
    request.HTTPMethod = @"POST";
    
    if (jsonError) {
        return [RACSignal error: jsonError];
    }

    return [self enqueueRequest: request modelClass: [STKProject class] fetchAllPages: YES];
}

- (RACSignal *)createRepository:(NSString *)name projectKey:(NSString *)key forkable:(BOOL)forkable {
    NSDictionary *body = @{@"projectKey": key, @"name" : name, @"scmId" : @"git", @"forkable": @(forkable)};

    NSURLRequest *request = [self requestWithEndpoint: [NSString stringWithFormat: @"projects/%@/repos", key]
                                               method: @"POST"
                                              payload: body];
    return [self enqueueRequest: request modelClass: [STKRepository class] fetchAllPages: YES];
}

- (NSURLRequest *)requestWithEndpoint:(NSString *)endpoint method:(NSString *)method payload:(id)payload {
    NSURL *url = [self.baseUrl URLByAppendingPathComponent: endpoint];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    NSError *jsonError = nil;
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject: payload options: 0 error: &jsonError];
    request.HTTPMethod = @"POST";
    
    if (jsonError) {
        return nil;
    }
    
    return request;
}

@end
