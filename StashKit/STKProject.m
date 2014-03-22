//
//  STKProject.m
//  StashKit
//
//  Created by Romain Pouclet on 2014-03-21.
//  Copyright (c) 2014 Perfectly-Cooked. All rights reserved.
//

#import "STKProject.h"

@implementation STKProject

- (NSString *)description {
    return [NSString stringWithFormat: @"<%@ #%@ %@ - %@>", NSStringFromClass([self class]), self.identifier, self.key, self.name];
}

@end
