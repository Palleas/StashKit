//
//  STKProject.h
//  StashKit
//
//  Created by Romain Pouclet on 2014-03-21.
//  Copyright (c) 2014 Perfectly-Cooked. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface STKProject : MTLModel <MTLJSONSerializing>

@property (copy) NSString *key;
@property (copy) NSString *name;
@property (strong) NSURL *URL;
@property (strong) NSNumber *identifier;

@end
