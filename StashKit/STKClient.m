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

#import <ReactiveCocoa/ReactiveCocoa.h>

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

- (RACSignal *)sendRequestForRessource:(NSString *)ressource body:(id)body HTTPMethod:(NSString *)method {
    NSParameterAssert(ressource != nil);

    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // Build request
        NSURL *url = [[self.user.baseUrl URLByAppendingPathComponent: STKClientAPIEndPoint] URLByAppendingPathComponent: ressource];

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
        [request setValue: [self.user HTTPBasicAuthorizationHeaderValue] forHTTPHeaderField: @"Authorization"];
        [request setValue: @"application/json" forHTTPHeaderField: @"Content-Type"];
        [request setValue: @"application/json" forHTTPHeaderField: @"Accept"];
        request.HTTPMethod = method;

        if (body != nil) {
            NSError *jsonEncodingError = nil;
            request.HTTPBody = [NSJSONSerialization dataWithJSONObject: body options: 0 error: &jsonEncodingError];

            if (jsonEncodingError) {
                [subscriber sendError: jsonEncodingError];
            }
        }

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

            [subscriber sendNext: results[@"values"]];
        }];

        [task resume];

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];

    }];
}

- (RACSignal *)fetchProjects {
    return [[self sendRequestForRessource: @"projects" body: nil HTTPMethod: @"GET"] map:^id(NSArray *list) {
        NSMutableArray *projects = [NSMutableArray array];

        [list enumerateObjectsUsingBlock:^(NSDictionary *payload, NSUInteger idx, BOOL *stop) {
            STKProject *project = [[STKProject alloc] init];
            project.identifier = payload[@"id"];
            project.key = payload[@"key"];
            NSLog(@"Setting project name to %@", payload[@"name"]);
            project.name = payload[@"name"];
            project.url = [NSURL URLWithString: payload[@"url"]];

            [projects addObject: project];
        }];

        return projects;
    }];
}

@end
