//
//  MayImageCropperController.h
//  MayImageCropperController
//
//  Created by Jo Brunner on 29.10.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//
@import Foundation;
@import UIKit;

@protocol MayImageCropperDelegate;


@interface MayImageCropperController : UIViewController

@property (nonatomic, weak) id<MayImageCropperDelegate> delegate;

- (instancetype)initWithOriginalImage:(UIImage *)image;

@end


@protocol MayImageCropperDelegate <NSObject>

@optional

- (void)imageCropper:(MayImageCropperController *)controller
     didCaptureImage:(UIImage *)image;

- (void)imageCropperDidCancel:(MayImageCropperController *)controller;

@end
