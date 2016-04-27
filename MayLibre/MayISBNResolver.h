//
//  MayISBNResolver.h
//  MayLibre
//
//  Created by Jo Brunner on 24.04.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MayISBNResolverResponse)(NSDictionary *result, NSError *error);

@interface MayISBNResolver : NSObject

/**
 * Resolves a ISBN to a book record
 */
- (void)resolveWithISBN:(NSNumber *)isbnNumber
               complete:(MayISBNResolverResponse)completeBlock;

@end