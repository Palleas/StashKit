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
    return @{@"name" : @"name",
             @"identifier" : @"id",
             };
}

- (NSString *)description {
    return [NSString stringWithFormat: @"<%@ #%@ %@>", NSStringFromClass([self class]), self.identifier ?: @"No identifier", self.name ?: @"No name"];
}
@end
