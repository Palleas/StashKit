//
//  STKRepository.h
//  StashKit
//
//  Created by Romain Pouclet on 2014-03-26.
//  Copyright (c) 2014 Perfectly-Cooked. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface STKRepository : MTLModel <MTLJSONSerializing>

@property (copy) NSString *name;
@property (strong) NSNumber *identifier;
@property (copy) NSArray *cloneURLs;

/**
 *  Return the default clone URL for a repository (preferably the SSH-based one)
 */
- (NSString *)cloneURL;

@end
