//
//  STKUser.h
//  StashKit
//
//  Created by Romain Pouclet on 2014-10-15.
//  Copyright (c) 2014 Perfectly-Cooked. All rights reserved.
//

#import "MTLModel.h"
#import <Mantle/Mantle.h>

@interface STKUser : MTLModel <MTLJSONSerializing>

@property (copy) NSString *name;
@property (copy) NSString *email;
@property (copy) NSNumber *identifier;
@property (copy) NSString *displayName;
@property (assign) BOOL active;
@property (copy) NSString *slug;
@property (copy) NSString *type;

@end
