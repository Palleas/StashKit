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
            NSString *lastpart = [[request.URL.path componentsSeparatedByString: @"/"] lastObject];
            return [lastpart isEqualToString: @"projects"] && [request.HTTPMethod isEqualToString: @"GET"];
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
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            NSString *lastpart = [[request.URL.path componentsSeparatedByString: @"/"] lastObject];
            return [request.HTTPMethod isEqualToString: @"POST"] && [lastpart isEqualToString: @"projects"];
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSString *string = [[NSBundle bundleForClass: self.class] pathForResource: @"create-project" ofType: @"json"];
            return [OHHTTPStubsResponse responseWithFileAtPath: string
                                                    statusCode: 200
                                                       headers: @{@"Content-Type" : @"application/json"}];
        }];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.HTTPMethod isEqualToString: @"POST"]
                && [request.URL.path rangeOfString: @"projects/COP/repos"].location != NSNotFound;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSString *string = [[NSBundle bundleForClass: self.class] pathForResource: @"create-repository" ofType: @"json"];
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
        RACSignal *createSignal = [client createProject: @"Cool project" key: @"COP" description: @"My cool project description" avatar: nil];
        STKProject *project = [createSignal asynchronousFirstOrDefault: nil success: &success error: &error];
        expect(success).to.beTruthy();
        expect(error).to.beNil();
        expect(project).to.beKindOf(STKProject.class);
        expect(project).notTo.beNil();
        expect(project.name).to.equal(@"Cool project");
        expect(project.key).to.equal(@"COP");
        expect(project.projectDescription).to.equal(@"My cool project description");
    });

    it(@"should create a repository for a given project", ^{
        RACSignal *createSignal = [client createRepository: @"My repo" projectKey: @"COP" forkable: YES];
        STKRepository *repository = [createSignal asynchronousFirstOrDefault: nil success: &success error: &error];
        expect(success).to.beTruthy();
        expect(error).to.beNil();
        expect(repository).to.beKindOf(STKRepository.class);
        expect(repository).notTo.beNil();
        expect(repository.name).to.equal(@"My repo");
    });
});

SpecEnd