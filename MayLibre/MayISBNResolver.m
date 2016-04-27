//
//  MayISBNResolver.m
//  MayLibre
//
//  Created by Jo Brunner on 24.04.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import "MayISBNResolver.h"

@implementation MayISBNResolver

- (void)resolveWithISBN:(NSNumber *)isbnNumber
               complete:(MayISBNResolverResponse)completeBlock {
    
    double delayInSeconds = 2.0;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        NSError *error = nil;
        
        NSDictionary *result = @{
                                 @"version":@"1.0",
                                 @"author":@[
                                           @"Kürschner, Harald",
                                           @"Raus, Thomas",
                                           @"Venter, Joachim"
                                           ]
                                 };
        
        completeBlock(result, error);
    });
    
}

@end
