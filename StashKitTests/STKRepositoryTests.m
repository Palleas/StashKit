//
//  STKRepositoryTests.m
//  StashKit
//
//  Created by Romain Pouclet on 2014-03-27.
//  Copyright (c) 2014 Perfectly-Cooked. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "STKRepository.h"
#import <Mantle/Mantle.h>

@interface STKRepositoryTests : XCTestCase

@end

@implementation STKRepositoryTests

- (void)testCloneURLReturnsTheSSHURLFirst {
    STKRepository *repository = [[STKRepository alloc] init];
    repository.cloneURLs = @[@{@"href": @"https://github.com/Palleas/StashKit.git",
                               @"name": @"http"
                               },
                             @{@"href": @"git@github.com:Palleas/StashKit.git",
                               @"name": @"ssh"
                               }];
    XCTAssertEqualObjects(@"git@github.com:Palleas/StashKit.git", [repository cloneURL], @"Clone url should be the SSH one, git@github.com:Palleas/StashKit.git");
}

@end
