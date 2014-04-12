//
//  STKClientTests.m
//  StashKit
//
//  Created by Romain Pouclet on 2014-04-01.
//  Copyright (c) 2014 Perfectly-Cooked. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "STKClient.h"

@interface STKClientTests : XCTestCase
    
@end

@implementation STKClientTests

- (void)testTheRequestForNextPageIsCreatedWithProperURL {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: @"http://localhost:7990/rest/api/1.0/projects"]];
    [request setValue: @"Basic yay-token" forHTTPHeaderField: @"Authorization"];
    [request setValue: @"application/json" forHTTPHeaderField: @"Content-Type"];
    [request setValue: @"application/json" forHTTPHeaderField: @"Accept"];

    STKClient *client = [[STKClient alloc] initWithUsername: @"hal.jordan"
                                                   password: @"b3w4r3"
                                                    baseUrl: [NSURL URLWithString: @"http://stash.oa.net"]];
    NSURLRequest *nextRequest = [client createNextPageRequest: request nextStart: @26];

    XCTAssertEqualObjects([request allHTTPHeaderFields], [nextRequest allHTTPHeaderFields], @"Both request you have the same headers");
    XCTAssertEqualObjects([NSURL URLWithString: @"http://localhost:7990/rest/api/1.0/projects?start=26"], nextRequest.URL, @"URL should be the same, with the since parameter set to 26");
}

@end
