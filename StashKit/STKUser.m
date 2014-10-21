//
//  STKUser.m
//  StashKit
//
//  Created by Romain Pouclet on 2014-10-15.
//  Copyright (c) 2014 Perfectly-Cooked. All rights reserved.
//

#import "STKUser.h"

@implementation STKUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"name" : @"name",
             @"email" : @"emailAddress",
             @"identifier" : @"id",
             @"displayName" : @"displayName",
             @"active" : @"active",
             @"slug" : @"slug",
             @"type" : @"type"
             };
}

@end
