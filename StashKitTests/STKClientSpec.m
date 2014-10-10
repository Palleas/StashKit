//
//  STKClientSpec.m
//  StashKit
//
//  Created by Romain Pouclet on 2014-10-09.
//  Copyright (c) 2014 Perfectly-Cooked. All rights reserved.
//
#define EXP_SHORTHAND

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "StashKit.h"

SpecBegin(STKClient)

describe(@"Authenticated", ^{
    __block STKClient *client;
    __block BOOL success;
    __block NSError *error;
    
    beforeEach(^{
        client = [[STKClient alloc] initWithUsername: @"hal.hordan" password: @"b3w4r3" baseUrl: [NSURL URLWithString:@"http://stash"]];
        expect(client).notTo.beNil();

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return request.URL.query == nil;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSString *string = [[NSBundle bundleForClass: self.class] pathForResource: @"projects" ofType: @"json"];
            return [OHHTTPStubsResponse responseWithFileAtPath: string
                                                    statusCode: 200
                                                       headers: @{@"Content-Type" : @"application/json"}];
        }];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.query isEqualToString: @"start=5"];
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSString *string = [[NSBundle bundleForClass: self.class] pathForResource: @"projects-2" ofType: @"json"];
            return [OHHTTPStubsResponse responseWithFileAtPath: string
                                                    statusCode: 200
                                                       headers: @{@"Content-Type" : @"application/json"}];
        }];
    });
    
    afterEach(^{
        [OHHTTPStubs removeAllStubs];
    });
    
    it(@"should fetch the first batch of projects", ^{
        NSArray *projects = [[[client fetchProjects: NO] collect] asynchronousFirstOrDefault: nil success: &success error: &error];
        expect(success).to.beTruthy();
        expect(error).to.beNil();
        expect(projects).to.beKindOf(NSArray.class);
        expect(projects).to.haveCountOf(5);
    });
    
    it(@"should fetch all the available projects", ^{
        NSArray *projects = [[[client fetchProjects: YES] collect] asynchronousFirstOrDefault: nil success: &success error: &error];
        expect(success).to.beTruthy();
        expect(error).to.beNil();
        expect(projects).to.beKindOf(NSArray.class);
        expect(projects).to.haveCountOf(6);
    });
    
    it(@"should create a project", ^{
    
    });

    it(@"should create a repository for a given project", ^{
        
    });
});

SpecEnd