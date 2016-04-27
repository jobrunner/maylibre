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
    
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                        @"https://www.googleapis.com/books/v1/volumes?q=isbn:",
                                        isbnNumber]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask =
    [_manager dataTaskWithRequest:request
                completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                    if (error) {
                        // NSLog(@"Error: %@", error);
                        completeBlock(nil, error);
                    }
                    else {
//                       NSLog(@"%@ %@", response, responseObject);
//                       NSLog(@"%@", responseObject);
                        NSString *resourceId = [[[responseObject objectForKey:@"items"] firstObject] objectForKey:@"id"];
                       
//                        NSLog(@"resourceId: %@", resourceId);
                       
                        [self resolveWithResourceId:resourceId
                                           complete:^(NSDictionary *result, NSError *error) {
                                                completeBlock(result, error);
                                           }];
                    }
               }];
    
    [dataTask resume];
 }

- (void)resolveWithResourceId:(NSString *)resourceId
               complete:(MayISBNResolverResponse)completeBlock {

    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                       @"https://www.googleapis.com/books/v1/volumes/",
                                       resourceId]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask =
    [_manager dataTaskWithRequest:request
                completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                    if (error) {
                        NSLog(@"Error: %@", error);
                        completeBlock(nil, error);
                    }
                    else {
                        completeBlock(responseObject, error);
                    }
                }];
    
    [dataTask resume];
}

@end
