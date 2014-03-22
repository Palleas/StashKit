//
//  STKProject.h
//  StashKit
//
//  Created by Romain Pouclet on 2014-03-21.
//  Copyright (c) 2014 Perfectly-Cooked. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STKProject : NSObject

@property (copy) NSString *key;
@property (copy) NSString *name;
@property (strong) NSURL *url;
@property (strong) NSNumber *identifier;

@end
