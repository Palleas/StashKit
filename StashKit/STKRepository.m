//
//  STKRepository.m
//  StashKit
//
//  Created by Romain Pouclet on 2014-03-26.
//  Copyright (c) 2014 Perfectly-Cooked. All rights reserved.
//

#import "STKRepository.h"

@implementation STKRepository

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"name"        : @"name",
             @"identifier"  : @"id",
             @"cloneURLs"   : @"links.clone"
             };
}

- (NSString *)description {
    return [NSString stringWithFormat: @"<%@ #%@ %@>", NSStringFromClass([self class]), self.identifier ?: @"No identifier", self.name ?: @"No name"];
}

- (NSString *)cloneURL {
    return [[self.cloneURLs sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *url1, NSDictionary *url2) {
        return [url1[@"name"] isEqualToString: @"ssh"] ? NSOrderedAscending : NSOrderedDescending;
    }] firstObject][@"href"];
}

@end
