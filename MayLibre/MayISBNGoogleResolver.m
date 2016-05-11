//
//  MayISBNGoogleResolver.m
//  MayLibre
//
//  Created by Jo Brunner on 27.04.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import "MayISBNGoogleResolver.h"
#import "AFNetworking.h"

@interface MayISBNGoogleResolver()

@property (nonatomic, strong) NSURLSessionConfiguration *configuration;
@property (nonatomic, strong) AFURLSessionManager *manager;

@end

@implementation MayISBNGoogleResolver

- (instancetype)init {
    
    if (self = [super init]) {
        _configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:_configuration];
    }
    
    return self;
}

- (void)resolveWithISBN:(NSNumber *)isbnNumber
               complete:(MayISBNResolverResponse)completeBlock {
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",
                                       @"https://www.googleapis.com/books/v1/volumes?q=isbn:",
                                       isbnNumber,
                                       @"&maxResults=1&projection=full&fields=items"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask =
    [_manager dataTaskWithRequest:request
                completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {

                    NSDictionary *result = [[responseObject objectForKey:@"items"] firstObject];
    
                    completeBlock(result, error);
               }];
    
    [dataTask resume];
 }

@end
