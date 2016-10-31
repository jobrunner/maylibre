//
//  MayImagePickerController.h
//  MayImagePickerController
//
//  Created by Jo Brunner on 29.10.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//
@import Foundation;
@import UIKit;

@protocol MayImagePickerDelegate;


typedef NS_ENUM(NSInteger, SourceType) {
    SourceTypeCamera,
    SourceTypeLibrary
};


@interface MayImagePickerController : UIViewController <
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate>

@property (nonatomic, assign) SourceType sourceType;
@property (nonatomic, weak) id<MayImagePickerDelegate> delegate;

+ (void)lastTakenImageFromLibrary:(void(^)(UIImage *image, NSDictionary *info))complete;

@end


@protocol MayImagePickerDelegate <NSObject>

- (void)imagePicker:(MayImagePickerController *)controller
     didSelectImage:(UIImage *)image;

- (void)imagePickerDidCancel:(MayImagePickerController *)controller;

@end
